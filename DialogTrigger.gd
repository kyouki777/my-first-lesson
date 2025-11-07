extends Area2D

@export var dialog_name: String = ""  # Set this per Area2D in the Inspector
var player_in_area = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

	# Connect the custom signal to the open_hidden_room function
	connect("trigger_hidden_room", Callable(self, "open_hidden_room"))


func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		print("E pressed")
		if dialog_name != "":
			Dialogic.start(dialog_name)
			
		else:
			print("⚠ No dialog name set for this Area2D!")
