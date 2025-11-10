extends Node

# This variable can be accessed from anywhere!
# When true, player can't move and dialogs can't be re-triggered.
var is_game_paused: bool = false

func _ready() -> void:
	Dialogic.dialog_ending_timeline = null
