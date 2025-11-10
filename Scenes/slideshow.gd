extends Control

# Each slide is an array of 2 textures (the frames)
@export var slide_animations: Array[Array] = [
	[
		preload("res://Assets/intro 1a.png"),
		preload("res://Assets/intro 1b.png")
	],
	[
		preload("res://Assets/intro 2a.png"),
		preload("res://Assets/intro 2b.png")
	],
	[
		preload("res://Assets/intro 3a.png"),
		preload("res://Assets/intro 3b.png")
	],
	[
		preload("res://Assets/intro 4a.png"),
		preload("res://Assets/intro 4b.png")
	],
	[
		preload("res://Assets/intro 5a.png"),
		preload("res://Assets/intro 5b.png")
		
	],
	[
		preload("res://Assets/intro 6a.png"),
		preload("res://Assets/intro 6b.png")
		
	]
]

# Path to the next scene
@export var next_scene_path: String = "res://Scenes/main_menu.tscn"

# --- AUDIO ---------------------------------------------------------
@export var book_open_sound: AudioStream
@export var book_close_sound: AudioStream
@export var page_flip_sound: AudioStream

# --- NODES ---------------------------------------------------------
@onready var slide_display: TextureRect = $SlideDisplay
@onready var sfx_player: AudioStreamPlayer2D = $SFXPlayer
@onready var bgm_player: AudioStreamPlayer2D = $BGMPlayer

# --- VARIABLES -----------------------------------------------------
var current_slide_index: int = 0
var current_frame_index: int = 0
var frame_timer: float = 0.0
var frame_interval: float = 0.15  # seconds per frame

# --- READY ---------------------------------------------------------
func _ready() -> void:
	show_slide(current_slide_index)

	if bgm_player and not bgm_player.playing:
		bgm_player.play()

	if sfx_player and book_open_sound:
		sfx_player.stream = book_open_sound
		sfx_player.play()

# --- PROCESS -------------------------------------------------------
func _process(delta: float) -> void:
	if current_slide_index < slide_animations.size():
		var frames = slide_animations[current_slide_index]
		if frames.size() >= 2:
			frame_timer += delta
			if frame_timer >= frame_interval:
				frame_timer = 0.0
				current_frame_index = (current_frame_index + 1) % frames.size()
				slide_display.texture = frames[current_frame_index]

# --- INPUT ---------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		skip_slideshow()
	elif event.is_action_pressed("ui_accept"):
		next_slide()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		next_slide()

# --- SLIDE HANDLING ------------------------------------------------
func show_slide(index: int) -> void:
	if index < slide_animations.size():
		current_frame_index = 0
		frame_timer = 0.0
		slide_display.texture = slide_animations[index][0]

func next_slide() -> void:
	current_slide_index += 1
	if current_slide_index < slide_animations.size():
		if sfx_player and page_flip_sound:
			sfx_player.stream = page_flip_sound
			sfx_player.play()
		show_slide(current_slide_index)
	else:
		if sfx_player and book_close_sound:
			sfx_player.stream = book_close_sound
			sfx_player.play()
		await get_tree().create_timer(1.0).timeout
		go_to_next_scene()

func skip_slideshow() -> void:
	if sfx_player and book_close_sound:
		sfx_player.stream = book_close_sound
		sfx_player.play()
	await get_tree().create_timer(0.5).timeout
	go_to_next_scene()

# --- SCENE CHANGE --------------------------------------------------
func go_to_next_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)
