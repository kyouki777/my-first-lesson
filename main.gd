extends Node2D  # or whatever your main node is

@export var start_dialog_name: String = ""  # your Dialogic timeline name

func _ready():
	pass
	# 1. "FREEZE" THE GAME
	# Set the global pause flag to true.
	GlobalState.is_game_paused = true
	#
	# 2. START THE DIALOG
	# This function will pause *itself* until the dialog is over.
	Dialogic.start(start_dialog_name)
	await Dialogic.timeline_ended
	# 3. "UNFREEZE" THE GAME
	# Now that the dialog is over, set the flag back to false.
	GlobalState.is_game_paused = false
