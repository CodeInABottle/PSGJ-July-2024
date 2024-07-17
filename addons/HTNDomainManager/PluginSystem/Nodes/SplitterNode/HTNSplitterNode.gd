@tool
class_name HTNSplitterNode
extends HTNBaseNode

@onready var nick_name: LineEdit = $NickName

func get_node_name() -> String:
	return nick_name.text

func get_node_type() -> String:
	return "Splitter"

func validate_self() -> String:
	return ""

func load_data(data: Dictionary) -> void:
	nick_name.text = data["nickname"]

func get_data() -> Dictionary:
	return {
		"nickname": get_node_name()
	}

func _on_nick_name_text_submitted(new_text: String) -> void:
	HTNGlobals.node_name_altered.emit()
