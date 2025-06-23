extends Label

var score := 0:
	set(value):
		score = value
		text = str(value)

func _on_board_completed(field_bytes: PackedByteArray):
	var field := PackedInt32Array(Array(field_bytes))
	var sum := 0
	for i in field:
		sum += i**2
	score += sum**2

func _ready():
	score = 0
