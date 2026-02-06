extends Control

const CELL_SIZE = 20

# Tetromino colors (same as game board)
const TETROMINO_COLORS = {
	"I": Color(0.0, 0.9, 0.9, 1.0),    # Cyan
	"O": Color(0.9, 0.9, 0.0, 1.0),    # Yellow
	"T": Color(0.6, 0.0, 0.9, 1.0),    # Purple
	"S": Color(0.0, 0.9, 0.0, 1.0),    # Green
	"Z": Color(0.9, 0.0, 0.0, 1.0),    # Red
	"J": Color(0.0, 0.0, 0.9, 1.0),    # Blue
	"L": Color(0.9, 0.5, 0.0, 1.0),    # Orange
}

const BACKGROUND_COLOR = Color(0.1, 0.1, 0.15, 1.0)

var next_piece_type = ""
var next_piece_blocks = []

func _ready():
	custom_minimum_size = Vector2(120, 120)

func _draw():
	# Draw background
	draw_rect(Rect2(0, 0, size.x, size.y), BACKGROUND_COLOR)

	# Draw next piece if available
	if next_piece_type != "" and next_piece_blocks.size() > 0:
		_draw_next_piece()

func _draw_next_piece():
	var color = TETROMINO_COLORS.get(next_piece_type, Color.WHITE)

	# Calculate bounds to center the piece
	var min_x = 999
	var max_x = -999
	var min_y = 999
	var max_y = -999

	for block in next_piece_blocks:
		min_x = min(min_x, block.x)
		max_x = max(max_x, block.x)
		min_y = min(min_y, block.y)
		max_y = max(max_y, block.y)

	var piece_width = (max_x - min_x + 1) * CELL_SIZE
	var piece_height = (max_y - min_y + 1) * CELL_SIZE

	# Center offset
	var offset_x = (size.x - piece_width) / 2 - min_x * CELL_SIZE
	var offset_y = (size.y - piece_height) / 2 - min_y * CELL_SIZE

	# Draw each block
	for block in next_piece_blocks:
		var x = offset_x + block.x * CELL_SIZE
		var y = offset_y + block.y * CELL_SIZE
		_draw_block(Vector2(x, y), color)

func _draw_block(position: Vector2, color: Color):
	var rect = Rect2(position.x + 1, position.y + 1, CELL_SIZE - 2, CELL_SIZE - 2)

	# Draw solid block
	draw_rect(rect, color)

	# Highlight (top-left)
	var highlight_color = Color(color.r + 0.2, color.g + 0.2, color.b + 0.2, color.a)
	draw_line(Vector2(position.x + 2, position.y + 2),
		Vector2(position.x + CELL_SIZE - 2, position.y + 2), highlight_color, 2.0)
	draw_line(Vector2(position.x + 2, position.y + 2),
		Vector2(position.x + 2, position.y + CELL_SIZE - 2), highlight_color, 2.0)

	# Shadow (bottom-right)
	var shadow_color = Color(color.r - 0.2, color.g - 0.2, color.b - 0.2, color.a)
	draw_line(Vector2(position.x + CELL_SIZE - 2, position.y + 2),
		Vector2(position.x + CELL_SIZE - 2, position.y + CELL_SIZE - 2), shadow_color, 2.0)
	draw_line(Vector2(position.x + 2, position.y + CELL_SIZE - 2),
		Vector2(position.x + CELL_SIZE - 2, position.y + CELL_SIZE - 2), shadow_color, 2.0)

func set_next_piece(piece_type: String, blocks: Array):
	next_piece_type = piece_type
	next_piece_blocks = blocks
	queue_redraw()

func clear_preview():
	next_piece_type = ""
	next_piece_blocks = []
	queue_redraw()
