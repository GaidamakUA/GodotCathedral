extends Node2D

const baseVector := Vector2(1, 1)

var grid_position: Vector2 setget set_grid_position, get_grid_position\

func set_grid_position(newGridPosition: Vector2) -> void:
	position = newGridPosition * Global.GRID_SIZE

func get_grid_position() -> Vector2:
	return (position / Global.GRID_SIZE).snapped(baseVector)