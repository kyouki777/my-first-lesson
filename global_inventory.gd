extends Node

var collected_items: Array = []
var all_parts := ["Motherboard", "CPU", "RAM", "Storage", "Power Supply"]

signal all_parts_collected

func add_item(item_name: String):
	if item_name not in collected_items:
		collected_items.append(item_name)
		print("Collected:", item_name)
		check_completion()

func has_item(item_name: String) -> bool:
	return item_name in collected_items

func check_completion():
	if collected_items.size() == all_parts.size():
		print("✅ All parts collected!")
		emit_signal("all_parts_collected")
