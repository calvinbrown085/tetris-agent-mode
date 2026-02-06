extends Control

signal start_game_pressed
signal quit_pressed

func _ready():
	pass

func _on_start_button_pressed():
	start_game_pressed.emit()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed():
	quit_pressed.emit()
	get_tree().quit()
