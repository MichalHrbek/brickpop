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
	
	for i in bricks:
		if is_instance_valid(i):
			i.modulate = Color.WHITE
	
	var bitfield := gen_bitfield()
	for i in piece_bricks:
		var pos = round((i.global_position-(global_position+Constants.BRICK_OFFSET))/Constants.BRICK_SIZE)
		if pos.x < 0 or pos.x >= 8: continue
		if pos.y < 0 or pos.y >= 8: continue
		holes[pos.y*8+pos.x].modulate = Color.WHITE*1.25
		bitfield |= (1 << int(pos.y*8+pos.x))
	
	bitfield = BoardUtils.get_complete(bitfield)
	for i in 64:
		if bitfield & (1 << i):
			if is_instance_valid(bricks[i]):
				bricks[i].modulate = Color.GREEN
			holes[i].modulate = Color.GREEN

func try_place(piece: Piece) -> bool:
	var start_pos = Vector2i(round((piece.global_position-global_position)/Constants.BRICK_SIZE))
	
	if not BoardUtils.can_shift_shape(piece.shape, start_pos):
		return false
	
	var shifted = BoardUtils.shift_shape(piece.shape, start_pos)
	
	if shifted & gen_bitfield():
		return false
	
	for x in 8:
		for y in 8:
			if shifted & (1 << (y*8+x)):
				var brick = piece.bricks.pop_front()
				brick.reparent(self)
				bricks[y*8+x] = brick
				brick.position = Constants.BRICK_OFFSET + Vector2(x,y)*Constants.BRICK_SIZE
	
	piece.queue_free()
	check_completion()
	return true

func gen_bitfield() -> int:
	var bitfield := 0
	for i in 64:
		if bricks[i]:
			bitfield |= (1 << i)
	return bitfield

func check_completion():
	var to_destroy = BoardUtils.check_completion_points(gen_bitfield())
	
	var complete := false
	
	for i in 64:
		if to_destroy[i]:
			complete = true
			bricks[i].queue_free()
			bricks[i] = null
	
	if complete:
		completed.emit(to_destroy)
