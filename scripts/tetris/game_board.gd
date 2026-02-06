class_name GameBoard
extends RefCounted

## Manages the game board state (10x20 grid) and collision detection

signal lines_cleared(lines: int, is_tetris: bool)
signal board_updated()

const BOARD_WIDTH: int = 10
const BOARD_HEIGHT: int = 20
const SPAWN_ROW: int = 0

# Board state: 2D array where null = empty, Color = filled block
var grid: Array = []


func _init() -> void:
	clear_board()


func clear_board() -> void:
	grid.clear()
	for y in range(BOARD_HEIGHT):
		var row: Array[Variant] = []
		row.resize(BOARD_WIDTH)
		for x in range(BOARD_WIDTH):
			row[x] = null
		grid.append(row)
	board_updated.emit()


func is_valid_position(blocks: Array[Vector2i]) -> bool:
	for block in blocks:
		if block.x < 0 or block.x >= BOARD_WIDTH:
			return false
		if block.y < 0 or block.y >= BOARD_HEIGHT:
			return false
		if grid[block.y][block.x] != null:
			return false
	return true


func is_collision(blocks: Array[Vector2i]) -> bool:
	return not is_valid_position(blocks)


func lock_piece(piece: Tetromino) -> void:
	var blocks = piece.get_blocks()
	for block in blocks:
		if block.y >= 0 and block.y < BOARD_HEIGHT and block.x >= 0 and block.x < BOARD_WIDTH:
			grid[block.y][block.x] = piece.color
	board_updated.emit()


func check_and_clear_lines() -> int:
	var lines_to_clear: Array[int] = []

	# Find full lines
	for y in range(BOARD_HEIGHT):
		if is_line_full(y):
			lines_to_clear.append(y)

	# Clear lines
	if lines_to_clear.size() > 0:
		clear_lines(lines_to_clear)
		var is_tetris = lines_to_clear.size() == 4
		lines_cleared.emit(lines_to_clear.size(), is_tetris)
		board_updated.emit()

	return lines_to_clear.size()


func is_line_full(y: int) -> bool:
	for x in range(BOARD_WIDTH):
		if grid[y][x] == null:
			return false
	return true


func clear_lines(lines: Array[int]) -> void:
	# Sort lines in descending order to remove from bottom to top
	lines.sort()
	lines.reverse()

	for line in lines:
		# Remove the cleared line
		grid.remove_at(line)

		# Add new empty line at top
		var new_row: Array[Variant] = []
		new_row.resize(BOARD_WIDTH)
		for x in range(BOARD_WIDTH):
			new_row[x] = null
		grid.insert(0, new_row)


func get_cell(x: int, y: int) -> Variant:
	if x < 0 or x >= BOARD_WIDTH or y < 0 or y >= BOARD_HEIGHT:
		return null
	return grid[y][x]


func is_spawn_area_blocked() -> bool:
	# Check if the spawn area (top rows) has any blocks
	for y in range(2):
		for x in range(BOARD_WIDTH):
			if grid[y][x] != null:
				return true
	return false


func get_drop_distance(piece: Tetromino) -> int:
	var distance = 0
	var test_piece = piece.duplicate_tetromino()

	while true:
		test_piece.move(Vector2i(0, 1))
		if is_collision(test_piece.get_blocks()):
			break
		distance += 1

	return distance


func get_board_state() -> Array:
	# Returns a deep copy of the board state
	var state: Array = []
	for y in range(BOARD_HEIGHT):
		var row: Array[Variant] = []
		row.resize(BOARD_WIDTH)
		for x in range(BOARD_WIDTH):
			row[x] = grid[y][x]
		state.append(row)
	return state
