@tool
class_name HTNMethodNode
extends HTNBaseNode

const PREFIX := "Method - "

var _priority: int = 0
var _nick_name: String:
	set(value):
		_nick_name = value
		HTNGlobals.node_name_altered.emit()
		if value == "":
			title = "Method"
		else:
			title = PREFIX + value

var condition_data: Dictionary = {}:
	set(value):
		condition_data = value
		_update_tool_tip()

func get_node_name() -> String:
	if not _nick_name.is_empty():
		return _nick_name
	return ""

func get_node_type() -> String:
	return "Method"

func validate_self() -> String:
	if condition_data.is_empty():
		return "There are no conditions set."
	else:
		for world_state_key: String in condition_data:
			if world_state_key != "": continue
			return "Missing WorldStateKey field for at least one condition."
		return ""

func load_data(data: Dictionary) -> void:
	_nick_name = data["nickname"]
	condition_data = data["condition_data"]
	_priority = data["priority"]
	%SpinBox.value = _priority

func get_data() -> Dictionary:
	return {
		"condition_data": condition_data,
		"nickname": _nick_name,
		"priority": get_priority()
	}

func get_priority() -> int:
	return _priority

func _update_tool_tip() -> void:
	if condition_data.is_empty():
		tooltip_text = ""
		return
	var text: String = ""
	for key: String in condition_data.keys():
		if key == "AlwaysTrue":
			tooltip_text = ""
			return
		if condition_data[key]["CompareID"] == 5:	# Range
			text += str(condition_data[key]["Value"].x)
			if condition_data[key]["RangeInclusivity"][0]:
				text += " <= " + key
			else:
				text += " < " + key
			if condition_data[key]["RangeInclusivity"][1]:
				text += " <= " + str(condition_data[key]["Value"].y)
			else:
				text += " < " + str(condition_data[key]["Value"].y)
		else:
			text += key
			match condition_data[key]["CompareID"]:
				0:	# >
					text += " > " + str(condition_data[key]["Value"])
				1:	# <
					text += " < " + str(condition_data[key]["Value"])
				2:	# ==
					text += " == " + str(condition_data[key]["Value"])
				3:	# >=
					text += " >= " + str(condition_data[key]["Value"])
				4:	# <=
					text += " <= " + str(condition_data[key]["Value"])
		text += "\n"
	tooltip_text = text

func _on_conditions_pressed() -> void:
	HTNGlobals.condition_editor.open(self, condition_data)

func _on_spin_box_value_changed(value: float) -> void:
	_priority = int(value)
	HTNGlobals.current_graph.is_saved = false
