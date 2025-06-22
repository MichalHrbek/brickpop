extends Label

var score := 0:
	set(value):
		score = value
		text = str(value)

func _on_board_completed(field):
	var sum := 0
	for i in field:
		sum += i**2
	score += sum**2

func _ready():
	score = 0
