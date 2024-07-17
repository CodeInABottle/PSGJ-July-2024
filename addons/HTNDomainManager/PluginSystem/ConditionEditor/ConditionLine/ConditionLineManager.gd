@tool
class_name HTNConditionLine
extends VBoxContainer

## Compare IDs
#0:	# Greater Than
#1:	# Less Than
#2:	# Equal To
#3:	# Greater Than or Equal To
#4:	# Less Than or Equal To
#5:	# Range

## Single Type IDs
#0:	# Boolean
#1:	# Int
#2:	# Float
#3:	# String
#4:	# Vector2
#5:	# Vector3
#6:	# World State

## Range Type IDs
#0:	# Int
#1:	# Float

# Options
@onready var compare_option: OptionButton = %CompareOption
@onready var range_type_option: OptionButton = %RangeTypeOption
@onready var single_type_option: OptionButton = %SingleTypeOption
# Data
@onready var data_container: HBoxContainer = %DataContainer
@onready var is_true_toggle: CheckButton = %IsTrueToggle
@onready var string_value: LineEdit = %StringValue
@onready var x_value: SpinBox = %XValue
@onready var y_value: SpinBox = %YValue
@onready var z_value: SpinBox = %ZValue
# Labels
@onready var x_label: Label = %XLabel
@onready var y_label: Label = %YLabel
@onready var z_label: Label = %ZLabel
# CheckBoxes
@onready var x_check_box: CheckBox = %XCheckBox
@onready var y_check_box: CheckBox = %YCheckBox
# Other
@onready var range_separator: HSeparator = %RangeSeparator
@onready var world_state_line_editor: LineEdit = %WorldStateLineEditor

func initialize(data: Dictionary = {}) -> void:
	data_container.hide()
	if data.is_empty():
		_show_based_on_compare_type(0)
	else:	# Load data
		_load_data(data)

func get_data() -> Dictionary:
	var value
	if range_type_option.visible:
		if range_type_option.selected == 0:	# Int:
			value = Vector2i(x_value.value, y_value.value)
		else:	# Float
			value = Vector2(x_value.value, y_value.value)
	else:	# Single type option
		match single_type_option.selected:
			0:	# Boolean
				value = is_true_toggle.button_pressed
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
		"CompareID": compare_option.selected,
		"RangeID": range_type_option.selected if range_type_option.visible else -1,
		"SingleID": single_type_option.selected if single_type_option.visible else -1,
		"WorldState": world_state_line_editor.text,
		"Value": value,
		"RangeInclusivity": [x_check_box.button_pressed, y_check_box.button_pressed]
	}

func _load_data(data: Dictionary) -> void:
	world_state_line_editor.text = data["WorldState"]
	compare_option.select(data["CompareID"])
	_on_compare_option_item_selected(compare_option.selected)
	if data["RangeID"] > -1:
		range_type_option.select(data["RangeID"])
		x_check_box.set_pressed_no_signal(data["RangeInclusivity"][0])
		y_check_box.set_pressed_no_signal(data["RangeInclusivity"][1])
		_on_range_type_option_item_selected(data["RangeID"])
		if data["RangeID"] == 0:	# Int
			x_value.value = int(data["Value"].x)
			y_value.value = int(data["Value"].y)
		else:	# Float
			x_value.value = float(data["Value"].x)
			y_value.value = float(data["Value"].y)
	else:
		single_type_option.select(data["SingleID"])
		_on_single_type_option_item_selected(single_type_option.selected)
		match single_type_option.selected:
			0:	# Boolean
				is_true_toggle.set_pressed_no_signal(data["Value"])
			1:	# Int
				x_value.value = int(data["Value"])
			3, 6:	# String | World State
				string_value.text = data["Value"]
			var idx:
				if idx == 5:
					z_value.value = float(data["Value"].z)
				if idx >= 4:
					y_value.value = float(data["Value"].y)
				if idx == 2:
					x_value.value = float(data["Value"])
				else:
					x_value.value = float(data["Value"].x)

func _show_based_on_compare_type(idx: int) -> void:
	_hide_data_container()
	match idx:
		0, 1, 3, 4:
			range_type_option.hide()
			single_type_option.show()
			single_type_option.set_item_disabled(0, true)
			single_type_option.set_item_disabled(3, true)
			single_type_option.set_item_disabled(4, true)
			single_type_option.set_item_disabled(5, true)
			single_type_option.set_item_disabled(6, true)
			if single_type_option.selected != 1 and single_type_option.selected != 2:
				single_type_option.select(1)
			_show_based_on_single_type_ID(single_type_option.selected)
		2:	# Equals Only
			range_type_option.hide()
			single_type_option.show()
			_show_based_on_single_type_ID(single_type_option.selected)
		5:	# Range
			range_type_option.show()
			single_type_option.hide()
			_show_spin_box(0, "Start", true, true)
			_show_spin_box(1, "End", true, true)
			range_separator.show()
			data_container.show()

func _show_based_on_single_type_ID(idx: int) -> void:
	if not data_container.visible: data_container.show()
	_hide_data_fields()
	match idx:
		0:	# Boolean
			is_true_toggle.show()
		1:	# Int
			_show_spin_box(0, "Value: ", true, false)
		3:	# String
			string_value.placeholder_text = "Text..."
			string_value.show()
		6:	# World State
			string_value.placeholder_text = "World State..."
			string_value.show()
		_:	# Float Based Data Types
			var text: String = "Value: "
			if idx == 5:	# Vector3
				_show_spin_box(2, "Z: ", false, false)
			if idx >= 4:	# Vector2
				_show_spin_box(1, "Y: ", false, false)
				text = "X: "

			_show_spin_box(0, text, false, false)

func _show_spin_box(component_idx: int, label_text: String, is_rounded: bool, enable_checkbox: bool) -> void:
	var spin_box: SpinBox
	var label: Label
	match component_idx:
		0:	# X
			spin_box = x_value
			label = x_label
			if enable_checkbox: x_check_box.show()
		1:	# Y
			spin_box = y_value
			label = y_label
			if enable_checkbox: y_check_box.show()
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

func _hide_data_fields() -> void:
	is_true_toggle.hide()
	string_value.hide()
	x_value.hide()
	y_value.hide()
	z_value.hide()
	x_label.hide()
	y_label.hide()
	z_label.hide()

func _hide_data_container() -> void:
	_hide_data_fields()
	x_check_box.hide()
	y_check_box.hide()
	range_separator.hide()
	single_type_option.set_item_disabled(0, false)
	single_type_option.set_item_disabled(3, false)
	single_type_option.set_item_disabled(4, false)
	single_type_option.set_item_disabled(5, false)
	single_type_option.set_item_disabled(6, false)

func _on_delete_button_pressed() -> void:
	queue_free()

func _on_compare_option_item_selected(index: int) -> void:
	_show_based_on_compare_type(index)

func _on_range_type_option_item_selected(index: int) -> void:
	# True: Int | False: Float
	_show_spin_box(0, "Start", true if index == 0 else false, true)
	_show_spin_box(1, "End", true if index == 0 else false, true)

func _on_single_type_option_item_selected(index: int) -> void:
	_show_based_on_single_type_ID(index)

func _on_visibility_changed() -> void:
	if not is_node_ready(): return

	if visible:
		_on_compare_option_item_selected(compare_option.selected)
		if range_type_option.visible:
			_on_range_type_option_item_selected(range_type_option.selected)
		else:
			_on_single_type_option_item_selected(single_type_option.selected)
	else:
		_hide_data_container()
