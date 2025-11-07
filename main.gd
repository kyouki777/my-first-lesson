extends Node2D  # or whatever your main node is

@export var start_dialog_name: String = ""  # your Dialogic timeline name

func _ready():
	# Start the dialogue automatically
	Dialogic.start(start_dialog_name)
