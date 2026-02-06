class_name TetrisGameManager
extends Node

## Top-level game manager that integrates all Tetris components and handles input
## This node should be added to the scene tree and acts as the main interface

# Expose the game controller
var game_controller: TetrisGameController

# Settings
@export var starting_level: int = 1
@export var enable_ghost_piece: bool = true
@export var enable_hold: bool = true


func _ready() -> void:
	# Initialize game controller
	game_controller = TetrisGameController.new()
	add_child(game_controller)

	# Connect input signals
	game_controller.input_handler.move_left_pressed.connect(_on_move_left_pressed)
	game_controller.input_handler.move_right_pressed.connect(_on_move_right_pressed)
	game_controller.input_handler.move_down_pressed.connect(_on_move_down_pressed)
	game_controller.input_handler.move_down_released.connect(_on_move_down_released)
	game_controller.input_handler.rotate_cw_pressed.connect(_on_rotate_cw_pressed)
	game_controller.input_handler.rotate_ccw_pressed.connect(_on_rotate_ccw_pressed)
	game_controller.input_handler.hard_drop_pressed.connect(_on_hard_drop_pressed)
	game_controller.input_handler.hold_pressed.connect(_on_hold_pressed)
	game_controller.input_handler.pause_pressed.connect(_on_pause_pressed)

	# Enable process for DAS handling
	set_process(true)


func _process(_delta: float) -> void:
	if not game_controller:
		return

	# Handle DAS (Delayed Auto Shift) based on held keys
	var direction = game_controller.input_handler.get_movement_direction()

	if direction != Vector2i.ZERO:
		# Key is held, start DAS if not already active
		if not game_controller.is_das_charging:
			game_controller.start_das(direction)
	else:
		# No keys held, stop DAS
		if game_controller.is_das_charging:
			game_controller.stop_das()


func _input(event: InputEvent) -> void:
	if game_controller and game_controller.input_handler:
		game_controller.input_handler.process_input(event)


func start_new_game() -> void:
	game_controller.start_game(starting_level)


func pause_game() -> void:
	game_controller.pause_game()


func resume_game() -> void:
	game_controller.resume_game()


func _on_move_left_pressed() -> void:
	# Just move once on initial press, DAS handled in _process
	game_controller.move_piece_left()


func _on_move_right_pressed() -> void:
	# Just move once on initial press, DAS handled in _process
	game_controller.move_piece_right()


func _on_move_down_pressed() -> void:
	# Enable soft drop mode (faster falling)
	game_controller.start_soft_drop()


func _on_move_down_released() -> void:
	# Disable soft drop mode
	game_controller.stop_soft_drop()


func _on_rotate_cw_pressed() -> void:
	game_controller.rotate_piece_clockwise()


func _on_rotate_ccw_pressed() -> void:
	game_controller.rotate_piece_counterclockwise()


func _on_hard_drop_pressed() -> void:
	game_controller.hard_drop()


func _on_hold_pressed() -> void:
	if enable_hold:
		game_controller.hold_piece()


func _on_pause_pressed() -> void:
	if game_controller.current_state == TetrisGameController.GameState.PLAYING:
		pause_game()
	elif game_controller.current_state == TetrisGameController.GameState.PAUSED:
		resume_game()


# Accessor methods for UI
func get_board() -> GameBoard:
	return game_controller.board


func get_score_manager() -> ScoreManager:
	return game_controller.score_manager


func get_piece_spawner() -> PieceSpawner:
	return game_controller.piece_spawner


func get_current_piece() -> Tetromino:
	return game_controller.get_current_piece()


func get_held_piece_type() -> int:
	return game_controller.get_held_piece_type()


func get_ghost_piece_blocks() -> Array[Vector2i]:
	if enable_ghost_piece:
		return game_controller.get_ghost_piece_position()
	return []


func get_game_state() -> TetrisGameController.GameState:
	return game_controller.get_current_state()
