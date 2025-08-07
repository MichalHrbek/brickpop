extends Node

@export var score: Score
@export var board: Board
@export var piece_spawner: PieceSpawner

func _ready():
	var game_save: GameSaveResource = null
	if FileAccess.file_exists(Constants.GAME_SAVE): game_save = load(Constants.GAME_SAVE)
	if game_save:
		# Loading board
		for y in 8:
			for x in 8:
				if game_save.board_bitfield & (1 << (y*8+x)):
					var brick: Node2D = Piece.brick_scene.instantiate()
					brick.modulate = game_save.board_colors.pop_front()
					board.try_fill_at(Vector2i(x,y), brick)
		# Loading pieces
		for i in len(game_save.piece_shapes):
			piece_spawner.spawn_piece(i,game_save.piece_shapes[i],game_save.piece_colors[i])
		# Loading score
		score.score = game_save.score
	else:
		piece_spawner.spawn_new_round.call_deferred()

func save_game():
	var data = GameSaveResource.new()
	data.score = score.score
	data.board_bitfield = board.gen_bitfield()
	for i in board.holes:
		if i.brick:
			data.board_colors.append(i.brick.modulate)
	
	for i in piece_spawner.pieces:
		data.piece_colors.append(i.color)
		data.piece_shapes.append(i.shape)

	var error := ResourceSaver.save(data, Constants.GAME_SAVE)
	if error:
		print("An error happened while saving game: ", error)

func delete_save():
	DirAccess.remove_absolute(Constants.GAME_SAVE)
