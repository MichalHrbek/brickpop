class_name Board extends Node2D

const hole_scene = preload("res://scenes/hole.tscn")

var holes: Array[Hole] = []

signal completed(completions: PackedByteArray, board_after: int)

func _ready():
	for i in 8:
		for j in 8:
			var hole = hole_scene.instantiate()
			hole.position = Vector2(j*Constants.BRICK_SIZE,i*Constants.BRICK_SIZE)+Constants.BRICK_OFFSET
			add_child(hole)
			holes.append(hole)

func _process(delta):
	var pieces = get_tree().get_nodes_in_group("pieces")
	
	for i in holes:
		i.hide_highlight()
		i.modulate = Color.WHITE
	
	for i in pieces:
		var pos = round((i.global_position-(global_position))/Constants.BRICK_SIZE)
		if not BoardUtils.can_shift_shape(i.shape, pos): continue
		var bitfield := gen_bitfield()
		var shape = BoardUtils.shift_shape(i.shape, pos)
		if shape & gen_bitfield(): continue
		for j in 64:
			if shape & (1 << j):
				holes[j].show_highlight(i.color)
				bitfield |= (1 << j)
		bitfield = BoardUtils.get_complete(bitfield)
		for j in 64:
			if bitfield & (1 << j):
				holes[j].modulate = i.color
				# TODO: Change brick color to i.color instead of modulate

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
				holes[y*8+x].fill(brick)
	
	piece.queue_free()
	check_completion()
	return true

func gen_bitfield() -> int:
	var bitfield := 0
	for i in 64:
		if holes[i].brick:
			bitfield |= (1 << i)
	return bitfield

func check_completion():
	var to_destroy = BoardUtils.check_completion_points(gen_bitfield())
	
	var complete := false
	
	for i in 64:
		if to_destroy[i]:
			complete = true
			holes[i].clear()
	
	if complete:
		completed.emit(to_destroy, gen_bitfield())
