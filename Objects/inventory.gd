extends Control

var is_open = false

@onready var inv: Inv = preload("res://inventory/playerInv.tres")
@onready var slots:Array = $NinePatchRect/GridContainer.get_children()

func _process(delta):
	if Input.is_action_just_pressed("q"):
		if is_open:
			closeInv()
		else:
			openInv()
func _ready():
	update_slots()
	closeInv()
	
func update_slots():
	for i in range(min(inv.items.size(), slots.size())):
		slots[i].update(inv.items[i])
func openInv():
	is_open = true
	visible = true
	print("open inv called")
	
func closeInv():
	is_open = false
	visible = false
