extends CanvasLayer

signal puzzle_solved

@export var cell_scene: PackedScene #
@export var grid_size: int = 5
@onready var puzzle_grid: GridContainer = $HBoxContainer/VBoxContainer/PuzzleGrid
@onready var quit_button: Button = $QuitButton
@onready var mode_button: Button = $ModeButton
@onready var top_clues_grid: GridContainer = $HBoxContainer/VBoxContainer/TopCluesGrid
@onready var left_clues_grid: GridContainer = $HBoxContainer/LeftCluesGrid

# 1=Filled, 0=Empty. This is the "answer key".
var solution: Array[int] = [
	0, 1, 1, 1, 0,
	1, 1, 0, 1, 1,
	1, 0, 1, 0, 1,
	1, 1, 0, 1, 1,
	0, 1, 1, 1, 0
]
# This holds the player's current "filled" state (1s and 0s)
var current_state: Array[int] = []
var grid_cells: Array[Node] = []
var current_mode: String = "fill"

func _ready():
	mode_button.pressed.connect(_on_toggle_mode)
	quit_button.pressed.connect(_on_quit)
	
	puzzle_grid.columns = grid_size
	current_state.resize(grid_size * grid_size)
	current_state.fill(0) # Fill with 0s
	
	generate_clues()
	generate_grid()

func start_puzzle():
	GlobalState.is_in_minigame = true
	show()

func generate_grid():
	for i in grid_size * grid_size:
		var cell = cell_scene.instantiate()
		var cell_script = cell as PicrossCell
		cell_script.current_mode = current_mode
		
		# .bind(i) passes the cell's index 'i' to our function
		cell.cell_state_changed.connect(_on_cell_changed.bind(i))
		
		puzzle_grid.add_child(cell)
		grid_cells.append(cell)

# This function looks at the solution and creates the clue numbers
func generate_clues():
	# This is a bit complex, but you'd loop through your
	# 'solution' array, one row/column at a time, and count
	# the continuous blocks of '1's to generate the clue strings.
	# Example: [1, 1, 0, 1, 1] -> "2 2"
	# For now, we'll just put placeholder labels
	
	# Top Clues (columns)
	for i in grid_size:
		var clue = Label.new()
		clue.text = "1\n2" # Placeholder
		clue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		top_clues_grid.add_child(clue)
		
	# Left Clues (rows)
	for i in grid_size:
		var clue = Label.new()
		clue.text = "1 1" # Placeholder
		clue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		left_clues_grid.add_child(clue)

func _on_toggle_mode():
	if current_mode == "fill":
		current_mode = "mark"
		mode_button.text = "Mode: Mark X"
	else:
		current_mode = "fill"
		mode_button.text = "Mode: Fill"
	
	# Update all cells with the new mode
	for cell in grid_cells:
		(cell as PicrossCell).current_mode = current_mode

func _on_cell_changed(new_state: int, cell_index: int):
	# We only care about the "filled" state for the solution
	if new_state == 1:
		current_state[cell_index] = 1
	elif current_state[cell_index] == 1: # If we changed a '1' back to '0' or '2'
		current_state[cell_index] = 0
		
	check_for_win()

func check_for_win():
	# Compare the player's 'filled' state to the solution
	for i in solution.size():
		var player_is_filled = (current_state[i] == 1)
		var solution_is_filled = (solution[i] == 1)
		
		if player_is_filled != solution_is_filled:
			# Found a mismatch, puzzle is not solved
			return
			
	# If we get through the whole loop, it's a match!
	print("PUZZLE SOLVED!")
	GlobalState.is_in_minigame = false
	hide()
	puzzle_solved.emit()

func _on_quit():
	GlobalState.is_in_minigame = false
	hide()
