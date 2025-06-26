class_name Board extends Area2D

@onready var collision_shape = %CollisionShape2D

const hole_scene = preload("res://scenes/hole.tscn")

var holes: Array[Node2D] = []
var bricks: Array[Node2D] = []

signal completed(field: PackedByteArray)

func _ready():
	collision_shape.shape.size = Vector2(Constants.BRICK_SIZE*8,Constants.BRICK_SIZE*8)
	collision_shape.position = Vector2(Constants.BRICK_SIZE*8/2.0,Constants.BRICK_SIZE*8/2.0)
	for i in 8:
		for j in 8:
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
		if pos.x < 0 or pos.x >= 8: continue
		if pos.y < 0 or pos.y >= 8: continue
		holes[pos.y*8+pos.x].modulate = Color.WHITE*1.25

func can_place(start_pos: Vector2i, shape: Array[Vector2i]) -> bool:
	for i in len(shape):
		var pos = start_pos+shape[i]
		if pos.x < 0 or pos.x >= 8: return false
		if pos.y < 0 or pos.y >= 8: return false
		if bricks[pos.y*8+pos.x]: return false
	return true

func try_place(piece: Piece) -> bool:
	var start_pos = Vector2i(round((piece.bricks[0].global_position-(global_position+Constants.BRICK_OFFSET))/Constants.BRICK_SIZE))-piece.shape[0]
	
	if not can_place(start_pos, piece.shape):
		return false
	
	for i in len(piece.shape):
		var pos = start_pos+piece.shape[i]
		piece.bricks[i].reparent(self)
		bricks[pos.y*8+pos.x] = piece.bricks[i]
		piece.bricks[i].position = Constants.BRICK_OFFSET + pos*Constants.BRICK_SIZE
	
	piece.queue_free()
	check_completion()
	return true

func gen_bitmap() -> int:
	print(64>>16)
	var bitmap := 0
	for i in 64:
		if bricks[i]:
			bitmap |= (1 << i)
	return bitmap

func check_completion():
	var to_destroy = BoardUtils.check_completion_points(gen_bitmap())
	
	var complete := false
	
	for i in 64:
		if to_destroy[i]:
			complete = true
			bricks[i].queue_free()
			bricks[i] = null
	
	if complete:
		completed.emit(to_destroy)

func can_fit(shape: Array[Vector2i]) -> bool:
	for x in 8:
		for y in 8:
			if can_place(Vector2i(x,y), shape):
				return true
	return false
