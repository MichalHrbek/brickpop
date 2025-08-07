class_name Score
extends Label

signal score_achieved(score: int)

var score := 0:
	set(value):
		score = value
		_update_text(value)

func _on_board_completed(completions: PackedByteArray, board_after: int):
	var field := PackedInt32Array(Array(completions))
	var sum := 0
	for i in field:
		sum += i**2
	var gain = sum**2
	
	if board_after == 0: # Cleared whole board
		gain *= 4
	
	score += gain	
	score_achieved.emit(score)

func _update_text(value):
	text = str(value)

func _ready():
	_update_text(score)
