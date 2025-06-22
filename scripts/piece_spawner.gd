extends Node2D

@export var spawn_points: Array[Marker2D] = []
@export var board: Board
@export var shapes: Array[PieceConfig]

const piece_scene = preload("res://scenes/piece.tscn")

var pieces: Array[Piece] = []

func _ready():
	spawn_new()

# Weighted random sampling
func _random_shape(shapes_list: Array[PieceConfig]) -> PieceConfig:
	var probability_sum := 0.0
	for i in shapes_list:
		probability_sum += i.probability
	var p = randf_range(0,probability_sum)
	for i in shapes_list:
		p -= i.probability
		if p <= 0:
			return i
	return null

func spawn_new():
	for i in pieces:
		if is_instance_valid(i):
			i.queue_free()
	pieces = []
	
	for i in spawn_points:
		var piece: Piece = piece_scene.instantiate()
		piece.shape = _random_shape(shapes).shape;
		piece.modulate = Constants.BRICK_COLORS.pick_random()
		piece.board = board
		piece.global_position = i.global_position
		piece.tree_exited.connect(_handle_piece_placed.bind(piece))
		add_child(piece)
		pieces.append(piece)

func _handle_piece_placed(piece: Piece):
	for i in pieces:
		if is_instance_valid(i):
			if piece != i:
				return
	spawn_new()
