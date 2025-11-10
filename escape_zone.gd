extends Area2D

@onready var fade_rect: ColorRect = get_tree().current_scene.get_node("WinFadeIn/FadeRect")


const WIN_SCENE_PATH = "res://Scenes/WinScene.tscn"

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		print("Entered escape zone")
		

		
		# (Optional) trigger fade or win scene
		_trigger_win_sequence()

func _trigger_win_sequence():
	# Stop AI and player manually (don't pause tree)
	for enemy in get_tree().get_nodes_in_group("Caretaker"):
		enemy.set_process(false)
	
	var player = get_tree().current_scene.get_node("Player")
	player.set_process(false)
	
	# Fade in
	if fade_rect:
		fade_rect.visible = true
		fade_rect.modulate.a = 0
		var t = fade_rect.create_tween()
		t.tween_property(fade_rect, "modulate:a", 1.0, 1.5)
		t.tween_callback(Callable(self, "_load_win_scene"))
		t.play()
	else:
		_load_win_scene()

func _load_win_scene():
	get_tree().change_scene_to_file(WIN_SCENE_PATH)
