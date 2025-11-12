extends ColorRect

@onready var line_edit: LineEdit = $PasswordEntry
@onready var submit_button: Button = $SubmitButton
@onready var incorrect_label: Label = $IncorrectLabel
@onready var player: Node = null

@export var caretaker_scene: PackedScene
@export var spawn_point_name: String = "CaretakerSpawn"
@onready var sound_player: AudioStreamPlayer = $SuccessSound

var ui_open := true
var typing := false
var caretaker_spawned := false

func _ready() -> void:
	player = get_tree().get_root().find_child("Player", true, false)

	if line_edit:
		line_edit.connect("text_submitted", Callable(self, "_on_text_submitted"))
		line_edit.connect("focus_entered", Callable(self, "_on_focus_entered"))
		line_edit.connect("focus_exited", Callable(self, "_on_focus_exited"))
		line_edit.connect("text_changed", Callable(self, "_on_text_changed"))

	if submit_button:
		submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))

	if incorrect_label:
		incorrect_label.visible = false

func _on_text_changed(new_text: String) -> void:
	var filtered_text := ""
	for c in new_text:
		if c.is_valid_int():
			filtered_text += c
	line_edit.text = filtered_text
	line_edit.caret_column = filtered_text.length()

func _input(event: InputEvent) -> void:
	if not typing and event.is_action_pressed("ui_interact"):
		ui_open = !ui_open
		visible = ui_open
		if ui_open:
			line_edit.grab_focus()
		else:
			line_edit.release_focus()

func _on_submit_pressed() -> void:
	_on_text_submitted(line_edit.text)

func _on_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() == "121818113":
		visible = false
		ui_open = false
		line_edit.text = ""
		line_edit.release_focus()

		if not caretaker_spawned:
			var delay = randf_range(3.0, 8.0)  # for testing, seconds; use 180–480 for minutes
			print("Caretaker will spawn in ", delay, " seconds...")
			_start_caretaker_timer(delay)
			caretaker_spawned = true
	else:
		_show_incorrect_message()
		line_edit.text = ""
		line_edit.grab_focus()

func _start_caretaker_timer(delay: float) -> void:
	var timer := Timer.new()
	timer.wait_time = delay
	timer.one_shot = true
	add_child(timer)
	timer.connect("timeout", Callable(self, "_spawn_caretaker"))
	timer.start()

func _spawn_caretaker() -> void:
	print("Caretaker spawning now...")

	if not caretaker_scene:
		push_warning("⚠ Caretaker scene not assigned!")
		return

	var caretaker_instance = caretaker_scene.instantiate()

	# Find spawn point anywhere in the tree
	var spawn_point = get_tree().get_root().find_child(spawn_point_name, true, false)
	if spawn_point and spawn_point is Node2D:
		caretaker_instance.global_position = spawn_point.global_position
	else:
		print("⚠ Spawn point not found, spawning at (0,0)")
		caretaker_instance.global_position = Vector2.ZERO

	# Add to current scene
	get_tree().current_scene.add_child(caretaker_instance)

	# Play sound
	if sound_player:
		sound_player.play()

	

func _show_incorrect_message() -> void:
	if incorrect_label:
		incorrect_label.visible = true
		var tween := create_tween()
		tween.tween_interval(2.0)
		tween.tween_callback(Callable(incorrect_label, "hide"))

func _on_focus_entered() -> void:
	typing = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_focus_exited() -> void:
	typing = false
