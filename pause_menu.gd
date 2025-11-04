extends Control

# Pause menu buttons
@onready var resume_button = $VBoxContainer/ResumeButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton
@onready var quit_button = $VBoxContainer/QuitGameButton

# Background ColorRect (semi-transparent)
@onready var bg = $ColorRect

func _ready():
	# Start hidden
	visible = false

	# Ensure this menu works while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect buttons safely
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Optional: ensure background fills screen
	
func _input(event: InputEvent) -> void:
	# Press Esc (ui_cancel) to toggle pause
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	get_tree().paused = true
	visible = true

func resume_game():
	get_tree().paused = false
	visible = false

# Button callbacks
func _on_resume_pressed():
	resume_game()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")  # adjust path as needed

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
