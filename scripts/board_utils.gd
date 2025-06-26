class_name BoardUtils

static func can_shift_shape(shape: int, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= 8: return false
	if pos.y < 0 or pos.y >= 8: return false
	if is_oob(shape, pos): return false
	return true

static func shift_shape(shape: int, pos: Vector2i) -> int:
	return shape >> (pos.x+pos.y*8)

static func is_oob(piece: int, pos: Vector2i) -> bool: # true -> is out of bounds
	if pos.y*8+pos.x >= 64: return true
	var mask_8b: int = 0b11111111 >> (8-pos.x)
	var mask = mask_8b * 0x0101010101010101
	#var mask: int = ~(mask_8b | (mask_8b << 8) | (mask_8b << 16) | (mask_8b << 24) | (mask_8b << 32) | (mask_8b << 40) | (mask_8b << 48) | (mask_8b << 56))
	return (piece >> (64 - pos.y*8+pos.x)) or (mask & piece)

static func check_completion_points(bitfield: int) -> PackedByteArray:
	var to_destroy = PackedByteArray()
	to_destroy.resize(64)
	for y in 8:
		var complete = true
		for x in 8:
			if not (bitfield & (1 << (y*8+x))):
				complete = false
				break
		if complete:
			for x in 8:
				to_destroy[y*8+x] += 1
	
	for x in 8:
		var complete = true
		for y in 8:
			if not (bitfield & (1 << (y*8+x))):
				complete = false
				break
		if complete:
			for y in 8:
				to_destroy[y*8+x] += 1

	return to_destroy

# Weighted random sampling
static func random_shape(shapes_list: Array[PieceConfig]) -> PieceConfig:
	var probability_sum := 0.0
	for i in shapes_list:
		probability_sum += i.probability
	var p = randf_range(0,probability_sum)
	for i in shapes_list:
		p -= i.probability
		if p <= 0:
			return i
	return null

static func random_sort(shapes_list: Array[PieceConfig]) -> Array[PieceConfig]:
	shapes_list = shapes_list.duplicate()
	var arr: Array[PieceConfig] = []
	
	var probability_sum := 0.0
	for i in shapes_list:
		probability_sum += i.probability
	
	while len(shapes_list):
		var p = randf_range(0,probability_sum)
		for i in shapes_list: # TODO: binary search
			p -= i.probability
			if p <= 0:
				arr.append(i)
				break
	
	return arr
