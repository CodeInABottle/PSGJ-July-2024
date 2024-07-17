@tool
class_name HTNApplicatorNode
extends HTNBaseNode

@onready var edit_button: Button = $EditButton

var _nick_name: String:
	set(value):
		_nick_name = value
		HTNGlobals.node_name_altered.emit()
		if value.is_empty():
			title = "Applicator"
		else:
			title = "Applicator - " + value

var effect_data: Dictionary:
	set(value):
		effect_data = value
		_update_tool_tip()

func get_node_name() -> String:
	if not _nick_name.is_empty():
		return _nick_name
	return ""

func get_node_type() -> String:
	return "Applicator"

func validate_self() -> String:
	if effect_data.is_empty():
		return "There are no effects set."
	else:
		for world_state: StringName in effect_data.keys():
			if not world_state.is_empty(): continue
			return "Missing WorldStateKey field for efftect"
		return ""

func load_data(data) -> void:
	_nick_name = data["nickname"]
	effect_data = data["effect_data"]

func get_data() -> Dictionary:
	return {
		"effect_data": effect_data,
		"nickname": _nick_name
	}

func _update_tool_tip() -> void:
	if effect_data.is_empty():
		tooltip_text = ""
		return
	var text := ""
	for key: String in effect_data:
		text += key + " = " + str(effect_data[key]["Value"])
		text += "\n"
	tooltip_text = text

func _on_edit_button_pressed() -> void:
	HTNGlobals.effect_editor.open(self, effect_data)
