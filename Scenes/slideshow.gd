extends Control

@export var slide_images: Array[Texture] = [
	preload("res://Assets/game intro 1.png"),
	preload("res://Assets/game intro 2.png"),
	preload("res://Assets/game intro 3.png"),
	preload("res://Assets/game intro 4.png"),
	preload("res://Assets/game intro 5.png"),
]

@export var next_scene_path: String = "res://Scenes/main_menu.tscn"

# Sounds (set these in the Inspector)
@export var book_open_sound: AudioStream
@export var book_close_sound: AudioStream
@export var page_flip_sound: AudioStream

@onready var slide_display: TextureRect = $SlideDisplay
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer

var current_slide_index: int = 0

func _ready() -> void:
	show_slide(current_slide_index)

	# Play background music if not already playing
	if bgm_player and not bgm_player.playing:
		bgm_player.play()

	# Play book opening sound
	if sfx_player and book_open_sound:
		sfx_player.stream = book_open_sound
		sfx_player.play()

func _input(event: InputEvent) -> void:
	# Skip entire slideshow if Enter pressed
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		skip_slideshow()
	
	# Detect Z / Space (default ui_accept)
	elif event.is_action_pressed("ui_accept"):
		next_slide()
	
	# Detect left mouse click (or touchscreen tap)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next_slide()

func next_slide() -> void:
	current_slide_index += 1

	if current_slide_index < slide_images.size():
		show_slide(current_slide_index)

		# Play page flip sound
		if sfx_player and page_flip_sound:
			sfx_player.stream = page_flip_sound
			sfx_player.play()
	else:
		# Play book closing sound
		if sfx_player and book_close_sound:
			sfx_player.stream = book_close_sound
			sfx_player.play()

		# Wait a moment before going to next scene
		await get_tree().create_timer(1.0).timeout
		go_to_next_scene()

func skip_slideshow() -> void:
	# Instantly skip to the end with closing sound
	if sfx_player and book_close_sound:
		sfx_player.stream = book_close_sound
		sfx_player.play()

	await get_tree().create_timer(0.5).timeout
	go_to_next_scene()

func show_slide(index: int) -> void:
	if index < slide_images.size():
		slide_display.texture = slide_images[index]

func go_to_next_scene():
	get_tree().change_scene_to_file(next_scene_path)
