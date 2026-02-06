extends Control

signal restart_pressed
signal menu_pressed
signal resume_pressed

@onready var game_over_screen = $GameOverScreen
@onready var pause_screen = $PauseScreen
@onready var final_score_label = $GameOverScreen/CenterContainer/VBoxContainer/FinalScoreLabel
@onready var restart_button = $GameOverScreen/CenterContainer/VBoxContainer/ButtonContainer/RestartButton
@onready var game_over_menu_button = $GameOverScreen/CenterContainer/VBoxContainer/ButtonContainer/MenuButton
@onready var resume_button = $PauseScreen/CenterContainer/VBoxContainer/ButtonContainer/ResumeButton
@onready var pause_menu_button = $PauseScreen/CenterContainer/VBoxContainer/ButtonContainer/MenuButton

func _ready():
	restart_button.pressed.connect(_on_restart_button_pressed)
	game_over_menu_button.pressed.connect(_on_menu_button_pressed)
	resume_button.pressed.connect(_on_resume_button_pressed)
	pause_menu_button.pressed.connect(_on_menu_button_pressed)

	hide_all_screens()

func show_game_over(final_score: int):
	hide_all_screens()
	final_score_label.text = "Final Score: " + str(final_score)
	game_over_screen.visible = true
	visible = true

func show_pause():
	hide_all_screens()
	pause_screen.visible = true
	visible = true

func hide_all_screens():
	game_over_screen.visible = false
	pause_screen.visible = false
	visible = false

func _on_restart_button_pressed():
	restart_pressed.emit()
	hide_all_screens()

func _on_menu_button_pressed():
	menu_pressed.emit()
	hide_all_screens()

func _on_resume_button_pressed():
	resume_pressed.emit()
	hide_all_screens()
