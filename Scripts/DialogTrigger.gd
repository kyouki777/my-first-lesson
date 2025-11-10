extends Area2D

@export var dialog_name: String = ""  # Set this per Area2D in the Inspector
var player_in_area = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))
	
	Dialogic.Inputs.manual_advance.system_enabled = true

	# Connect the custom signal to the open_hidden_room function
	#connect("trigger_hidden_room", Callable(self, "open_hidden_room"))


func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false

func _unhandled_input(event):
	# We only check for interaction if:
	# 1. The player is in the area.
	# 2. The game is NOT already paused.
	# 3. The "interact" button is pressed.
	if player_in_area and not GlobalState.is_game_paused and event.is_action_pressed("interact"):
		# Start the dialog!
		start_my_dialog()

func start_my_dialog():
	# 1. "FREEZE" THE GAME
	# Set the global pause flag to true.
	GlobalState.is_game_paused = true
	
	# 2. START THE DIALOG
	# This function will pause *itself* until the dialog is over.
	Dialogic.start(dialog_name)
	await Dialogic.timeline_ended
	# 3. "UNFREEZE" THE GAME
	# Now that the dialog is over, set the flag back to false.
	GlobalState.is_game_paused = false
