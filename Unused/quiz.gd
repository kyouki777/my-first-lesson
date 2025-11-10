extends CanvasLayer

@onready var question_label = $VBoxContainer/QuestionLabel
@onready var answer_input = $VBoxContainer/AnswerInput
@onready var submit_button = $VBoxContainer/SubmitButton
@onready var feedback_label = $VBoxContainer/FeedbackLabel
@onready var numpad_container = $VBoxContainer/GridContainer
@onready var score_label = $ScoreLabel

@onready var sfx_correct = $SFX_Correct
@onready var sfx_wrong = $SFX_Wrong
@onready var sfx_click = $SFX_Click
@onready var sfx_hum = $SFX_Hum
@onready var sfx_doorUnlocked = $SFX_DoorUnlocked

# Tilemap and area references
var floor_layer: TileMapLayer
var floor2_layer: TileMapLayer
var escape_zone_area: Area2D

var num1: int
var num2: int
var correct_answer: int
var operator: String
var score: int = 0
const TARGET_SCORE := 3

func _ready():
	var root = get_tree().current_scene
	floor_layer = root.get_node_or_null("Env/Floor")
	floor2_layer = root.get_node_or_null("Env/Floor2")
	escape_zone_area = root.get_node_or_null("Env/Floor2/EscapeZone")

	if not floor_layer:
		print("⚠ Floor layer not found!")
	if not floor2_layer:
		print("⚠ Floor2 layer not found!")
	if not escape_zone_area:
		print("⚠ EscapeZone not found!")

	randomize()
	submit_button.pressed.connect(_on_submit_pressed)
	answer_input.text_submitted.connect(_on_enter_pressed)
	answer_input.text_changed.connect(_on_text_changed)
	visibility_changed.connect(_on_visibility_changed)

	_build_numpad()
	generate_question()
	set_process_input(true)
	_update_score_label()


func _build_numpad():
	if not numpad_container:
		push_warning("⚠ numpad_container not found — check node name.")
		return

	var labels = ["1","2","3","4","5","6","7","8","9","0","←","C"]
	for lbl in labels:
		var btn = Button.new()
		btn.text = lbl
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(100, 60)
		numpad_container.add_child(btn)
		btn.pressed.connect(_on_numpad_pressed.bind(lbl))


func _on_numpad_pressed(label: String):
	sfx_click.play()
	match label:
		"C":
			answer_input.text = ""
		"←":
			if answer_input.text.length() > 0:
				answer_input.text = answer_input.text.substr(0, answer_input.text.length() - 1)
		_:
			answer_input.text += label
	answer_input.caret_column = answer_input.text.length()
	answer_input.deselect()
	answer_input.grab_focus()


func generate_question():
	num1 = randi_range(1, 10)
	num2 = randi_range(1, 10)
	var ops = ["+", "-", "×", "÷"]
	operator = ops[randi_range(0, ops.size() - 1)]

	match operator:
		"+":
			correct_answer = num1 + num2
		"-":
			if num2 > num1:
				var temp = num1
				num1 = num2
				num2 = temp
			correct_answer = num1 - num2
		"×":
			correct_answer = num1 * num2
		"÷":
			correct_answer = randi_range(1, 10)
			num2 = randi_range(1, 10)
			num1 = num2 * correct_answer

	question_label.text = "What is %d %s %d?" % [num1, operator, num2]
	feedback_label.text = ""
	answer_input.text = ""
	answer_input.grab_focus()


func _on_enter_pressed(_new_text: String):
	_on_submit_pressed()


func _on_submit_pressed():
	sfx_click.play()
	var text_input = answer_input.text.strip_edges()
	if text_input.is_valid_int():
		var user_answer = int(text_input)
		check_answer(user_answer)
	else:
		feedback_label.text = "Please enter a valid number."
	answer_input.grab_focus()


func check_answer(user_answer: int):
	if user_answer == correct_answer:
		feedback_label.text = "✅ Correct!"
		sfx_correct.play()
		score += 1
	else:
		feedback_label.text = "❌ Wrong! The answer was %d." % correct_answer
		sfx_wrong.play()
		score -= 1

	_update_score_label()
	_check_unlock_condition()

	await get_tree().create_timer(1.2).timeout
	generate_question()


func _update_score_label():
	score_label.text = "Score: %d" % score


func _check_unlock_condition():
	if score >= TARGET_SCORE:
		print("Door unlocked! Score reached: ", score)
		feedback_label.text = "🎉 Door unlocked!"

		if floor_layer:
			floor_layer.visible = false
			floor_layer.collision_enabled = false
			print("Floor 1 fully disabled")

			floor2_layer.visible = true
			sfx_doorUnlocked.play()
		if escape_zone_area:
			escape_zone_area.monitoring = true
			escape_zone_area.visible = true







func _on_text_changed(new_text: String):
	var filtered_text = ""
	for c in new_text:
		if c.is_valid_int() and c.length() == 1:
			filtered_text += c
	answer_input.text = filtered_text
	answer_input.caret_column = filtered_text.length()


func _input(event):
	if not visible:
		return

	if event is InputEventMouseButton and event.pressed:
		sfx_click.play()

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_BACKSPACE:
				if answer_input.has_focus():
					sfx_click.play()
			KEY_ENTER, KEY_KP_ENTER:
				if answer_input.has_focus():
					_on_submit_pressed()


func _on_visibility_changed():
	if visible:
		if not sfx_hum.playing:
			sfx_hum.play()
		answer_input.grab_focus()
	else:
		sfx_hum.stop()
