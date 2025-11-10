extends Area2D

@export var quiz_scene: PackedScene  # drag your quiz.tscn here

var player_in_zone := false
@export var quiz_ui: CanvasLayer
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		if quiz_ui and is_instance_valid(quiz_ui):
			quiz_ui.visible = false

func _process(_delta):
	if player_in_zone and Input.is_action_just_pressed("interact"):  # "E" key
		_toggle_quiz_ui()

func _toggle_quiz_ui():
	quiz_ui.visible = !quiz_ui.visible
