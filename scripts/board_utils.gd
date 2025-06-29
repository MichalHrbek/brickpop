class_name BoardUtils

static func can_shift_shape(shape: int, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.x >= 8: return false
	if pos.y < 0 or pos.y >= 8: return false
	if is_oob(shape, pos): return false
	return true

static func shift_shape(shape: int, pos: Vector2i) -> int:
	return shape << (pos.x+pos.y*8)

static func is_oob(piece: int, pos: Vector2i) -> bool: # true -> is out of bounds
	if pos == Vector2i.ZERO: return false
	var mask_8b: int = (0xFF << (8 - pos.x)) & 0xFF
	var mask = mask_8b * 0x0101010101010101
	#var mask: int = mask_8b | (mask_8b << 8) | (mask_8b << 16) | (mask_8b << 24) | (mask_8b << 32) | (mask_8b << 40) | (mask_8b << 48) | (mask_8b << 56)
	return (piece >> (64 - (pos.y*8+pos.x))) or (mask & piece)

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

static func complete(bitfield: int) -> int:
	return bitfield & (~get_complete(bitfield))

static func get_complete(bitfield: int) -> int: # Returns just the complete rows and columns
	var newfield: int = 0
	for x in 8:
		var mask = 0xFF << (x * 8);
		if (bitfield & mask) == mask:
			newfield |= mask
	for y in 8:
		var mask = 0x0101010101010101 << y;
		if (bitfield & mask) == mask:
			newfield |= mask
	return newfield

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
		for i in len(shapes_list): # TODO: binary search
			p -= shapes_list[i].probability
			if p <= 0:
				arr.append(shapes_list[i])
				shapes_list.remove_at(i)
				break
	return arr

static func popcount(x: int) -> int:
	x = x - ((x >> 1) & 0x5555555555555555)
	x = (x & 0x3333333333333333) + ((x >> 2) & 0x3333333333333333)
	x = (x + (x >> 4)) & 0x0F0F0F0F0F0F0F0F
	x = x + (x >> 8)
	x = x + (x >> 16)
	x = x + (x >> 32)
	return int(x & 0x7F)

static func find_usable_blocks(max_depth: int, current_depth: int, shapes: Array[int], n_shapes: int, bitfield: int) -> Array[int]:
	if current_depth == max_depth:
		return []
	var free = 64-popcount(bitfield)
	for i in n_shapes:
		var s = shapes[i+n_shapes*current_depth]
		if popcount(s) > free:
			continue
		for x in 8:
			for y in 8:
				var ss = shift_shape(s, Vector2i(x,y))
				if ss & bitfield: continue
				if is_oob(s, Vector2i(x,y)): continue
				var usable = find_usable_blocks(max_depth, current_depth+1, shapes, n_shapes, complete(ss | bitfield))
				if len(usable) != max_depth-current_depth-1: continue
				usable.append(s)
				return usable
	return []
