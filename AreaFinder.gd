class_name AreaFinder

const Piece = preload("res://pieces/Piece.gd")

const GRID_SIZE := 10

var matrix := []
var visited_points := []
var white_areas := []
var black_areas := []
var pieces := []

func _init():
	for x in range(GRID_SIZE):
    matrix.append([])
    for y in range(GRID_SIZE):
        matrix[x].append(Global.Player.NONE)

func add_piece(piece: Piece) -> void:
	pieces.append(piece)
	for position in piece.get_pieces_position():
		var y :int = round(position.y)
		var x :int = round(position.x)
		matrix[y][x] = piece.player
#	for row in matrix:
#		print(row)
	recalculate_areas(piece.player)

func recalculate_areas(player: int) -> void:
	if player == Global.Player.WHITE:
		white_areas = []
	if player == Global.Player.BLACK:
		black_areas = []
	visited_points = []
	for i in range(10):
		for j in range(10):
			if visited_points.has([i, j]):
				continue
			var area := {"area":[], "player": player, "valid": true}
			mark_neigbours([i, j], area)
			if not area.area.empty():
				if player == Global.Player.WHITE:
					white_areas.append(area)
				if player == Global.Player.BLACK:
					black_areas.append(area)
			area.valid = area.valid && area.area.size() < 40
			var pieces_inside := []
			for piece in pieces:
				var position = piece.grid_position
				var y :int = round(position.y)
				var x :int = round(position.x)
				if area.area.has([y, x]):
					pieces_inside.append(piece)
			area.valid = area.valid && pieces_inside.size() < 2
			
			for piece_inside in pieces_inside:
				piece_inside.in_occupied_area = area.valid

func mark_neigbours(coordinates: Array, current_area: Dictionary) -> void:
	if coordinates[0] < 0 || coordinates[0] > 9:
		return
	if coordinates[1] < 0 || coordinates[1] > 9:
		return
	if matrix[coordinates[0]][coordinates[1]] == current_area.player:
		return
	if visited_points.has(coordinates):
		return
	current_area.area.append(coordinates)
	visited_points.append(coordinates)
	mark_neigbours([coordinates[0] - 1, coordinates[1]], current_area)
	mark_neigbours([coordinates[0] + 1, coordinates[1]], current_area)
	mark_neigbours([coordinates[0], coordinates[1] - 1], current_area)
	mark_neigbours([coordinates[0], coordinates[1] + 1], current_area)
	mark_neigbours([coordinates[0] - 1, coordinates[1] - 1], current_area)
	mark_neigbours([coordinates[0] + 1, coordinates[1] + 1], current_area)
	mark_neigbours([coordinates[0] - 1, coordinates[1] + 1], current_area)
	mark_neigbours([coordinates[0] + 1, coordinates[1] - 1], current_area)