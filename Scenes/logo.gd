extends Control

@export var initial_delay: float = 1.0
@export var fade_in_duration: float = 1.0
@export var logo_display_time: float = 1.5
@export var fade_out_duration: float = 1.0
@export var final_delay: float = 1.0
@export var next_scene_path: String = "res://Scenes/slideshow.tscn"

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect
@onready var logo: Sprite2D = $Logo
@onready var headphones_slide: Sprite2D = $HeadphonesSlide

func _ready():
	# If the game was finished before, skip this
	if FileAccess.file_exists("user://end_flag.json"):
		var file = FileAccess.open("user://end_flag.json", FileAccess.READ)
		if file.get_as_text().contains("true"):
			file.close()
			get_tree().change_scene_to_file("res://Scenes/EmptyScene.tscn")
			return
		file.close()

	# Hide second slide at start
	headphones_slide.visible = false

	# Create the tween sequence
	var tween = get_tree().create_tween()

	# Initial wait
	tween.tween_interval(initial_delay)

	# Fade in logo
	fade_rect.modulate.a = 1.0
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_duration)

	# Display logo
	tween.tween_interval(logo_display_time)

	# Fade out logo
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_duration)
	tween.tween_callback(_show_headphones_slide)

	# Wait a little before next fade
	tween.tween_interval(0.5)

	# Fade in headphones slide
	tween.tween_property(fade_rect, "modulate:a", 0.0, fade_in_duration)

	# Display headphones slide for a bit
	tween.tween_interval(2.5)

	# Fade out and change scene
	tween.tween_property(fade_rect, "modulate:a", 1.0, fade_out_duration)
	tween.tween_interval(final_delay)
	tween.tween_callback(change_scene)


func _show_headphones_slide():
	logo.visible = false
	headphones_slide.visible = true


func change_scene():
	get_tree().change_scene_to_file(next_scene_path)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or \
	   (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		get_tree().change_scene_to_file(next_scene_path)
