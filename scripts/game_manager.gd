extends Control

# UI node references
@onready var game_board = $MarginContainer/HBoxContainer/GameBoardContainer/BoardPanel/GameBoard
@onready var next_piece_preview = $MarginContainer/HBoxContainer/RightPanel/NextPieceContainer/VBox/Padding/Content/NextPiecePreview
@onready var score_value = $MarginContainer/HBoxContainer/LeftPanel/ScoreContainer/VBox/Padding/Content/ScoreValue
@onready var level_value = $MarginContainer/HBoxContainer/LeftPanel/LevelContainer/VBox/Padding/Content/LevelValue
@onready var lines_value = $MarginContainer/HBoxContainer/LeftPanel/LinesContainer/VBox/Padding/Content/LinesValue
@onready var game_ui = $GameUI

# Backend game manager
var backend_manager: TetrisGameManager

# Game state
var is_game_active = false
var is_paused = false
var current_score = 0
var current_level = 1
var current_lines = 0

func _ready():
	# Validate UI nodes exist
	if not game_board or not next_piece_preview or not game_ui:
		push_error("Required UI nodes not found! Check scene structure.")
		return

	# Initialize backend
	backend_manager = TetrisGameManager.new()
	backend_manager.starting_level = 1
	backend_manager.enable_ghost_piece = true
	backend_manager.enable_hold = false  # Can enable later
	add_child(backend_manager)

	# Wait for backend to be ready
	await get_tree().process_frame

	# Validate backend initialized
	if not backend_manager.game_controller:
		push_error("Backend game_controller failed to initialize!")
		return

	# Connect backend signals to UI update methods
	_connect_backend_signals()

	# Start the game
	backend_manager.start_new_game()
	is_game_active = true

func _connect_backend_signals():
	var controller = backend_manager.game_controller

	# Game state signals
	controller.game_started.connect(_on_backend_game_started)
	controller.game_paused.connect(_on_backend_game_paused)
	controller.game_resumed.connect(_on_backend_game_resumed)
	controller.game_over.connect(_on_backend_game_over)

	# Piece signals
	controller.piece_spawned.connect(_on_backend_piece_spawned)
	controller.piece_moved.connect(_on_backend_piece_moved)
	controller.piece_rotated.connect(_on_backend_piece_rotated)
	controller.piece_locked.connect(_on_backend_piece_locked)
	controller.piece_hard_dropped.connect(_on_backend_piece_hard_dropped)

	# Board signals
	controller.board.lines_cleared.connect(_on_backend_lines_cleared)
	controller.board.board_updated.connect(_on_backend_board_updated)

	# Score signals
	controller.score_manager.score_changed.connect(_on_backend_score_changed)
	controller.score_manager.level_changed.connect(_on_backend_level_changed)
	controller.score_manager.lines_changed.connect(_on_backend_lines_changed)

	# Spawner signals
	controller.piece_spawner.next_pieces_updated.connect(_on_backend_next_pieces_updated)

