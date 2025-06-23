class_name BoardUtils

static func place(field: PackedByteArray, shape: Array[Vector2i], origin: Vector2i):# -> PackedByteArray | null
	var arr := PackedByteArray(field)
	for i in shape:
		var pos := origin + i
		if pos.x < 0 or pos.x >= 8: return null
		if pos.y < 0 or pos.y >= 8: return null
		if arr[pos.x+pos.y*8]: return null
		arr[pos.x+pos.y*8] = 1
	return arr

static func check_completion(field: PackedByteArray) -> PackedByteArray:
	var to_destroy = PackedByteArray()
	to_destroy.resize(64)
	for y in 8:
		var complete = true
		for x in 8:
			if not field[y*8+x]:
				complete = false
				break
		if complete:
			for x in 8:
				to_destroy[y*8+x] += 1
	
	for x in 8:
		var complete = true
		for y in 8:
			if not field[y*8+x]:
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
