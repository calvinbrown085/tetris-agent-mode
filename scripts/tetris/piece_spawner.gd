class_name PieceSpawner
extends RefCounted

## Manages piece spawning and "next piece" queue using bag randomization

signal next_pieces_updated(next_pieces: Array[Tetromino.Type])

const PREVIEW_COUNT: int = 3  # Number of next pieces to show
const SPAWN_POSITION: Vector2i = Vector2i(3, 0)

var piece_bag: Array[Tetromino.Type] = []
var next_pieces: Array[Tetromino.Type] = []


func _init() -> void:
	# Initialize with pieces for immediate gameplay
	fill_bag()
	for i in range(PREVIEW_COUNT + 1):
		next_pieces.append(draw_from_bag())
	next_pieces_updated.emit(next_pieces)


func spawn_next_piece() -> Tetromino:
	if next_pieces.is_empty():
		# Safety fallback - should never happen
		fill_bag()
		next_pieces.append(draw_from_bag())

	var piece_type = next_pieces.pop_front()
	next_pieces.append(draw_from_bag())

	next_pieces_updated.emit(next_pieces)

	return Tetromino.new(piece_type, SPAWN_POSITION)


func fill_bag() -> void:
	# 7-bag randomization system (standard in modern Tetris)
	# Each bag contains exactly one of each piece type
	piece_bag.clear()
	piece_bag.append_array([
		Tetromino.Type.I,
		Tetromino.Type.O,
		Tetromino.Type.T,
		Tetromino.Type.S,
		Tetromino.Type.Z,
		Tetromino.Type.J,
		Tetromino.Type.L
	])
	piece_bag.shuffle()


func draw_from_bag() -> Tetromino.Type:
	if piece_bag.is_empty():
		fill_bag()
	return piece_bag.pop_back()


func get_next_pieces() -> Array[Tetromino.Type]:
	return next_pieces.duplicate()


func peek_next() -> Tetromino.Type:
	if next_pieces.is_empty():
		return Tetromino.Type.I
	return next_pieces[0]


func reset() -> void:
	piece_bag.clear()
	next_pieces.clear()
	fill_bag()
	for i in range(PREVIEW_COUNT + 1):
		next_pieces.append(draw_from_bag())
	next_pieces_updated.emit(next_pieces)
