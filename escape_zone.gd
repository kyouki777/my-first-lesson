extends Area2D

@export var fade_path: NodePath = ^"CanvasLayer/ColorRect" # set this from the editor
const WIN_SCENE_PATH = "res://Scenes/WinScene.tscn"

@onready var fade_rect: ColorRect = get_node_or_null(fade_path)

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		print("Entered escape zone")
		_trigger_win_sequence(body)

func _trigger_win_sequence(player):
	# Stop AI
	for enemy in get_tree().get_nodes_in_group("Caretaker"):
		enemy.process_mode = Node.PROCESS_MODE_DISABLED

	# Stop player movement completely
	player.set_physics_process(false)
	player.set_process(false)
	player.velocity = Vector2.ZERO

	# Fade in smoothly
	if fade_rect:
		fade_rect.visible = true
		fade_rect.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 1.5)
		tween.tween_callback(Callable(self, "_load_win_scene"))
	else:
		print("FadeRect not found, skipping fade.")
		_load_win_scene()

func _load_win_scene():
	get_tree().change_scene_to_file(WIN_SCENE_PATH)
