extends Label

var highscore: int = 0:
	set(value):
		highscore = value
		text = str(value)

const FILENAME = "user://highscore.bin"

func _ready():
	if not FileAccess.file_exists(FILENAME): return
	var save_file = FileAccess.open(FILENAME, FileAccess.READ)
	highscore = save_file.get_64()

func _on_score_score_achieved(score: int):
	if score > highscore:
		highscore = score
		var save_file = FileAccess.open(FILENAME, FileAccess.WRITE)
		save_file.store_64(highscore)
