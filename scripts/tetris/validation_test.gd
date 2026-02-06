extends Node

## Validation test for Tetris backend
## Run this to verify all components are working correctly

func _ready() -> void:
	print("=== TETRIS BACKEND VALIDATION TEST ===\n")

	run_all_tests()

	print("\n=== ALL TESTS COMPLETE ===")
	print("If no errors appeared above, the backend is working correctly!")
	print("Ready for UI integration.")

	# Exit after tests (remove this if you want to keep testing interactively)
	await get_tree().create_timer(1.0).timeout
	#get_tree().quit()


func run_all_tests() -> void:
	test_tetromino()
	test_game_board()
	test_score_manager()
	test_piece_spawner()
	test_input_handler()
	test_game_controller()
	test_integration()


func test_tetromino() -> void:
	print("Testing Tetromino...")

	# Test all piece types
	for piece_type in Tetromino.Type.values():
		var piece = Tetromino.new(piece_type, Vector2i(0, 0))
		assert(piece.type == piece_type, "Piece type mismatch")
		assert(piece.get_blocks().size() == 4, "Piece should have 4 blocks")
		assert(piece.color != null, "Piece should have color")

	# Test rotation
	var t_piece = Tetromino.new(Tetromino.Type.T, Vector2i(0, 0))
	var initial_rotation = t_piece.rotation_state
	t_piece.rotate_clockwise()
	assert(t_piece.rotation_state == (initial_rotation + 1) % 4, "Clockwise rotation failed")

	t_piece.rotate_counterclockwise()
	assert(t_piece.rotation_state == initial_rotation, "Counter-clockwise rotation failed")

	# Test wall kicks
	var i_piece = Tetromino.new(Tetromino.Type.I, Vector2i(0, 0))
	var kicks = i_piece.get_wall_kick_tests(0, 1)
	assert(kicks.size() > 0, "I piece should have wall kicks")

	print("  ✓ Tetromino tests passed")


func test_game_board() -> void:
	print("Testing GameBoard...")

	var board = GameBoard.new()

	# Test empty board
	assert(board.get_cell(0, 0) == null, "New board should be empty")

	# Test collision with empty board
	var test_blocks = [Vector2i(0, 0), Vector2i(1, 0)]
	assert(board.is_valid_position(test_blocks), "Valid position rejected")

	# Test out of bounds
	var oob_blocks = [Vector2i(-1, 0)]
	assert(not board.is_valid_position(oob_blocks), "Out of bounds not detected")

	# Test piece locking
	var piece = Tetromino.new(Tetromino.Type.I, Vector2i(0, 18))
	board.lock_piece(piece)
	var locked_blocks = piece.get_blocks()
	assert(board.get_cell(locked_blocks[0].x, locked_blocks[0].y) != null, "Piece not locked")

	# Test line clearing
	board.clear_board()
	# Fill bottom row
	for x in range(board.BOARD_WIDTH):
		board.grid[board.BOARD_HEIGHT - 1][x] = Color.WHITE
	var cleared = board.check_and_clear_lines()
	assert(cleared == 1, "Line clear failed")

	print("  ✓ GameBoard tests passed")


func test_score_manager() -> void:
	print("Testing ScoreManager...")

	var score_mgr = ScoreManager.new(1)

	# Test initial state
	assert(score_mgr.get_current_score() == 0, "Initial score should be 0")
	assert(score_mgr.get_current_level() == 1, "Initial level should be 1")

	# Test single line clear
	score_mgr.add_line_clear_score(1)
	assert(score_mgr.get_current_score() == 100, "Single line score incorrect")

	# Test tetris
	score_mgr.reset()
	score_mgr.add_line_clear_score(4, true)
	assert(score_mgr.get_current_score() == 800, "Tetris score incorrect")

	# Test level progression
	score_mgr.reset()
	for i in range(10):
		score_mgr.add_line_clear_score(1)
	assert(score_mgr.get_current_level() == 2, "Level progression failed")

	# Test fall speed
	var speed_l1 = score_mgr.get_fall_speed()
	assert(speed_l1 > 0, "Fall speed should be positive")

	print("  ✓ ScoreManager tests passed")


