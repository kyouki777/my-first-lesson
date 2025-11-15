class_name PicrossCell
extends Button

signal cell_state_changed(new_state)

# 0 = Empty, 1 = Filled, 2 = Marked 'X'
var state: int = 0

# We'll set this from the main puzzle
var current_mode = "fill" # "fill" or "mark"

func _on_pressed():
	if current_mode == "fill":
		state = 1
		self.text = "■" # A solid block character\

	else: # "mark"
		state = 2
		self.text = "X"
	
	cell_state_changed.emit(state)

# We can also add a way to clear the cell (e.g., right-click)
func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		state = 0
		self.text = ""
		cell_state_changed.emit(state)
		get_viewport().set_input_as_handled() # Stop click from passing through
