extends Node

const ITEM_DATABASE_PATH: String = "res://inventory/item_database/"

var item_database: Dictionary = {}

func _ready() -> void:
	var resource_files: PackedStringArray = DirAccess.get_files_at(ITEM_DATABASE_PATH)
	for resource_file: String in resource_files:
		var data: InventoryItem = load(ITEM_DATABASE_PATH + resource_file)
		if data == null: continue
		if data["item_name"] in item_database: continue

		item_database[data["item_name"]] = data

func get_item(item_name: String) -> InventoryItem:
	if item_database.keys().has(item_name):
		return item_database[item_name]	
	return null