func _input(event):
	if not is_game_active:
		return

	# Pause/Resume (handle both ui_pause and tetris_pause)
	if event.is_action_pressed("ui_pause") or event.is_action_pressed("tetris_pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
		return

	# Don't process other inputs if paused
	if is_paused:
		return

	# Let backend handle all game input
	# The backend's input handler will process movement, rotation, etc.

func toggle_pause():
	if is_paused:
		resume_game()
	else:
		pause_game()

func pause_game():
	if not is_game_active or is_paused:
		return

	is_paused = true
	game_ui.show_pause()
	backend_manager.pause_game()

func resume_game():
	if not is_paused:
		return

	is_paused = false
	game_ui.hide_all_screens()
	backend_manager.resume_game()

func end_game():
	is_game_active = false
	game_ui.show_game_over(current_score)

# UI Update Methods (called by backend game logic)

func update_score(score: int):
	current_score = score
	score_value.text = str(score)

func update_level(level: int):
	current_level = level
	level_value.text = str(level)

func update_lines(lines: int):
	current_lines = lines
	lines_value.text = str(lines)

func update_current_piece(piece_data):
	game_board.set_current_piece(piece_data)

func update_ghost_piece(position: Vector2i):
	game_board.update_ghost_piece(position)

func update_next_piece(piece_type: String, blocks: Array):
	next_piece_preview.set_next_piece(piece_type, blocks)

func place_piece(piece_data):
	game_board.place_piece(piece_data)

func clear_lines_visual(line_numbers: Array):
	game_board.clear_lines(line_numbers)

func check_completed_lines() -> Array:
	return game_board.check_lines()

func is_position_valid(piece_data) -> bool:
	return game_board.is_position_valid(piece_data)

func get_board_state() -> Array:
	return game_board.get_grid_state()

func reset_game():
	is_game_active = true
	is_paused = false
	current_score = 0
	current_level = 1
	current_lines = 0

	update_score(0)
	update_level(1)
	update_lines(0)

	game_board.reset_board()
	next_piece_preview.clear_preview()
	game_ui.hide_all_screens()

	# Restart backend game
	backend_manager.start_new_game()

# Backend Signal Handlers

func _on_backend_game_started():
	pass  # Game already started

func _on_backend_game_paused():
	pass  # UI already handles pause state

func _on_backend_game_resumed():
	pass  # UI already handles resume state

func _on_backend_game_over():
	end_game()

func _on_backend_piece_spawned(piece: Tetromino):
	# Update current piece on board
	var piece_data = _convert_tetromino_to_ui_data(piece)
	game_board.set_current_piece(piece_data)

	# Update ghost piece
	_update_ghost_piece(piece)

func _on_backend_piece_moved(piece: Tetromino):
	# Update current piece position
	var piece_data = _convert_tetromino_to_ui_data(piece)
	game_board.set_current_piece(piece_data)

	# Update ghost piece
	_update_ghost_piece(piece)

func _on_backend_piece_rotated(piece: Tetromino):
	# Update current piece rotation
	var piece_data = _convert_tetromino_to_ui_data(piece)
	game_board.set_current_piece(piece_data)

	# Update ghost piece
	_update_ghost_piece(piece)

func _on_backend_piece_locked(piece: Tetromino):
	# Place piece on board
	var piece_data = _convert_tetromino_to_ui_data(piece)
	game_board.place_piece(piece_data)

func _on_backend_piece_hard_dropped(distance: int):
	pass  # Visual feedback can be added later

func _on_backend_lines_cleared(lines: int, is_tetris: bool):
	# Note: Backend has already cleared the lines from its board
	# We just need to sync the UI board state
	# For now, we'll do a full sync on next board update
	pass

func _on_backend_board_updated():
	# Full board redraw
	_sync_board_state()

func _on_backend_score_changed(new_score: int):
	update_score(new_score)

func _on_backend_level_changed(new_level: int):
	update_level(new_level)

func _on_backend_lines_changed(new_lines: int):
	update_lines(new_lines)

func _on_backend_next_pieces_updated(next_pieces: Array):
	# Update next piece preview with first piece in queue
	if next_pieces.size() > 0:
		var next_type = next_pieces[0]
		var type_string = Tetromino.Type.keys()[next_type]
		var temp_piece = Tetromino.new(next_type, Vector2i.ZERO)
		var blocks = []
		for block in temp_piece.get_blocks():
			blocks.append(block)
		next_piece_preview.set_next_piece(type_string, blocks)

func _update_ghost_piece(piece: Tetromino):
	# Calculate where the piece would land
	var drop_distance = backend_manager.game_controller.board.get_drop_distance(piece)
	var ghost_position = Vector2i(piece.position.x, piece.position.y + drop_distance)
	game_board.update_ghost_piece(ghost_position)


func _convert_tetromino_to_ui_data(piece: Tetromino) -> Dictionary:
	var type_string = Tetromino.Type.keys()[piece.type]
	var blocks = []

	# Get blocks relative to position
	var shape = Tetromino.SHAPES[piece.type][piece.rotation_state]
	for offset in shape:
		blocks.append(offset)

	return {
		"type": type_string,
		"position": piece.position,
		"blocks": blocks
	}

func _sync_board_state():
	# Sync the backend board state to the UI board
	var board = backend_manager.get_board()
	for y in range(board.BOARD_HEIGHT):
		for x in range(board.BOARD_WIDTH):
			var color = board.get_cell(x, y)
			if color != null:
				# Get the type string from color
				var type_string = _get_type_from_color(color)
				if y >= 0 and y < game_board.GRID_HEIGHT and x >= 0 and x < game_board.GRID_WIDTH:
					game_board.grid[y][x] = type_string
			else:
				if y >= 0 and y < game_board.GRID_HEIGHT and x >= 0 and x < game_board.GRID_WIDTH:
					game_board.grid[y][x] = ""
	game_board.queue_redraw()

func _get_type_from_color(color: Color) -> String:
	# Match color to tetromino type
	for type_key in Tetromino.COLORS.keys():
		if Tetromino.COLORS[type_key].is_equal_approx(color):
			return Tetromino.Type.keys()[type_key]
	return ""

# UI Signal Handlers

func _on_game_ui_restart_pressed():
	reset_game()

func _on_game_ui_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_game_ui_resume_pressed():
	resume_game()
