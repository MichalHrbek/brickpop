extends Node2D

@export var spawn_points: Array[Marker2D] = []
@export var board: Board
@export var shapes: Array[PieceConfig]

const piece_scene = preload("res://scenes/piece.tscn")

var pieces: Array[Piece] = []

func _ready():
	for i in shapes:
		assert(i.probability > 0)
	spawn_new()

func spawn_new():
	for i in pieces:
		if is_instance_valid(i):
			i.queue_free()
	pieces = []
	
	var random_shapes: Array[int] = []
	
	for i in len(spawn_points):
		for j in BoardUtils.random_sort(shapes):
			random_shapes.append(j.bitfield)
	
	var usable = BoardUtils.find_usable_blocks(len(spawn_points), 0, random_shapes, len(shapes), board.gen_bitfield())
	for i in len(spawn_points):
		var piece: Piece = piece_scene.instantiate()
		piece.shape = usable[i]
		piece.color = Constants.BRICK_COLORS.pick_random()
		piece.board = board
		piece.global_position = spawn_points[i].global_position
		piece.tree_exited.connect(_on_piece_placed.bind(piece))
		add_child(piece)
		pieces.append(piece)

func _on_piece_placed(piece: Piece):
	var valid = false
	var placable = false
	
	for i in pieces:
		if is_instance_valid(i):
			if piece != i:
				valid = true
				if BoardUtils.can_fit_shape(i.shape, board.gen_bitfield()):
					placable = true
	
	if not valid:
		spawn_new()
		return
	
	if not placable:
		print("GG you lost!")
