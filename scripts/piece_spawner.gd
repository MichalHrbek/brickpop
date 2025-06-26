@tool
extends Node2D

@export var spawn_points: Array[Marker2D] = []
@export var board: Board
@export var shapes: Array[PieceConfig]

const piece_scene = preload("res://scenes/piece.tscn")

var pieces: Array[Piece] = []


func _ready():
	spawn_new()

@export_tool_button("Bit") var action = bit
func bit():
	print(16<<63)
	for i in shapes:
		var bitfield = 0
		for j in i.shape:
			bitfield |= (1 << (j.x+j.y*8))
		i.bitfield = bitfield
		ResourceSaver.save(i,i.resource_path)


func spawn_new():
	for i in pieces:
		if is_instance_valid(i):
			i.queue_free()
	pieces = []
	
	for i in spawn_points:
		var piece: Piece = piece_scene.instantiate()
		piece.shape = BoardUtils.random_shape(shapes).bitfield;
		piece.modulate = Constants.BRICK_COLORS.pick_random()
		piece.board = board
		piece.global_position = i.global_position
		piece.tree_exited.connect(_on_piece_placed.bind(piece))
		add_child(piece)
		pieces.append(piece)

func _on_piece_placed(piece: Piece):
	for i in pieces:
		if is_instance_valid(i):
			if piece != i:
				return
	spawn_new()
