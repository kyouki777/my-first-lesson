extends Control

@onready var input_line = $AnswerInput
@onready var keypad = $GridContainer
@onready var sfx_click: AudioStreamPlayer = $SFX_Click

func _ready():
	for button in keypad.get_children():
		button.focus_mode = Control.FOCUS_NONE  # 👈 prevents Enter key triggering last button
		button.connect("pressed", Callable(self, "_on_button_pressed").bind(button.text))

	input_line.editable = false
	set_process_input(true)
	grab_focus()


func _on_button_pressed(value: String):
	match value:
		"C":
			input_line.text = ""  # Clear all
		"←", "Backspace":
			if input_line.text.length() > 0:
				input_line.text = input_line.text.substr(0, input_line.text.length() - 1)
		_:
			if value.is_valid_int():
				input_line.text += value

	_play_click()
	input_line.caret_column = input_line.text.length()


func _input(event):
	if not visible:
		return  # ignore inputs when UI hidden

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_BACKSPACE:
				if input_line.text.length() > 0:
					input_line.text = input_line.text.substr(0, input_line.text.length() - 1)
					_play_click()
			KEY_ENTER, KEY_KP_ENTER:
				# Do nothing so Enter doesn’t trigger last clicked button
				pass
			KEY_C:
				input_line.text = ""
				_play_click()
			_:
				var key = OS.get_keycode_string(event.keycode)
				if key.is_valid_int():
					input_line.text += key
					_play_click()


func _play_click():
	if sfx_click:
		sfx_click.play()
