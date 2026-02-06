extends Control

signal line_cleared(line_number)
signal lines_cleared(lines_count)

# Grid dimensions
const GRID_WIDTH = 10
const GRID_HEIGHT = 20
const CELL_SIZE = 30

# Tetromino colors (7 classic colors)
const TETROMINO_COLORS = {
	"I": Color(0.0, 0.9, 0.9, 1.0),    # Cyan
	"O": Color(0.9, 0.9, 0.0, 1.0),    # Yellow
	"T": Color(0.6, 0.0, 0.9, 1.0),    # Purple
	"S": Color(0.0, 0.9, 0.0, 1.0),    # Green
	"Z": Color(0.9, 0.0, 0.0, 1.0),    # Red
	"J": Color(0.0, 0.0, 0.9, 1.0),    # Blue
	"L": Color(0.9, 0.5, 0.0, 1.0),    # Orange
}

const EMPTY_COLOR = Color(0.15, 0.15, 0.2, 1.0)
const GRID_LINE_COLOR = Color(0.2, 0.2, 0.25, 1.0)
const GHOST_PIECE_ALPHA = 0.3

# Game board state
var grid: Array = []
var current_piece = null
var ghost_piece_position = Vector2i.ZERO

# Animation state
var clearing_lines: Array = []
var clear_animation_progress = 0.0
var is_animating = false

func _ready():
	custom_minimum_size = Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	_initialize_grid()

func _initialize_grid():
	grid.clear()
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append("")
		grid.append(row)

func _draw():
	# Draw grid background and lines
	_draw_grid_background()

	# Draw placed blocks
	_draw_placed_blocks()

	# Draw ghost piece (if current piece exists)
	if current_piece:
		_draw_ghost_piece()

	# Draw current piece
	if current_piece:
		_draw_current_piece()

	# Draw line clearing animation
	if is_animating:
		_draw_line_clear_animation()

func _draw_grid_background():
	# Draw background
	draw_rect(Rect2(0, 0, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE), EMPTY_COLOR)

	# Draw grid lines
	for x in range(GRID_WIDTH + 1):
		var x_pos = x * CELL_SIZE
		draw_line(Vector2(x_pos, 0), Vector2(x_pos, GRID_HEIGHT * CELL_SIZE), GRID_LINE_COLOR, 1.0)

	for y in range(GRID_HEIGHT + 1):
		var y_pos = y * CELL_SIZE
		draw_line(Vector2(0, y_pos), Vector2(GRID_WIDTH * CELL_SIZE, y_pos), GRID_LINE_COLOR, 1.0)

func _draw_placed_blocks():
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] != "":
				var color = TETROMINO_COLORS.get(grid[y][x], Color.WHITE)
				_draw_block(Vector2(x, y), color)

func _draw_current_piece():
	if not current_piece:
		return

	var piece_type = current_piece.get("type", "")
	var position = current_piece.get("position", Vector2i.ZERO)
	var blocks = current_piece.get("blocks", [])
	var color = TETROMINO_COLORS.get(piece_type, Color.WHITE)

	for block in blocks:
		var draw_pos = Vector2(position.x + block.x, position.y + block.y)
		if draw_pos.y >= 0:  # Only draw if visible on board
			_draw_block(draw_pos, color)

func _draw_ghost_piece():
	if not current_piece:
		return

	var piece_type = current_piece.get("type", "")
	var blocks = current_piece.get("blocks", [])
	var color = TETROMINO_COLORS.get(piece_type, Color.WHITE)
	color.a = GHOST_PIECE_ALPHA

	for block in blocks:
		var draw_pos = Vector2(ghost_piece_position.x + block.x, ghost_piece_position.y + block.y)
		if draw_pos.y >= 0:
			_draw_block(draw_pos, color, true)

