class_name Board extends Area2D

@export var width = 8
@export var height = 8

@onready var collision_shape = %CollisionShape2D

const hole_scene = preload("res://scenes/hole.tscn")

var holes: Array[Node2D] = []
var bricks: Array[Node2D] = []

signal completed(field: PackedByteArray)

func _ready():
	collision_shape.shape.size = Vector2(Constants.BRICK_SIZE*width,Constants.BRICK_SIZE*height)
	collision_shape.position = Vector2(Constants.BRICK_SIZE*width/2.0,Constants.BRICK_SIZE*height/2.0)
	for i in height:
		for j in width:
			var hole = hole_scene.instantiate()
			hole.position = Vector2(j*Constants.BRICK_SIZE,i*Constants.BRICK_SIZE)+Constants.BRICK_OFFSET
			add_child(hole)
			holes.append(hole)
			bricks.append(null)

func _process(delta):
	var piece_bricks = get_overlapping_areas()
	
	for i in holes:
		i.modulate = Color.WHITE
	
	for i in piece_bricks:
		var pos = round((i.global_position-(global_position+Constants.BRICK_OFFSET))/Constants.BRICK_SIZE)
		if pos.x < 0 or pos.x >= width: continue
		if pos.y < 0 or pos.y >= height: continue
		holes[pos.y*width+pos.x].modulate = Color.WHITE*1.25

func can_place(start_pos: Vector2i, shape: Array[Vector2i]) -> bool:
	for i in len(shape):
		var pos = start_pos+shape[i]
		if pos.x < 0 or pos.x >= width: return false
		if pos.y < 0 or pos.y >= height: return false
		if bricks[pos.y*width+pos.x]: return false
	return true

func try_place(piece: Piece) -> bool:
	var start_pos = Vector2i(round((piece.bricks[0].global_position-(global_position+Constants.BRICK_OFFSET))/Constants.BRICK_SIZE))-piece.shape[0]
	
	if not can_place(start_pos, piece.shape):
		return false
	
	for i in len(piece.shape):
		var pos = start_pos+piece.shape[i]
		piece.bricks[i].reparent(self)
		bricks[pos.y*width+pos.x] = piece.bricks[i]
		piece.bricks[i].position = Constants.BRICK_OFFSET + pos*Constants.BRICK_SIZE
	
	piece.queue_free()
	check_completion()
	return true

func gen_bitmap() -> PackedByteArray:
	var arr := PackedByteArray()
	arr.resize(width*height)
	for i in width*height:
		if bricks[i]:
			arr[i] = 1
	return arr

func check_completion():
	var to_destroy = BoardUtils.check_completion(gen_bitmap(), width, height)
	
	var complete := false
	
	for i in height*width:
		if to_destroy[i]:
			complete = true
			bricks[i].queue_free()
			bricks[i] = null
	
	if complete:
		completed.emit(to_destroy)

func can_fit(shape: Array[Vector2i]) -> bool:
	for i in width:
		for j in height:
			if can_place(Vector2i(i,j), shape):
				return true
	return false
