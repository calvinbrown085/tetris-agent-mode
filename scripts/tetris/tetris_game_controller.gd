class_name TetrisGameController
extends Node

## Main game controller that orchestrates all Tetris game logic

# Game state signals
signal game_started()
signal game_paused()
signal game_resumed()
signal game_over()
signal piece_spawned(piece: Tetromino)
signal piece_moved(piece: Tetromino)
signal piece_rotated(piece: Tetromino)
signal piece_locked(piece: Tetromino)
signal piece_hard_dropped(distance: int)

# Game state enum
enum GameState {
	IDLE,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# Core game components
var board: GameBoard
var score_manager: ScoreManager
var piece_spawner: PieceSpawner
var input_handler: InputHandler

# Current game state
var current_state: GameState = GameState.IDLE
var current_piece: Tetromino = null
var held_piece: Tetromino.Type = -1
var can_hold: bool = true

# Timing variables
var fall_timer: float = 0.0
var lock_delay_timer: float = 0.0
var lock_delay_max: float = 0.5  # 0.5 second lock delay
var is_lock_delay_active: bool = false
var das_timer: float = 0.0  # Delayed Auto Shift
var das_delay: float = 0.133  # DAS delay in seconds
var arr_timer: float = 0.0  # Auto Repeat Rate
var arr_rate: float = 0.033  # ARR rate in seconds

# Movement state
var is_das_charging: bool = false
var das_direction: Vector2i = Vector2i.ZERO
var is_soft_drop_active: bool = false
var soft_drop_timer: float = 0.0
var soft_drop_rate: float = 0.05  # Move down every 0.05 seconds during soft drop


func _init() -> void:
	board = GameBoard.new()
	score_manager = ScoreManager.new()
	piece_spawner = PieceSpawner.new()
	input_handler = InputHandler.new()

	# Connect signals
	board.lines_cleared.connect(_on_lines_cleared)
	score_manager.level_changed.connect(_on_level_changed)


func _ready() -> void:
	set_process(false)


func start_game(starting_level: int = 1) -> void:
	# Reset all game state
	board.clear_board()
	score_manager.reset()
	score_manager.level = starting_level  # Set starting level
	piece_spawner.reset()
	current_piece = null
	held_piece = -1
	can_hold = true
	current_state = GameState.PLAYING
	fall_timer = 0.0

	# Spawn first piece
	spawn_piece()

	set_process(true)
	game_started.emit()


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		set_process(false)
		game_paused.emit()


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		set_process(true)
		game_resumed.emit()


func end_game() -> void:
	current_state = GameState.GAME_OVER
	set_process(false)
	game_over.emit()


func _process(delta: float) -> void:
	if current_state != GameState.PLAYING or current_piece == null:
		return

	# Handle soft drop (faster falling when down key held)
	if is_soft_drop_active:
		soft_drop_timer += delta
		if soft_drop_timer >= soft_drop_rate:
			soft_drop_timer = 0.0
			if move_piece_down():
				score_manager.add_soft_drop_score(1)  # Award 1 point per cell
			else:
				# Hit bottom during soft drop, activate lock delay
				if not is_lock_delay_active:
					is_lock_delay_active = true
					lock_delay_timer = 0.0
	else:
		# Handle normal automatic falling
		fall_timer += delta
		var fall_speed = score_manager.get_fall_speed()

		if fall_timer >= fall_speed:
			fall_timer = 0.0
			if not move_piece_down():
				# Piece can't move down, activate lock delay
				if not is_lock_delay_active:
					is_lock_delay_active = true
					lock_delay_timer = 0.0

	# Handle lock delay
	if is_lock_delay_active:
		lock_delay_timer += delta
		if lock_delay_timer >= lock_delay_max:
			lock_current_piece()

	# Handle DAS (Delayed Auto Shift)
	if is_das_charging and das_direction != Vector2i.ZERO:
		das_timer += delta
		if das_timer >= das_delay:
			# Start auto-repeat
			arr_timer += delta
			if arr_timer >= arr_rate:
				arr_timer = 0.0
				move_piece(das_direction)


func spawn_piece() -> void:
	current_piece = piece_spawner.spawn_next_piece()
	can_hold = true
	is_lock_delay_active = false
	lock_delay_timer = 0.0

	# Check if piece can spawn
	if board.is_collision(current_piece.get_blocks()):
		end_game()
		return

	score_manager.increment_piece_count()
	piece_spawned.emit(current_piece)


func move_piece(direction: Vector2i) -> bool:
	if current_piece == null:
		return false

	var old_position = current_piece.position
	current_piece.move(direction)

	if board.is_collision(current_piece.get_blocks()):
		current_piece.position = old_position
		return false

	# Reset lock delay if piece moved successfully
	if direction.y == 0:  # Horizontal movement
		if is_lock_delay_active:
			lock_delay_timer = 0.0

