extends Node

const GRID_SIZE := 128

enum Player {NONE, WHITE, BLACK, NEUTRAL}
const Piece = preload("res://pieces/Piece.gd")

var selectedNode: Piece
var selectedOrientation: int
var selectedDockPosition: Vector2
var current_player: int = Player.WHITE

func switch_turn() -> void:
	if current_player == Player.WHITE:
		current_player = Player.BLACK
	else:
		assert current_player == Player.BLACK
		current_player = Player.WHITE