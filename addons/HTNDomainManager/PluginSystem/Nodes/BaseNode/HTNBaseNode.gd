@tool
class_name HTNBaseNode
extends GraphNode

var _default_style_box_panel: StyleBoxFlat
var _default_style_box_titlebar: StyleBoxFlat

func initialize() -> void:
	_default_style_box_panel = get_theme_stylebox("panel")
	_default_style_box_titlebar = get_theme_stylebox("titlebar")
	dehighlight()

func get_node_name() -> String:
	return ""

func get_node_type() -> String:
	assert(false, "HTN Base Node Default Error Message")
	return ""

# Return value:
#	On valid: return "" (and empty string)
#	On invalid: return an error message string
func validate_self() -> String:
	return "HTN Base Node Default Error Message"

func load_data(_data: Dictionary) -> void:
	pass

func get_data() -> Dictionary:
	return {}

func highlight() -> void:
	var new_style_box_panel: StyleBoxFlat = _default_style_box_panel.duplicate()
	new_style_box_panel.border_width_left = 4
	new_style_box_panel.border_width_right = 4
	new_style_box_panel.border_width_bottom = 4
	var new_style_box_titlebar: StyleBoxFlat = _default_style_box_titlebar.duplicate()
	new_style_box_titlebar.border_width_left = 4
	new_style_box_titlebar.border_width_right = 4
	new_style_box_titlebar.border_width_top = 4
	add_theme_stylebox_override("panel", new_style_box_panel)
	add_theme_stylebox_override("titlebar", new_style_box_titlebar)

func dehighlight() -> void:
	add_theme_stylebox_override("panel", _default_style_box_panel)
	add_theme_stylebox_override("titlebar", _default_style_box_titlebar)
