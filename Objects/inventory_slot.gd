extends Panel

#controls the UI slot of the inventory

signal item_hovered (item)

var current_slot: InvSlot

@onready var item_visual : Sprite2D = $CenterContainer/Panel/itemDisplay
@onready var amount_text : Label = $CenterContainer/Panel/Label

@onready var item_description_label : Label = $"../../../NinePatchRect2/GridContainer/itemDescription"
@onready var item_name_label : Label = $"../../../NinePatchRect2/GridContainer/itemName"

func update(slot: InvSlot):
	current_slot = slot #makes sure the data is the same as slot which is what item the slot is containin, and can be referenced below
	if !slot.item: #if there's no item, the UI is off
		item_visual.visible = false
		amount_text.visible = false
	else: #if there's an item the UI is on
		item_visual.visible = true
		item_visual.texture = slot.item.texture #visible according to the item's texture
		if slot.amount > 1: 
			amount_text.visible = true
		amount_text.text = str(slot.amount) #changes the amount UI according to how the slot's resource data amount

func _on_slot_pressed() -> void:
	print("use or combine")

func _on_slot_mouse_entered() -> void:
	if !current_slot.item:
		item_description_label.text = ""
		item_name_label.text = "" 
	else:
		print(current_slot.item.description)
		item_description_label.text = current_slot.item.description
		item_name_label.text = current_slot.item.name # .text refers to the label's properti thats being changed to current_slot's description

func _on_slot_mouse_exited() -> void:
	item_description_label.text = ""
	item_name_label.text = "" #deletes text after mouse exits
