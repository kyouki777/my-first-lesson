extends Area2D
@export var dialog_name: String = "" 
@export var donedialog: String = "" 
# 1. Define the states your object can be in
enum {
	STATE_DIALOG, # Start: We need to show the dialog
	STATE_PUZZLE, # We've seen the dialog, now we show the puzzle
	STATE_DONE    # Puzzle is finished
}

# 2. Set the starting state
var current_state = STATE_DIALOG

# Reference to your puzzle scene (drag it in the Inspector)
@export var puzzle_ui: CanvasLayer

# Internal variable to track if the player is nearby
var player_in_area: bool = false

func _ready():
	# Connect the Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		# You can also show a "Press E" prompt here

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		# You can hide the "Press E" prompt here

# This function handles the interaction
func _process(_delta):
	# Check if player is here, presses interact, and game is not paused
	if player_in_area and Input.is_action_just_pressed("interact") and not GlobalState.is_game_paused:
		
		# This is the "state machine"
		# It checks our current state and does the right action
		match current_state:
			
			STATE_DIALOG:
				# 1. Freeze the game
				GlobalState.is_game_paused = true
				
				# 2. Show the "power" dialog
				Dialogic.start(dialog_name)
				
				# 3. Wait for the dialog to finish
				await Dialogic.timeline_ended
				
				# 4. Unfreeze the game
				GlobalState.is_game_paused = false
				
				# 5. --- THIS IS THE KEY ---
				#    Change the state to "PUZZLE"
				current_state = STATE_PUZZLE
				print("Object state is now PUZZLE")

			STATE_PUZZLE:
				_toggle_puzzle_ui()
				
				# 3. Change state to "DONE"
				current_state = STATE_DONE
				print("Object state is now DONE")

			STATE_DONE:
				# The puzzle is already solved.
				# You can play a simple "it's fixed" dialog
				Dialogic.start(donedialog)
				# No need to await, just let it play

func _toggle_puzzle_ui():
	puzzle_ui.visible = !puzzle_ui.visible
