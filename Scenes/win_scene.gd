extends CanvasLayer

@onready var bgm = $AudioStreamPlayer2D

func _ready() -> void:
	# Play BGM if it exists
	if bgm:
		bgm.play()

	# Start the dialogue after a short delay
	await get_tree().create_timer(5.0).timeout
	Dialogic.start("escapeScene")

	# Wait for the player to make a choice in the dialogue
	await _wait_for_ending_choice()

# Poll for the Dialogic variable set by the timeline
func _wait_for_ending_choice() -> void:
	while Dialogic.VAR.get("ending_choice") == "":
		await get_tree().create_timer(0.2).timeout

	var choice = Dialogic.VAR.get("ending_choice")
	print("ENDING CHOICE:", choice)  # Debug log

	# Execute the action based on the choice
	_execute_end_action(choice)

# Execute the proper action
func _execute_end_action(choice: String) -> void:
	match choice:
		"main_menu":
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		"quit":
			# Save the end_flag so next time game opens it shows EmptyScene
			var file = FileAccess.open("user://end_flag.json", FileAccess.WRITE)
			if file:
				file.store_string('{"game_finished": true}')
				file.close()
			await get_tree().create_timer(1.0).timeout
			get_tree().quit()
