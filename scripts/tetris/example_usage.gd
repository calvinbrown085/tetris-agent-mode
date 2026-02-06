extends Node

## Example usage of the Tetris backend
## This demonstrates how to integrate the backend with a UI

var game_manager: TetrisGameManager


func _ready() -> void:
	# Create and add game manager
	game_manager = TetrisGameManager.new()
	add_child(game_manager)

	# Configure settings
	game_manager.starting_level = 1
	game_manager.enable_ghost_piece = true
	game_manager.enable_hold = true

	# Connect to all important signals
	connect_signals()

	# Start the game
	game_manager.start_new_game()


func connect_signals() -> void:
	var controller = game_manager.game_controller

	# Game state signals
	controller.game_started.connect(_on_game_started)
	controller.game_over.connect(_on_game_over)
	controller.game_paused.connect(_on_game_paused)
	controller.game_resumed.connect(_on_game_resumed)

	# Piece signals
	controller.piece_spawned.connect(_on_piece_spawned)
	controller.piece_moved.connect(_on_piece_moved)
	controller.piece_rotated.connect(_on_piece_rotated)
	controller.piece_locked.connect(_on_piece_locked)
	controller.piece_hard_dropped.connect(_on_piece_hard_dropped)

	# Board signals
	controller.board.lines_cleared.connect(_on_lines_cleared)
	controller.board.board_updated.connect(_on_board_updated)

	# Score signals
	controller.score_manager.score_changed.connect(_on_score_changed)
	controller.score_manager.level_changed.connect(_on_level_changed)
	controller.score_manager.lines_changed.connect(_on_lines_changed)

	# Spawner signals
	controller.piece_spawner.next_pieces_updated.connect(_on_next_pieces_updated)


# Game state callbacks
func _on_game_started() -> void:
	print("Game started!")


func _on_game_over() -> void:
	print("Game Over!")
	var stats = game_manager.get_score_manager().get_statistics()
	print("Final Stats: ", stats)


func _on_game_paused() -> void:
	print("Game paused")


func _on_game_resumed() -> void:
	print("Game resumed")


# Piece callbacks
func _on_piece_spawned(piece: Tetromino) -> void:
	print("Piece spawned: ", Tetromino.Type.keys()[piece.type])
	# Update UI to show new piece


func _on_piece_moved(piece: Tetromino) -> void:
	# Update piece position in UI
	pass


func _on_piece_rotated(piece: Tetromino) -> void:
	# Update piece rotation in UI
	print("Piece rotated to state: ", piece.rotation_state)


func _on_piece_locked(piece: Tetromino) -> void:
	print("Piece locked")
	# Play lock sound effect


func _on_piece_hard_dropped(distance: int) -> void:
	print("Hard drop distance: ", distance)
	# Play hard drop sound effect


# Board callbacks
func _on_lines_cleared(lines: int, is_tetris: bool) -> void:
	if is_tetris:
		print("TETRIS! 4 lines cleared!")
	else:
		print("Lines cleared: ", lines)
	# Play line clear animation and sound


func _on_board_updated() -> void:
	# Redraw the board
	render_game_board()


# Score callbacks
func _on_score_changed(new_score: int) -> void:
	print("Score: ", new_score)
	# Update score display


func _on_level_changed(new_level: int) -> void:
	print("Level up! Now level ", new_level)
	# Update level display, maybe play level up effect


func _on_lines_changed(new_lines: int) -> void:
	print("Total lines: ", new_lines)
	# Update lines display


# Spawner callbacks
func _on_next_pieces_updated(next_pieces: Array[Tetromino.Type]) -> void:
	print("Next pieces: ", next_pieces)
	# Update next piece preview display


# Example rendering function
func render_game_board() -> void:
	var board = game_manager.get_board()

	print("\n=== BOARD STATE ===")

	# In a real implementation, you would draw this with sprites/tiles
	# This is just a console visualization for testing

	for y in range(board.BOARD_HEIGHT):
		var line = ""
		for x in range(board.BOARD_WIDTH):
			var cell = board.get_cell(x, y)
			if cell != null:
				line += "█"  # Filled block
			else:
				line += "·"  # Empty cell
		print(line)

	# Show current piece
	var current_piece = game_manager.get_current_piece()
	if current_piece:
		print("Current piece: ", Tetromino.Type.keys()[current_piece.type])
		print("Position: ", current_piece.position)
		print("Rotation: ", current_piece.rotation_state)

	# Show ghost piece
	var ghost_blocks = game_manager.get_ghost_piece_blocks()
	if not ghost_blocks.is_empty():
		print("Ghost piece at: ", ghost_blocks)

	# Show held piece
	var held = game_manager.get_held_piece_type()
	if held != -1:
		print("Held piece: ", Tetromino.Type.keys()[held])

	# Show stats
	var score_mgr = game_manager.get_score_manager()
	print("Score: ", score_mgr.get_current_score())
	print("Level: ", score_mgr.get_current_level())
	print("Lines: ", score_mgr.get_lines_cleared())
	print("==================\n")


# Example: Programmatically control the game
func simulate_moves() -> void:
	# Move left
	game_manager.game_controller.move_piece_left()

	# Rotate
	game_manager.game_controller.rotate_piece_clockwise()

	# Hard drop
	game_manager.game_controller.hard_drop()


# Example: Access game data
func print_game_info() -> void:
	var board = game_manager.get_board()
	var score_manager = game_manager.get_score_manager()
	var piece_spawner = game_manager.get_piece_spawner()

	print("Board dimensions: ", board.BOARD_WIDTH, "x", board.BOARD_HEIGHT)
	print("Current score: ", score_manager.get_current_score())
	print("Current level: ", score_manager.get_current_level())
	print("Fall speed: ", score_manager.get_fall_speed(), " seconds")
	print("Next pieces: ", piece_spawner.get_next_pieces())
