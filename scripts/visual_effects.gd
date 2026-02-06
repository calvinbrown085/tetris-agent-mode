extends Node2D

# Visual effects for Tetris game
# Handles particle effects, screen shake, and other visual feedback

signal effect_completed(effect_name: String)

const PARTICLE_COLORS = [
	Color(0.0, 0.9, 0.9, 1.0),    # Cyan
	Color(0.9, 0.9, 0.0, 1.0),    # Yellow
	Color(0.6, 0.0, 0.9, 1.0),    # Purple
	Color(0.0, 0.9, 0.0, 1.0),    # Green
	Color(0.9, 0.0, 0.0, 1.0),    # Red
	Color(0.0, 0.0, 0.9, 1.0),    # Blue
	Color(0.9, 0.5, 0.0, 1.0),    # Orange
]

var screen_shake_amount = 0.0
var original_position = Vector2.ZERO

func _ready():
	original_position = position

func _process(delta):
	# Handle screen shake
	if screen_shake_amount > 0:
		position = original_position + Vector2(
			randf_range(-screen_shake_amount, screen_shake_amount),
			randf_range(-screen_shake_amount, screen_shake_amount)
		)
		screen_shake_amount = lerp(screen_shake_amount, 0.0, delta * 10.0)

		if screen_shake_amount < 0.1:
			screen_shake_amount = 0.0
			position = original_position

func trigger_line_clear_effect(line_count: int):
	# Screen shake intensity based on lines cleared
	var shake_intensity = 5.0 * line_count
	screen_shake(shake_intensity)

func screen_shake(intensity: float):
	screen_shake_amount = intensity

func trigger_piece_lock_effect():
	# Small shake when piece locks
	screen_shake(2.0)

func trigger_hard_drop_effect():
	# Medium shake for hard drop
	screen_shake(4.0)

func trigger_level_up_effect():
	# Strong shake for level up
	screen_shake(8.0)

func trigger_game_over_effect():
	# Very strong shake for game over
	screen_shake(12.0)

# Particle burst effect (can be extended with GPUParticles2D later)
func create_particle_burst(pos: Vector2, color: Color, count: int = 10):
	# This is a placeholder for particle effects
	# Can be extended with actual GPUParticles2D nodes
	pass
