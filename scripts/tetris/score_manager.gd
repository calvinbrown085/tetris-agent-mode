class_name ScoreManager
extends RefCounted

## Manages scoring, level progression, and game statistics

signal score_changed(new_score: int)
signal level_changed(new_level: int)
signal lines_changed(new_lines: int)

var score: int = 0
var level: int = 1
var lines_cleared: int = 0
var total_pieces: int = 0

# Scoring based on original Tetris guidelines
const POINTS_SINGLE: int = 100
const POINTS_DOUBLE: int = 300
const POINTS_TRIPLE: int = 500
const POINTS_TETRIS: int = 800
const POINTS_SOFT_DROP: int = 1
const POINTS_HARD_DROP: int = 2

const LINES_PER_LEVEL: int = 10


func _init(starting_level: int = 1) -> void:
	level = starting_level
	score = 0
	lines_cleared = 0
	total_pieces = 0


func reset() -> void:
	score = 0
	level = 1
	lines_cleared = 0
	total_pieces = 0
	score_changed.emit(score)
	level_changed.emit(level)
	lines_changed.emit(lines_cleared)


func add_line_clear_score(lines: int, is_tetris: bool = false) -> void:
	var points = 0

	match lines:
		1:
			points = POINTS_SINGLE * level
		2:
			points = POINTS_DOUBLE * level
		3:
			points = POINTS_TRIPLE * level
		4:
			points = POINTS_TETRIS * level

	score += points
	lines_cleared += lines
	score_changed.emit(score)
	lines_changed.emit(lines_cleared)

	# Check for level up
	check_level_up()


func add_soft_drop_score(cells: int) -> void:
	score += cells * POINTS_SOFT_DROP
	score_changed.emit(score)


func add_hard_drop_score(cells: int) -> void:
	score += cells * POINTS_HARD_DROP
	score_changed.emit(score)


func increment_piece_count() -> void:
	total_pieces += 1


func check_level_up() -> void:
	var new_level = 1 + (lines_cleared / LINES_PER_LEVEL)
	if new_level > level:
		level = new_level
		level_changed.emit(level)


func get_fall_speed() -> float:
	# Returns the time in seconds between automatic piece drops
	# Speed increases with level (exponential curve)
	# Formula: speed = (0.8 - ((level - 1) * 0.007)) ^ (level - 1)
	# Simplified for better gameplay: base_speed / level
	var base_speed = 1.0  # 1 second at level 1
	var speed = base_speed / (1.0 + (level - 1) * 0.15)
	return max(speed, 0.05)  # Minimum 0.05 seconds (very fast)


func get_current_score() -> int:
	return score


func get_current_level() -> int:
	return level


func get_lines_cleared() -> int:
	return lines_cleared


func get_total_pieces() -> int:
	return total_pieces


func get_statistics() -> Dictionary:
	return {
		"score": score,
		"level": level,
		"lines": lines_cleared,
		"pieces": total_pieces
	}
