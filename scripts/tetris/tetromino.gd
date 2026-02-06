class_name Tetromino
extends RefCounted

## Defines tetromino pieces (I, O, T, S, Z, J, L shapes) with rotation states

enum Type {
	I,
	O,
	T,
	S,
	Z,
	J,
	L
}

var type: Type
var rotation_state: int = 0
var position: Vector2i = Vector2i.ZERO
var color: Color

# Each tetromino has up to 4 rotation states
# Represented as arrays of Vector2i offsets from the anchor point
const SHAPES = {
	Type.I: [
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],  # Horizontal
		[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],  # Vertical
		[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],  # Horizontal
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]   # Vertical
	],
	Type.O: [
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],  # Square (all same)
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)],
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1)]
	],
	Type.T: [
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # T pointing up
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # T pointing right
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # T pointing down
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]   # T pointing left
	],
	Type.S: [
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],  # Horizontal
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],  # Vertical
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],  # Horizontal
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]   # Vertical
	],
	Type.Z: [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],  # Horizontal
		[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # Vertical
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],  # Horizontal
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]   # Vertical
	],
	Type.J: [
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # J pointing up
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],  # J pointing right
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],  # J pointing down
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]   # J pointing left
	],
	Type.L: [
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # L pointing up
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],  # L pointing right
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],  # L pointing down
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]   # L pointing left
	]
}

const COLORS = {
	Type.I: Color(0.0, 1.0, 1.0),    # Cyan
	Type.O: Color(1.0, 1.0, 0.0),    # Yellow
	Type.T: Color(0.5, 0.0, 0.5),    # Purple
	Type.S: Color(0.0, 1.0, 0.0),    # Green
	Type.Z: Color(1.0, 0.0, 0.0),    # Red
	Type.J: Color(0.0, 0.0, 1.0),    # Blue
	Type.L: Color(1.0, 0.5, 0.0)     # Orange
}

# SRS (Super Rotation System) wall kick data
# Each entry is [test1, test2, test3, test4] for each rotation
const WALL_KICK_DATA = {
	"JLSTZ": {
		"0->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		"1->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
		"1->2": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)],
		"2->1": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		"2->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
		"3->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		"3->0": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		"0->3": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)]
	},
	"I": {
		"0->1": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, -1), Vector2i(1, 2)],
		"1->0": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, 1), Vector2i(-1, -2)],
		"1->2": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, 2), Vector2i(2, -1)],
		"2->1": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, -2), Vector2i(-2, 1)],
		"2->3": [Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, 1), Vector2i(-1, -2)],
		"3->2": [Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, -1), Vector2i(1, 2)],
		"3->0": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, -2), Vector2i(-2, 1)],
		"0->3": [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, 2), Vector2i(2, -1)]
	},
	"O": []  # O piece doesn't rotate
}


func _init(piece_type: Type, spawn_position: Vector2i = Vector2i(3, 0)) -> void:
	type = piece_type
	position = spawn_position
	color = COLORS[type]
	rotation_state = 0


func get_blocks() -> Array[Vector2i]:
	var blocks: Array[Vector2i] = []
	var shape = SHAPES[type][rotation_state]

	for offset in shape:
		blocks.append(position + offset)

	return blocks


func rotate_clockwise() -> int:
	var old_rotation = rotation_state
	rotation_state = (rotation_state + 1) % 4
	return old_rotation


func rotate_counterclockwise() -> int:
	var old_rotation = rotation_state
	rotation_state = (rotation_state - 1 + 4) % 4
	return old_rotation


func set_rotation(new_rotation: int) -> void:
	rotation_state = new_rotation % 4


func get_wall_kick_tests(old_rotation: int, new_rotation: int) -> Array[Vector2i]:
	var tests: Array[Vector2i] = []

	if type == Type.O:
		return tests

	var kick_table_key = "I" if type == Type.I else "JLSTZ"
	var rotation_key = "%d->%d" % [old_rotation, new_rotation]

	if WALL_KICK_DATA[kick_table_key].has(rotation_key):
		var kick_data = WALL_KICK_DATA[kick_table_key][rotation_key]
		for kick in kick_data:
			tests.append(kick)

	return tests


func move(delta: Vector2i) -> void:
	position += delta


func duplicate_tetromino() -> Tetromino:
	var copy = Tetromino.new(type, position)
	copy.rotation_state = rotation_state
	return copy
