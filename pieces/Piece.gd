extends Node2D

signal selected

const gridSize := 128;
const baseVector := Vector2(1, 1)
const orientationVector := Vector2(1, 0)

var grid_position: Vector2 setget set_grid_position, get_grid_position
var placed := false
var accumulated_rotation := 0.0
var player: int
var in_occupied_area := false

func belong_to_white() -> bool:
	return player == Global.Player.WHITE

func belong_to_black() -> bool:
	return player == Global.Player.BLACK

func rotate(radians: float):
	.rotate(radians)
	accumulated_rotation += radians

func set_grid_position(newGridPosition: Vector2) -> void:
	position = newGridPosition * gridSize

func get_grid_position() -> Vector2:
	return (position / gridSize).snapped(baseVector)

func get_pieces_position() -> PoolVector2Array:
	var result := PoolVector2Array()
	for child in $Tiles.get_children():
		var child_position = (child.global_position - global_position) * 8
		var relative_position = position + child_position
		var gridPostion = relative_position / gridSize
		result.append(gridPostion)
	return result

func _on_ClickArea_input_event(viewport, event, shape_idx):
	if event.is_action("ui_tap"):
		if not placed:
			emit_signal("selected")