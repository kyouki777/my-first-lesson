extends CanvasLayer

signal quiz_finished(was_correct: bool)

# --- Node References ---
@onready var question_label: Label = $Background/Quiz/Question
@onready var answers_container: VBoxContainer = $Background/Quiz/Answers
@onready var feedback_label: Label = $Background/Quiz/Feedback
@onready var next_button: Button = $Background/Quiz/Next

# We'll store the correct answer index here
var correct_index: int = 0


func _ready():
	# Hide by default
	hide()
	
	# Connect the Continue button
	next_button.pressed.connect(_on_continue_pressed)
	
	# Connect all the answer buttons.
	# We use .bind() to pass the button's index (0, 1, 2) to the function.
	for i in answers_container.get_child_count():
		var button = answers_container.get_child(i)
		# We connect the "pressed" signal to our _on_answer_pressed function
		# .bind(i) adds 'i' as an argument to that function call.
		button.pressed.connect(_on_answer_pressed.bind(i))


# This is our main function. Other scenes will call this.
func show_quiz(question_text: String, answers: Array[String], correct_answer_idx: int):
	# Set the question text
	question_label.text = question_text
	
	# Store the correct answer index
	correct_index = correct_answer_idx
	
	# Set up the answer buttons
	for i in answers_container.get_child_count():
		var button = answers_container.get_child(i)
		if i < answers.size():
			button.text = answers[i]
			button.disabled = false # Enable the button
			button.show()
		else:
			button.hide() # Hide unused buttons
	
	# Clear old feedback and hide the continue button
	feedback_label.text = ""
	next_button.hide()
	
	# Pause the game and show the quiz
	get_tree().paused = true
	show()


# This function runs when AnswerButton1, 2, or 3 is pressed.
# 'index_pressed' will be 0, 1, or 2, thanks to .bind(i).
func _on_answer_pressed(index_pressed: int):
	# Disable all answer buttons so they can't be spammed
	for button in answers_container.get_children():
		button.disabled = true

	var was_correct: bool = false
	
	# Check if the answer was correct
	if index_pressed == correct_index:
		feedback_label.text = "Correct!"
		feedback_label.modulate = Color.GREEN # Optional: color text
		was_correct = true
	else:
		feedback_label.text = "Wrong!"
		feedback_label.modulate = Color.RED # Optional: color text
		was_correct = false
	
	# Show the continue button
	next_button.show()
	
	# Emit the signal to let the main game know the result
	quiz_finished.emit(was_correct)


# This function runs when the "Continue" button is pressed
func _on_continue_pressed():
	# Unpause the game
	get_tree().paused = false
	# Hide the popup
	hide()
