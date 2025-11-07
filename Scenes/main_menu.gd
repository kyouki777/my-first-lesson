extends Control

@export var start_scene_path: String = "res://main.tscn"

# You can also set a path for your options menu if you have one.
# @export var options_scene_path: String = "res://options_menu.tscn"

# This function was created for the OptionsButton.
func _on_options_button_pressed():
	print("Options button pressed!")
	# For now, we'll just print a message.
	# Later, you would add:
	# get_tree().change_scene_to_file(options_scene_path)
	pass

func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(start_scene_path)
