extends Node

# UI Test Demo Script
# This demonstrates how to use the UI system without full game logic
# Attach this to the Game scene to see UI in action

@onready var game_manager = get_parent()

var demo_score = 0
var demo_level = 1
var demo_lines = 0
var demo_piece_index = 0

var piece_types = ["I", "O", "T", "S", "Z", "J", "L"]
var current_demo_piece = null

func _ready():
	if not game_manager:
		print("Error: ui_test_demo.gd must be a child of the Game scene")
		return

	# Connect to UI signals
	game_manager.game_started.connect(_on_game_started)
	game_manager.move_left_requested.connect(_on_move_left)
	game_manager.move_right_requested.connect(_on_move_right)
	game_manager.rotate_requested.connect(_on_rotate)
	game_manager.soft_drop_requested.connect(_on_soft_drop)
	game_manager.hard_drop_requested.connect(_on_hard_drop)

	print("UI Test Demo Active!")
	print("Controls:")
	print("  Arrow Keys: Move and rotate")
	print("  Space: Hard drop (adds score)")
	print("  P: Pause")

func _on_game_started():
	print("Game started!")
	_spawn_demo_piece()
	_update_next_piece()

func _spawn_demo_piece():
	var piece_type = piece_types[demo_piece_index % piece_types.size()]
	demo_piece_index += 1

	# Create a simple piece in the middle
	current_demo_piece = {
		"type": piece_type,
		"position": Vector2i(4, 2),
		"blocks": _get_demo_blocks(piece_type)
	}

	game_manager.update_current_piece(current_demo_piece)
	_update_ghost_piece()

func _get_demo_blocks(piece_type: String) -> Array:
	# Simple block patterns for demo
	match piece_type:
		"I": return [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)]
		"O": return [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
		"T": return [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
		"S": return [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
		"Z": return [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
		"J": return [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
		"L": return [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
		_: return [Vector2i(0, 0)]

func _update_next_piece():
	var next_type = piece_types[(demo_piece_index) % piece_types.size()]
	game_manager.update_next_piece(next_type, _get_demo_blocks(next_type))

func _update_ghost_piece():
	if not current_demo_piece:
		return

	# Simple ghost: just show it 10 rows below current
	var ghost_pos = Vector2i(current_demo_piece.position.x, current_demo_piece.position.y + 10)
	game_manager.update_ghost_piece(ghost_pos)

func _on_move_left():
	if not current_demo_piece:
		return

	current_demo_piece.position.x = max(0, current_demo_piece.position.x - 1)
	game_manager.update_current_piece(current_demo_piece)
	_update_ghost_piece()
	print("Moved left to x:", current_demo_piece.position.x)

func _on_move_right():
	if not current_demo_piece:
		return

	current_demo_piece.position.x = min(9, current_demo_piece.position.x + 1)
	game_manager.update_current_piece(current_demo_piece)
	_update_ghost_piece()
	print("Moved right to x:", current_demo_piece.position.x)

func _on_rotate():
	print("Rotate requested (not implemented in demo)")
	# In real game, this would rotate the piece

func _on_soft_drop():
	if not current_demo_piece:
		return

	current_demo_piece.position.y = min(19, current_demo_piece.position.y + 1)
	game_manager.update_current_piece(current_demo_piece)
	_update_ghost_piece()
	print("Soft drop to y:", current_demo_piece.position.y)

func _on_hard_drop():
	if not current_demo_piece:
		return

	print("Hard drop!")

	# Place the piece
	game_manager.place_piece(current_demo_piece)

	# Add score
	demo_score += 100
	game_manager.update_score(demo_score)

	# Every 5 drops, increase level and clear some lines
	if demo_score % 500 == 0:
		demo_level += 1
		game_manager.update_level(demo_level)

		# Demo line clear
		var lines_to_clear = [18, 19]
		game_manager.clear_lines_visual(lines_to_clear)

		demo_lines += 2
		game_manager.update_lines(demo_lines)

		print("Level up! Lines cleared!")

	# Spawn new piece
	await get_tree().create_timer(0.3).timeout  # Wait a bit
	_spawn_demo_piece()
	_update_next_piece()
