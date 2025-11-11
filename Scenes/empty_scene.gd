extends Node2D

@onready var bgm = $AudioStreamPlayer2D  # Make sure you have an AudioStreamPlayer2D node
@export var next_dialogic_scene: String = "EmptyScene"  # Name of the Dialogic scene to start

func _ready() -> void:
	if bgm and bgm.stream:
		bgm.play()
		# Wait until the audio finishes
		await _wait_for_audio()
		_start_dialogic_scene()
	else:
		# No audio? Just start the Dialogic scene immediately
		_start_dialogic_scene()

# Waits until the audio finishes playing
func _wait_for_audio() -> void:
	while bgm.playing:
		await get_tree().process_frame  # wait one frame

# Start the Dialogic scene
func _start_dialogic_scene() -> void:
	Dialogic.start(next_dialogic_scene)
