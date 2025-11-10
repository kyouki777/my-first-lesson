extends Control

@export var initial_delay: float = 1.0
@export var fade_in_duration: float = 1.0
@export var logo_display_time: float = 1.0
@export var fade_out_duration: float = 1.0
@export var final_delay: float = 1.0
@export var next_scene_path: String = "res://Scenes/slideshow.tscn"
@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect

func _ready():
	
	# Check if the game was already finished
	var file = FileAccess.open("user://end_flag.json", FileAccess.READ)
	if file:
		var data = JSON.parse_string(file.get_as_text())
		file.close()

		if data and "game_finished" in data and data["game_finished"] == true:
			print("Game already finished — loading EmptyScene.")
			get_tree().change_scene_to_file("res://Scenes/EmptyScene.tscn")
			return

	print("end_game not found yet")
	# 1. Create a new Tween
	# This creates a "sequence" that will run on its own.
	var tween = get_tree().create_tween()

	# 2. Chain all your animations and delays in order.
	# The tween will execute these one after another.
	
	# Wait for the initial_delay (1.0s)
	tween.tween_interval(initial_delay)
	
	# Fade In: Animate the "modulate:a" (alpha) property of the
	# FadeRect from its current value (1.0) down to 0.0 (transparent).
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_duration)
	
	# Wait while the logo is visible (5.0s)
	tween.tween_interval(logo_display_time)
	
	# Fade Out: Animate the alpha property back to 1.0 (opaque).
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_duration)
	
	# Wait for the final_delay (3.0s) after it's faded to black.
	tween.tween_interval(final_delay)

	# 3. At the very end of the sequence, call a function.
	# This is the non-blocking way to change scenes when you're done.
	tween.tween_callback(change_scene)


# This function is called by the tween when the whole sequence is finished.
func change_scene():
	get_tree().change_scene_to_file(next_scene_path)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or \
	(event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
			# If they press skip, stop the timer and go to the next scene immediately.
			get_tree().change_scene_to_file(next_scene_path)
