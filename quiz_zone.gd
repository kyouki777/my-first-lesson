extends Area2D

@export var quiz_scene: PackedScene  # drag your quiz.tscn here
@export var quiz_node_name := "QuizUI"  # unique name for your quiz CanvasLayer

var player_in_zone := false
var quiz_ui: CanvasLayer = null

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
	if not quiz_ui:
		# Check if it's already in the scene
		var existing = get_tree().root.get_node_or_null(quiz_node_name)
		if existing:
			quiz_ui = existing
		else:
			if not quiz_scene:
				push_warning("No quiz scene assigned!")
				return
			quiz_ui = quiz_scene.instantiate()
			quiz_ui.name = quiz_node_name
			get_tree().root.add_child(quiz_ui)
	
	quiz_ui.visible = !quiz_ui.visible