	piece_moved.emit(current_piece)
	return true


func move_piece_down() -> bool:
	return move_piece(Vector2i(0, 1))


func move_piece_left() -> bool:
	return move_piece(Vector2i(-1, 0))


func move_piece_right() -> bool:
	return move_piece(Vector2i(1, 0))


func rotate_piece_clockwise() -> bool:
	if current_piece == null or current_piece.type == Tetromino.Type.O:
		return false

	var old_rotation = current_piece.rotate_clockwise()

	# Try basic rotation
	if not board.is_collision(current_piece.get_blocks()):
		if is_lock_delay_active:
			lock_delay_timer = 0.0  # Reset lock delay on successful rotation
		piece_rotated.emit(current_piece)
		return true

	# Try wall kicks
	var kick_tests = current_piece.get_wall_kick_tests(old_rotation, current_piece.rotation_state)
	for kick in kick_tests:
		current_piece.position += kick
		if not board.is_collision(current_piece.get_blocks()):
			if is_lock_delay_active:
				lock_delay_timer = 0.0
			piece_rotated.emit(current_piece)
			return true
		current_piece.position -= kick

	# All kicks failed, revert rotation
	current_piece.set_rotation(old_rotation)
	return false


func rotate_piece_counterclockwise() -> bool:
	if current_piece == null or current_piece.type == Tetromino.Type.O:
		return false

	var old_rotation = current_piece.rotate_counterclockwise()

	# Try basic rotation
	if not board.is_collision(current_piece.get_blocks()):
		if is_lock_delay_active:
			lock_delay_timer = 0.0
		piece_rotated.emit(current_piece)
		return true

	# Try wall kicks
	var kick_tests = current_piece.get_wall_kick_tests(old_rotation, current_piece.rotation_state)
	for kick in kick_tests:
		current_piece.position += kick
		if not board.is_collision(current_piece.get_blocks()):
			if is_lock_delay_active:
				lock_delay_timer = 0.0
			piece_rotated.emit(current_piece)
			return true
		current_piece.position -= kick

	# All kicks failed, revert rotation
	current_piece.set_rotation(old_rotation)
	return false


func hard_drop() -> void:
	if current_piece == null:
		return

	var drop_distance = board.get_drop_distance(current_piece)
	current_piece.move(Vector2i(0, drop_distance))

	score_manager.add_hard_drop_score(drop_distance)
	piece_hard_dropped.emit(drop_distance)

	lock_current_piece()


func soft_drop() -> bool:
	if move_piece_down():
		score_manager.add_soft_drop_score(1)
		return true
	return false


func hold_piece() -> void:
	if current_piece == null or not can_hold:
		return

	var current_type = current_piece.type

	if held_piece == -1:
		# First hold
		held_piece = current_type
		spawn_piece()
	else:
		# Swap with held piece
		var temp = held_piece
		held_piece = current_type
		current_piece = Tetromino.new(temp, piece_spawner.SPAWN_POSITION)

		# Check if swapped piece can spawn
		if board.is_collision(current_piece.get_blocks()):
			end_game()
			return

		piece_spawned.emit(current_piece)

	can_hold = false
	is_lock_delay_active = false
	lock_delay_timer = 0.0


func lock_current_piece() -> void:
	if current_piece == null:
		return

	board.lock_piece(current_piece)
	piece_locked.emit(current_piece)

	# Check for line clears
	var lines = board.check_and_clear_lines()

	# Reset timers
	is_lock_delay_active = false
	lock_delay_timer = 0.0
	fall_timer = 0.0

	# Spawn next piece
	spawn_piece()


func start_das(direction: Vector2i) -> void:
	is_das_charging = true
	das_direction = direction
	das_timer = 0.0
	arr_timer = 0.0


func stop_das() -> void:
	is_das_charging = false
	das_direction = Vector2i.ZERO
	das_timer = 0.0
	arr_timer = 0.0


func start_soft_drop() -> void:
	is_soft_drop_active = true
	soft_drop_timer = 0.0


func stop_soft_drop() -> void:
	is_soft_drop_active = false
	soft_drop_timer = 0.0


func _on_lines_cleared(lines: int, is_tetris: bool) -> void:
	score_manager.add_line_clear_score(lines, is_tetris)


func _on_level_changed(new_level: int) -> void:
	# Speed will automatically increase through score_manager.get_fall_speed()
	pass


func get_current_state() -> GameState:
	return current_state


func get_current_piece() -> Tetromino:
	return current_piece


func get_held_piece_type() -> int:
	return held_piece


func get_ghost_piece_position() -> Array[Vector2i]:
	if current_piece == null:
		return []

	var ghost = current_piece.duplicate_tetromino()
	var drop_distance = board.get_drop_distance(current_piece)
	ghost.move(Vector2i(0, drop_distance))

	return ghost.get_blocks()
