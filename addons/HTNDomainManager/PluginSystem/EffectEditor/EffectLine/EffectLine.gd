@tool
class_name HTNEffectLine
extends VBoxContainer

## Type IDs
#0:	# Boolean
#1:	# Int
#2:	# Float
#3:	# String
#4:	# Vector2
#5:	# Vector3
#6:	# World State

# Components
@onready var world_state_line_edit: LineEdit = %WorldStateLineEdit
@onready var type_option_button: OptionButton = %TypeOptionButton
# Containers
@onready var data_container: HBoxContainer = %DataContainer
# Data
@onready var string_value: LineEdit = %StringValue
@onready var bool_value: CheckButton = %BoolValue
@onready var x_label: Label = %XLabel
@onready var x_value: SpinBox = %XValue
@onready var y_label: Label = %YLabel
@onready var y_value: SpinBox = %YValue
@onready var z_label: Label = %ZLabel
@onready var z_value: SpinBox = %ZValue

func initialize(data: Dictionary) -> void:
	if data.is_empty():
		_on_type_option_button_item_selected(0)
	else:
		_load_data(data)

func get_data() -> Dictionary:
	var value
	match type_option_button.selected:
		0:	# Boolean
			value = bool_value.button_pressed
		1:	# Int
			value = int(x_value.value)
		2:	# Float
			value = float(x_value.value)
		3, 6:	# String | World State
			value = string_value.text
		4:	# Vector2
			value = Vector2(x_value.value, y_value.value)
		5:	# Vector3
			value = Vector3(x_value.value, y_value.value, z_value.value)

	return {
		"WorldState": world_state_line_edit.text,
		"TypeID": type_option_button.selected,
		"Value": value
	}

func _load_data(data: Dictionary) -> void:
	world_state_line_edit.text = data["WorldState"]
	type_option_button.select(data["TypeID"])
	_on_type_option_button_item_selected(data["TypeID"])
	match type_option_button.selected:
		0:	# Boolean
			bool_value.set_pressed_no_signal(data["Value"])
		1:	# Int
			x_value.value = int(data["Value"])
		2:	# Float
			x_value.value = float(data["Value"])
		3, 6:	# String | World State
			string_value.text = data["Value"]
		4:	# Vector2
			x_value.value = data["Value"].x
			y_value.value = data["Value"].y
		5:	# Vector3
			x_value.value = data["Value"].x
			y_value.value = data["Value"].y
			z_value.value = data["Value"].z

func _show_spin_box(component_idx: int, label_text: String, is_rounded: bool) -> void:
	var spin_box: SpinBox
	var label: Label
	match component_idx:
		0:	# X
			spin_box = x_value
			label = x_label
		1:	# Y
			spin_box = y_value
			label = y_label
		2:	# Z
			spin_box = z_value
			label = z_label
	# SpinBox
	spin_box.step = 1 if is_rounded else 0.1
	spin_box.rounded = is_rounded
	spin_box.show()
	# Label
	label.text = label_text
	label.show()

func _hide_data() -> void:
	string_value.hide()
	bool_value.hide()
	x_label.hide()
	x_value.hide()
	y_label.hide()
	y_value.hide()
	z_label.hide()
	z_value.hide()
	data_container.hide()

func _on_delete_button_pressed() -> void:
	queue_free()

func _on_type_option_button_item_selected(index: int) -> void:
	_hide_data()
	match index:
		0:	# Boolean
			bool_value.show()
		1:	# Int
			_show_spin_box(0, "X: ", true)
		2:	# Float
			_show_spin_box(0, "X: ", false)
		3:	# String
			string_value.placeholder_text = "Text..."
			string_value.show()
		4:	# Vector2
			_show_spin_box(0, "X: ", false)
			_show_spin_box(1, "Y: ", false)
		5:	# Vector3
			_show_spin_box(0, "X: ", false)
			_show_spin_box(1, "Y: ", false)
			_show_spin_box(2, "Z: ", false)
		6:	# World State
			string_value.placeholder_text = "World State Key..."
			string_value.show()
	data_container.show()

func _on_visibility_changed() -> void:
	if not type_option_button: return

	if visible:
		_on_type_option_button_item_selected(type_option_button.selected)
	else:
		_hide_data()
