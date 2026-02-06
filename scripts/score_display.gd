extends Label

# Animated score display that shows point changes

var target_score = 0
var display_score = 0
var animation_speed = 500.0  # Points per second

func _ready():
	text = "0"

func _process(delta):
	if display_score != target_score:
		# Animate score counting up
		var diff = target_score - display_score
		var step = animation_speed * delta

		if abs(diff) < step:
			display_score = target_score
		else:
			display_score += sign(diff) * step

		text = str(int(display_score))

func set_score(score: int):
	target_score = score

func set_score_instant(score: int):
	target_score = score
	display_score = score
	text = str(score)

func flash_score():
	# Create a flash animation when score increases
	var tween = create_tween()
	tween.set_parallel(true)

	# Scale up and down
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)

	# Flash color
	var original_color = modulate
	tween.tween_property(self, "modulate", Color(1.5, 1.5, 0.5, 1.0), 0.1)
	tween.tween_property(self, "modulate", original_color, 0.1).set_delay(0.1)
