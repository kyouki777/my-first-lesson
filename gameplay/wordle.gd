extends Control

@onready var buttons = $GridContainer.get_children()

signal winsignal

const SIZE = 5

var wordle:String = ""
var index = 0 # Position of button text to be updated
var latest_row_index = 0
var row_filled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_game()

func _input(event):
	# don't start game until menu is visible
	if not get_parent().visible:
		return
	if event is InputEventKey and event.is_pressed():
		if event.keycode >= KEY_A and event.keycode <= KEY_Z:
			var letter = char(event.keycode)
			print("Letter:", letter)
			
			if not row_filled:
				buttons[index].text = letter
				index += 1

				if index != 0 and index % 5 == 0:
					row_filled = true
			
	if Input.is_action_pressed("back"):
		if index > 0 and index > latest_row_index:
			index -= 1
			buttons[index].text = ""
			row_filled = false
	if Input.is_action_pressed("enter"):
		# Only check win when an entire row is filledsa
		if row_filled:
			check_win()
			latest_row_index = index
			row_filled = false
		if index >=25:
			reset_game()
			

func reset_game():
	index = 0
	row_filled = false
	latest_row_index = 0

	wordle = get_random_wordle()
	print("Wordle: ", wordle)
	for button in buttons:
		init_button_styles(button)

func init_button_styles(b: Button):
	b.text = ""
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.border_color = Color.DIM_GRAY
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	b.add_theme_stylebox_override("normal", style)

func update_button_style(button:Button, bg_color:Color):
	var style = button.get_theme_stylebox("normal")
	style.bg_color = bg_color
	button.add_theme_stylebox_override("normal", style)

func get_random_wordle():
	var file = FileAccess.open("res://gameplay/wordle-list.txt", FileAccess.READ)
	var content = file.get_as_text(true)
	var lines = content.split("\n")
	var new_lines = []
	for line in lines:
		if line.length() == 0 or line == "" or line.strip_edges() == "":
			continue
		else:
			new_lines.append(line)
	randomize()
	return new_lines.pick_random().to_upper()

func check_win():
	# Extract text from the last added row
	var entered_text = ""
	for button in buttons.slice(latest_row_index, latest_row_index+SIZE):
		entered_text += button.text
	print("Entered Text:", entered_text)
	
	var idx = 0
	# Update button colors
	for button in buttons.slice(latest_row_index, latest_row_index+SIZE):
		if entered_text[idx] == wordle[idx]:
			update_button_style(button, Color.SEA_GREEN)
		elif entered_text[idx] in wordle:
			update_button_style(button, Color.CHOCOLATE)
		elif entered_text[idx] not in wordle:
			update_button_style(button, Color.CRIMSON)
		idx += 1
	
	# Check win condition
	if entered_text == wordle:
		print("win")
		emit_signal("winsignal")
		# signal win 
	
	# Check lose condition when all rows are filled
	if index == buttons.size():
		# signal lost
		print("lose")
