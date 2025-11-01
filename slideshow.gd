extends Control

@export var slide_images: Array[Texture] = [
	preload("res://Assets/game intro 1.png"),
	preload("res://Assets/game intro 2.png"),
	preload("res://Assets/game intro 3.png"),
	preload("res://Assets/game intro 4.png"),
	preload("res://Assets/game intro 5.png"),
	
]
# game
@export var next_scene_path: String = "res://main_menu.tscn"
@onready var slide_display: TextureRect = $SlideDisplay
@onready var slide_timer: Timer = $SlideTimer

var current_slide_index: int = 0

func _ready() -> void:
	#slide_timer.timeout.connect(_on_slide_timer_timeout)
	
	show_slide(current_slide_index)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		# If they press skip, stop the timer and go to the next scene immediately.
		slide_timer.stop()
		go_to_next_scene()

func _on_slide_timer_timeout() -> void:
	# Move to the next slide index.
	current_slide_index += 1
	# Show the next slide.
	show_slide(current_slide_index)

# custom

func show_slide(index:int):
	if index < slide_images.size():
		# Set the texture of our TextureRect to the correct image.
		slide_display.texture = slide_images[index]
		# Start the timer.
		slide_timer.start()
	else:
		# If we're out of slides, go to the main game.
		go_to_next_scene()
		

func go_to_next_scene():
	# This is the standard Godot function for changing scenes.
	get_tree().change_scene_to_file(next_scene_path)
