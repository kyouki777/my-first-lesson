extends Node

# This variable can be accessed from anywhere!
# When true, (for dialogic mainly) player can't move and dialogs can't be re-triggered.
var is_game_paused: bool = false
var puzzle_1: bool = false
var puzzle_2: bool = false
var puzzle_3: bool = false

# When true, (seperate from dialogic) player won't move, but UI can still work
var is_in_minigame: bool = false

func _ready() -> void:
	Dialogic.dialog_ending_timeline = null
