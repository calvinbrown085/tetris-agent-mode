extends Node

# Tetromino shape definitions for UI rendering
# This is a reference for the UI system - backend logic should define its own shapes

const SHAPES = {
	"I": [
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],  # Horizontal
		[Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)],  # Vertical
		[Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)],  # Horizontal
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)],  # Vertical
	],
	"O": [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],  # No rotation needed
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)],
	],
	"T": [
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # T pointing up
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # T pointing right
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # T pointing down
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],  # T pointing left
	],
	"S": [
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)],  # Horizontal
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],  # Vertical
		[Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)],  # Horizontal
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)],  # Vertical
	],
	"Z": [
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],  # Horizontal
		[Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)],  # Vertical
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],  # Horizontal
		[Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)],  # Vertical
	],
	"J": [
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # J pointing right
		[Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)],  # J pointing down
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)],  # J pointing left
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)],  # J pointing up
	],
	"L": [
		[Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],  # L pointing right
		[Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],  # L pointing down
		[Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)],  # L pointing left
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)],  # L pointing up
	],
}

# Get the default rotation (0) for a piece type
static func get_default_shape(piece_type: String) -> Array:
	if SHAPES.has(piece_type):
		return SHAPES[piece_type][0]
	return []

# Get a specific rotation of a piece
static func get_shape_rotation(piece_type: String, rotation: int) -> Array:
	if SHAPES.has(piece_type):
		var rotations = SHAPES[piece_type]
		return rotations[rotation % rotations.size()]
	return []

# Get all rotations for a piece type
static func get_all_rotations(piece_type: String) -> Array:
	if SHAPES.has(piece_type):
		return SHAPES[piece_type]
	return []

# Get color for a piece type
static func get_piece_color(piece_type: String) -> Color:
	const COLORS = {
		"I": Color(0.0, 0.9, 0.9, 1.0),    # Cyan
		"O": Color(0.9, 0.9, 0.0, 1.0),    # Yellow
		"T": Color(0.6, 0.0, 0.9, 1.0),    # Purple
		"S": Color(0.0, 0.9, 0.0, 1.0),    # Green
		"Z": Color(0.9, 0.0, 0.0, 1.0),    # Red
		"J": Color(0.0, 0.0, 0.9, 1.0),    # Blue
		"L": Color(0.9, 0.5, 0.0, 1.0),    # Orange
	}
	return COLORS.get(piece_type, Color.WHITE)
