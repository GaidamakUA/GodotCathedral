extends Node2D

const gridSize := 120;

const baseVector := Vector2(1, 1)

const Piece = preload("res://pieces/Piece.gd")
const Cathedral = preload("res://pieces/Cathedral.tscn")
const AreaFinder = preload("res://AreaFinder.gd")
const Marker = preload("res://pieces/locked_area_marker.tscn")
var areaFinder: AreaFinder = null
var cathedral: Piece = null

# To prevent borderline cases
const grid_size := Rect2(-0.1, -0.1, 9.2, 9.2)
const occupied_tiles := PoolVector2Array()

func _ready():
	cathedral = Cathedral.instance()
	areaFinder = AreaFinder.new()
	Global.selectedNode = cathedral
	cathedral.player = Global.Player.NEUTRAL
	cathedral.connect("selected", self, "_on_piece_selected", [cathedral])
	var white_pieces := $WhitePieces.get_children()
	for piece in white_pieces:
		piece.connect("selected", self, "_on_piece_selected", [piece])
		piece.player = Global.Player.WHITE
	var black_pieces := $BlackPieces.get_children()
	for piece in black_pieces:
		piece.connect("selected", self, "_on_piece_selected", [piece])
		piece.player = Global.Player.BLACK
		piece.modulate = Color(0.5, 0.5, 0.5)
	update_text_label()

func update_text_label() -> void:
	if is_whites_turn():
		$UI/Label.text = "The turn of the WHITE"
	else:
		assert is_blacks_turn()
		$UI/Label.text = "The turn of the BLACK"

func is_whites_turn() -> bool:
	return Global.current_player == Global.Player.WHITE

func is_blacks_turn() -> bool:
	return Global.current_player == Global.Player.BLACK

func _on_piece_selected(piece: Piece) -> void:
	if (Global.selectedNode == piece):
		place_piece_if_possible()
		return
	if (is_whites_turn() && piece.belong_to_black()):
		return
	if (is_blacks_turn() && piece.belong_to_white()):
		return
	if (Global.selectedNode == cathedral):
		return
	if (Global.selectedNode != null):
		get_piece_holder().add_child(Global.selectedNode)
		Global.selectedNode.grid_position = Global.selectedDockPosition
		Global.selectedNode.rotate(-Global.selectedNode.accumulated_rotation)
	Global.selectedDockPosition = piece.grid_position
	Global.selectedNode = piece
	get_piece_holder().remove_child(piece)

func get_piece_holder() -> Node:
	if is_whites_turn():
		return $WhitePieces
	else:
		assert is_blacks_turn()
		return $BlackPieces

func place_piece_if_possible() -> void:
	var piece := Global.selectedNode
	var tile_positions := piece.get_pieces_position()
	var placing_possible = true
	for grid_position in tile_positions:
		if not grid_size.has_point(grid_position):
			placing_possible = false
			break
		for occupied in occupied_tiles:
			if occupied.distance_squared_to(grid_position) < 0.1:
				placing_possible = false
				break
		var blocked_points := get_blocked_points()
		for blocked_point in blocked_points:
			var point_poisiton := Vector2(blocked_point[1], blocked_point[0])
			if point_poisiton.distance_squared_to(grid_position) < 0.1:
				placing_possible = false
				break
	if placing_possible:
		Global.selectedNode.placed = true
		Global.selectedNode = null
		for grid_position in tile_positions:
			occupied_tiles.append(grid_position)
		Global.switch_turn()
		update_text_label()
		process_piece_for_areas(piece)

func process_piece_for_areas(piece: Piece) -> void:
	areaFinder.add_piece(piece)
	for marker in $Markers.get_children():
		$Markers.remove_child(marker)
	var areas
	if Global.current_player == Global.Player.WHITE:
		areas = areaFinder.black_areas
	else:
		areas = areaFinder.white_areas
	for area in areas:
		if not area.valid:
			continue
		for coordinate in area["area"]:
			var marker = Marker.instance()
			$Markers.add_child(marker)
			marker.grid_position = Vector2(coordinate[1], coordinate[0])

func get_blocked_points() -> Array:
	var areas
	if Global.current_player == Global.Player.WHITE:
		areas = areaFinder.black_areas
	else:
		areas = areaFinder.white_areas
	var result := []
	for area in areas:
		if area.valid:
			for point in area.area:
				result.append(point)
	return result

func _on_BoardArea_mouse_entered():
	if (Global.selectedNode != null):
		$GameBoard.add_child(Global.selectedNode)

func _on_BoardArea_mouse_exited():
	if (Global.selectedNode != null):
		$GameBoard.remove_child(Global.selectedNode)

func _on_BoardArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseMotion && Global.selectedNode != null:
		var coordinate = event.global_position / scale - $Background.position# / scale
		var gridPosition = $Background/Field.world_to_map(coordinate) - Vector2(1, 1)
		Global.selectedNode.grid_position = gridPosition

func _on_ClockwiseButton_pressed():
	if (Global.selectedNode != null):
		Global.selectedNode.rotate(-PI/2)


func _on_CounterclockwiseButton_pressed():
	if (Global.selectedNode != null):
		Global.selectedNode.rotate(PI/2)