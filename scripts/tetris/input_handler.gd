class_name InputHandler
extends RefCounted

## Handles input processing for Tetris game controls

signal move_left_pressed()
signal move_right_pressed()
signal move_down_pressed()
signal move_down_released()
signal rotate_cw_pressed()
signal rotate_ccw_pressed()
signal hard_drop_pressed()
signal hold_pressed()
signal pause_pressed()

# Input action names (these should be defined in project input map)
const ACTION_MOVE_LEFT = "tetris_move_left"
const ACTION_MOVE_RIGHT = "tetris_move_right"
const ACTION_MOVE_DOWN = "tetris_move_down"
const ACTION_ROTATE_CW = "tetris_rotate_cw"
const ACTION_ROTATE_CCW = "tetris_rotate_ccw"
const ACTION_HARD_DROP = "tetris_hard_drop"
const ACTION_HOLD = "tetris_hold"
const ACTION_PAUSE = "tetris_pause"

var is_move_left_held: bool = false
var is_move_right_held: bool = false
var is_move_down_held: bool = false


func process_input(event: InputEvent) -> void:
	if event.is_action_pressed(ACTION_MOVE_LEFT):
		is_move_left_held = true
		move_left_pressed.emit()

	elif event.is_action_released(ACTION_MOVE_LEFT):
		is_move_left_held = false

	elif event.is_action_pressed(ACTION_MOVE_RIGHT):
		is_move_right_held = true
		move_right_pressed.emit()

	elif event.is_action_released(ACTION_MOVE_RIGHT):
		is_move_right_held = false

	elif event.is_action_pressed(ACTION_MOVE_DOWN):
		is_move_down_held = true
		move_down_pressed.emit()

	elif event.is_action_released(ACTION_MOVE_DOWN):
		is_move_down_held = false
		move_down_released.emit()

	elif event.is_action_pressed(ACTION_ROTATE_CW):
		rotate_cw_pressed.emit()

	elif event.is_action_pressed(ACTION_ROTATE_CCW):
		rotate_ccw_pressed.emit()

	elif event.is_action_pressed(ACTION_HARD_DROP):
		hard_drop_pressed.emit()

	elif event.is_action_pressed(ACTION_HOLD):
		hold_pressed.emit()

	elif event.is_action_pressed(ACTION_PAUSE):
		pause_pressed.emit()


func get_movement_direction() -> Vector2i:
	var direction = Vector2i.ZERO

	if is_move_left_held:
		direction.x = -1
	elif is_move_right_held:
		direction.x = 1

	return direction


func is_soft_drop_active() -> bool:
	return is_move_down_held


func reset() -> void:
	is_move_left_held = false
	is_move_right_held = false
	is_move_down_held = false


static func get_required_input_actions() -> Array[Dictionary]:
	# Returns array of input actions that need to be configured in project settings
	return [
		{
			"name": ACTION_MOVE_LEFT,
			"default_key": KEY_LEFT,
			"description": "Move piece left"
		},
		{
			"name": ACTION_MOVE_RIGHT,
			"default_key": KEY_RIGHT,
			"description": "Move piece right"
		},
		{
			"name": ACTION_MOVE_DOWN,
			"default_key": KEY_DOWN,
			"description": "Soft drop (move piece down faster)"
		},
		{
			"name": ACTION_ROTATE_CW,
			"default_key": KEY_UP,
			"description": "Rotate piece clockwise"
		},
		{
			"name": ACTION_ROTATE_CCW,
			"default_key": KEY_Z,
			"description": "Rotate piece counter-clockwise"
		},
		{
			"name": ACTION_HARD_DROP,
			"default_key": KEY_SPACE,
			"description": "Hard drop (instantly drop piece)"
		},
		{
			"name": ACTION_HOLD,
			"default_key": KEY_C,
			"description": "Hold current piece"
		},
		{
			"name": ACTION_PAUSE,
			"default_key": KEY_ESCAPE,
			"description": "Pause game"
		}
	]
