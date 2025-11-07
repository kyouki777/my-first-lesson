extends Area2D

# --- QUIZ DATA ---
# You can set these in the Inspector for each pedestal you place!
@export var question_text: String = "What is 2 + 2?"
@export var answers: Array[String] = ["3", "4", "5"]
@export var correct_answer_index: int = 1 # "4" is at index 1

var has_been_triggered: bool = false


func _ready():
	# Connect the "body_entered" signal to our own function
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	# Check if the body is the player and we haven't been triggered yet
	if body.is_in_group("player") and not has_been_triggered:
		has_been_triggered = true
		
		# Find the QuizPopup node in the main scene
		# (We'll add it to a group in the next step)
		var quiz_popup = get_tree().get_first_node_in_group("quiz_popup")
		
		if quiz_popup:
			# Call the popup's function with our unique data!
			quiz_popup.show_quiz(question_text, answers, correct_answer_index)
			
			# Optional: Make this pedestal disappear or deactivate
			# queue_free()
		else:
			print("ERROR: QuizPedestal could not find a 'quiz_popup' node!")