func _draw_block(grid_position: Vector2, color: Color, is_ghost: bool = false):
	var x = grid_position.x * CELL_SIZE
	var y = grid_position.y * CELL_SIZE
	var rect = Rect2(x + 1, y + 1, CELL_SIZE - 2, CELL_SIZE - 2)

	if is_ghost:
		# Draw ghost piece with outline only
		draw_rect(rect, color, false)
		draw_rect(rect.grow(-2), color, false)
	else:
		# Draw solid block with 3D effect
		draw_rect(rect, color)

		# Highlight (top-left)
		var highlight_color = Color(color.r + 0.2, color.g + 0.2, color.b + 0.2, color.a)
		draw_line(Vector2(x + 2, y + 2), Vector2(x + CELL_SIZE - 2, y + 2), highlight_color, 2.0)
		draw_line(Vector2(x + 2, y + 2), Vector2(x + 2, y + CELL_SIZE - 2), highlight_color, 2.0)

		# Shadow (bottom-right)
		var shadow_color = Color(color.r - 0.2, color.g - 0.2, color.b - 0.2, color.a)
		draw_line(Vector2(x + CELL_SIZE - 2, y + 2), Vector2(x + CELL_SIZE - 2, y + CELL_SIZE - 2), shadow_color, 2.0)
		draw_line(Vector2(x + 2, y + CELL_SIZE - 2), Vector2(x + CELL_SIZE - 2, y + CELL_SIZE - 2), shadow_color, 2.0)

func _draw_line_clear_animation():
	for line in clearing_lines:
		var y = line * CELL_SIZE
		var alpha = 1.0 - clear_animation_progress
		var flash_color = Color(1.0, 1.0, 1.0, alpha)

		# Draw flashing effect
		var height = CELL_SIZE
		var rect = Rect2(0, y, GRID_WIDTH * CELL_SIZE, height)
		draw_rect(rect, flash_color)

# Public methods for game logic to call

func set_current_piece(piece_data):
	current_piece = piece_data
	queue_redraw()

func update_ghost_piece(position: Vector2i):
	ghost_piece_position = position
	queue_redraw()

func place_piece(piece_data):
	var piece_type = piece_data.get("type", "")
	var position = piece_data.get("position", Vector2i.ZERO)
	var blocks = piece_data.get("blocks", [])

	for block in blocks:
		var x = position.x + block.x
		var y = position.y + block.y
		if y >= 0 and y < GRID_HEIGHT and x >= 0 and x < GRID_WIDTH:
			grid[y][x] = piece_type

	current_piece = null
	queue_redraw()

func clear_lines(line_numbers: Array):
	clearing_lines = line_numbers
	is_animating = true
	clear_animation_progress = 0.0

	# Start animation
	var tween = create_tween()
	tween.tween_property(self, "clear_animation_progress", 1.0, 0.3)
	tween.tween_callback(_finish_line_clear)

func _finish_line_clear():
	# Remove cleared lines from grid
	for line in clearing_lines:
		grid.remove_at(line)

	# Add new empty lines at top
	for i in clearing_lines.size():
		var row = []
		for x in range(GRID_WIDTH):
			row.append("")
		grid.push_front(row)

	is_animating = false
	clearing_lines.clear()
	lines_cleared.emit(clearing_lines.size())
	queue_redraw()

func get_grid_state() -> Array:
	return grid.duplicate(true)

func is_position_valid(piece_data) -> bool:
	var position = piece_data.get("position", Vector2i.ZERO)
	var blocks = piece_data.get("blocks", [])

	for block in blocks:
		var x = position.x + block.x
		var y = position.y + block.y

		# Check boundaries
		if x < 0 or x >= GRID_WIDTH or y >= GRID_HEIGHT:
			return false

		# Check collision with placed blocks (only if y is on board)
		if y >= 0 and grid[y][x] != "":
			return false

	return true

func check_lines() -> Array:
	var full_lines = []

	for y in range(GRID_HEIGHT):
		var is_full = true
		for x in range(GRID_WIDTH):
			if grid[y][x] == "":
				is_full = false
				break

		if is_full:
			full_lines.append(y)

	return full_lines

func reset_board():
	_initialize_grid()
	current_piece = null
	ghost_piece_position = Vector2i.ZERO
	clearing_lines.clear()
	is_animating = false
	queue_redraw()
