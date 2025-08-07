class_name PieceSpawner
extends Node2D

@export var spawn_points: Array[Marker2D] = []
@export var board: Board
@export var shapes: Array[PieceConfig]

const piece_scene = preload("res://scenes/piece.tscn")

var pieces: Array[Piece] = []
signal unplacable

func _ready():
	for i in shapes:
		assert(i.probability > 0)

func spawn_piece(index: int, shape: int, color: Color):
	var piece: Piece = piece_scene.instantiate()
	piece.shape = shape
	piece.color = color
	piece.board = board
	spawn_points[index].add_child.call_deferred(piece)
	pieces.append(piece)

func spawn_new_round():
	for i in pieces:
		if is_instance_valid(i):
			i.queue_free()
	pieces = []
	
	var random_shapes: Array[int] = []
	
	for i in len(spawn_points):
		for j in BoardUtils.random_sort(shapes):
			random_shapes.append(j.bitfield)
	
	var usable = BoardUtils.find_usable_blocks(len(spawn_points), 0, random_shapes, len(shapes), board.gen_bitfield())
	usable.shuffle()
	for i in len(spawn_points):
		spawn_piece(i, usable[i], Constants.BRICK_COLORS.pick_random())

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
		spawn_new_round()
		return
	
	if not placable:
		unplacable.emit()

func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey:
			if event.keycode == KEY_SPACE:
				unplacable.emit()
		elif event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed:
				var pos = Vector2i(round((event.position-board.global_position-Constants.BRICK_OFFSET)/Constants.BRICK_SIZE))
				var brick: Node2D = Piece.brick_scene.instantiate()
				brick.modulate = Constants.BRICK_COLORS.pick_random()
				board.try_fill_at(pos,brick)
