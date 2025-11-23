extends CanvasLayer
@onready var play: Control = $play
@onready var color_rect: ColorRect = $ColorRect
@onready var win: Control = $win
@export var minigame: Control
	
# targetobject.connect("theirsignal", our method)
func _on_button_pressed() -> void:
	play.visible = false
	minigame.visible = true
	
	#signal name has to be same
	minigame.connect("winsignal", togglewin)
	
func togglewin():
	minigame.visible = false
	win.visible = true
	AudioManager.play_sfx("clicksfx")
	GlobalState.puzzle_1 = true
	

func _on_exit_pressed() -> void:
	# for Canvas UI parent to dissapear on use
	print("dosomething")
	self.visible = false
