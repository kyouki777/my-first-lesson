extends Control

var is_open = false

@onready var inv: Inv = preload("res://inventory/playerInv.tres")
@onready var slots:Array = $NinePatchRect/GridContainer.get_children()

@onready var item_name = $NinePatchRect2/GridContainer/itemName
@onready var item_description = $NinePatchRect2/GridContainer/itemDescription

func _process(delta):
	if Input.is_action_just_pressed("q"):
		if is_open:
			closeInv()
		else:
			openInv()

func _ready():
	inv.update.connect(update_slots)
	update_slots()
	closeInv()
	
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func openInv():
	is_open = true
	visible = true
	print("open inv called")
	
func closeInv():
	is_open = false
	visible = false
	
func _on_item_hovered(item: InvItem) -> void:
	print("on item hovered")
	item_description.text = item.description
