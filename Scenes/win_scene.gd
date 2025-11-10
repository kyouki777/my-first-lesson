extends CanvasLayer

@onready var bgm = $AudioStreamPlayer2D

func _ready() -> void:
	# Start looping BGM
	if bgm:
		bgm.play()

	await get_tree().create_timer(5.0).timeout

	# Start the dialogue
	Dialogic.start("escapeScene")

	# Connect to Dialogic 2 global signal
	if not Dialogic.is_connected("custom_event", Callable(self, "_on_custom_event")):
		Dialogic.connect("custom_event", Callable(self, "_on_custom_event"))


func _on_custom_event(event_name: String) -> void:
	print("Custom event received:", event_name)
	match event_name:
		"end_game":
			var file = FileAccess.open("user://end_flag.json", FileAccess.WRITE)
			if file:
				file.store_string('{"game_finished": true}')
				file.close()
			await get_tree().create_timer(2.0).timeout
			get_tree().quit()
		"main_menu":
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