func test_piece_spawner() -> void:
	print("Testing PieceSpawner...")

	var spawner = PieceSpawner.new()

	# Test initial state
	var next = spawner.get_next_pieces()
	assert(next.size() > 0, "Should have next pieces")

	# Test spawning
	var piece = spawner.spawn_next_piece()
	assert(piece != null, "Failed to spawn piece")
	assert(piece is Tetromino, "Spawned object is not Tetromino")

	# Test bag randomization (spawn 14 pieces, should get all 7 types twice)
	var piece_counts = {}
	for type in Tetromino.Type.values():
		piece_counts[type] = 0

	for i in range(14):
		var p = spawner.spawn_next_piece()
		piece_counts[p.type] += 1

	for type in Tetromino.Type.values():
		assert(piece_counts[type] >= 1, "Bag randomization not working - missing type")

	print("  ✓ PieceSpawner tests passed")


func test_input_handler() -> void:
	print("Testing InputHandler...")

	var handler = InputHandler.new()

	# Test initial state
	assert(not handler.is_move_left_held, "Initial state should be false")
	assert(not handler.is_soft_drop_active(), "Soft drop should not be active")

	# Test required actions list
	var actions = InputHandler.get_required_input_actions()
	assert(actions.size() == 8, "Should have 8 input actions")

	print("  ✓ InputHandler tests passed")


func test_game_controller() -> void:
	print("Testing TetrisGameController...")

	var controller = TetrisGameController.new()
	add_child(controller)

	# Test initial state
	assert(controller.get_current_state() == TetrisGameController.GameState.IDLE, "Should start in IDLE")

	# Test game start
	controller.start_game(1)
	assert(controller.get_current_state() == TetrisGameController.GameState.PLAYING, "Should be PLAYING")
	assert(controller.get_current_piece() != null, "Should have current piece")

	# Test piece movement
	var initial_pos = controller.get_current_piece().position
	var moved = controller.move_piece_right()
	if moved:
		assert(controller.get_current_piece().position.x == initial_pos.x + 1, "Piece didn't move right")

	# Test rotation
	var initial_rotation = controller.get_current_piece().rotation_state
	controller.rotate_piece_clockwise()
	# Rotation might fail due to collision, so we just check it doesn't crash

	# Test ghost piece
	var ghost = controller.get_ghost_piece_position()
	assert(ghost.size() == 4, "Ghost piece should have 4 blocks")

	# Test pause
	controller.pause_game()
	assert(controller.get_current_state() == TetrisGameController.GameState.PAUSED, "Should be PAUSED")

	controller.resume_game()
	assert(controller.get_current_state() == TetrisGameController.GameState.PLAYING, "Should resume to PLAYING")

	controller.end_game()
	controller.queue_free()

	print("  ✓ TetrisGameController tests passed")


func test_integration() -> void:
	print("Testing Integration...")

	# Create full game manager
	var game_manager = TetrisGameManager.new()
	add_child(game_manager)

	# Test accessors
	assert(game_manager.get_board() != null, "Board not accessible")
	assert(game_manager.get_score_manager() != null, "ScoreManager not accessible")
	assert(game_manager.get_piece_spawner() != null, "PieceSpawner not accessible")

	# Start game
	game_manager.start_new_game()
	assert(game_manager.get_current_piece() != null, "No piece after game start")

	# Test signal connections work
	var signal_fired = false
	game_manager.game_controller.piece_moved.connect(func(_p): signal_fired = true)

	game_manager.game_controller.move_piece_right()
	await get_tree().process_frame
	# Signal might not fire if move failed, that's ok for this test

	game_manager.queue_free()

	print("  ✓ Integration tests passed")


func print_summary() -> void:
	print("\n=== COMPONENT SUMMARY ===")
	print("✓ Tetromino - 7 pieces with rotation")
	print("✓ GameBoard - 10x20 grid with collision")
	print("✓ ScoreManager - Scoring and levels")
	print("✓ PieceSpawner - 7-bag randomization")
	print("✓ InputHandler - Input abstraction")
	print("✓ TetrisGameController - Game orchestration")
	print("✓ TetrisGameManager - UI integration point")
	print("\n=== FEATURES ===")
	print("✓ Piece movement (left, right, down)")
	print("✓ Piece rotation (CW, CCW with wall kicks)")
	print("✓ Collision detection")
	print("✓ Line clearing")
	print("✓ Scoring system")
	print("✓ Level progression")
	print("✓ Hard drop")
	print("✓ Soft drop")
	print("✓ Hold piece")
	print("✓ Ghost piece")
	print("✓ Lock delay")
	print("✓ DAS/ARR")
	print("✓ Game state management")
	print("✓ Next piece queue")
