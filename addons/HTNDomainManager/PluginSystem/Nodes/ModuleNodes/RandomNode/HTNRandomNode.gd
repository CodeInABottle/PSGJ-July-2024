@tool
class_name HTNRandomNode
extends HTNModuleBaseNode

@onready var type_option_button: OptionButton = %TypeOptionButton
@onready var min_max_container: HBoxContainer = %MinMaxContainer
@onready var min_value_spin_box: SpinBox = %MinValueSpinBox
@onready var max_value_spin_box: SpinBox = %MaxValueSpinBox

func initialize() -> void:
	super()
	_on_type_option_button_item_selected(type_option_button.selected)

func get_module_function_name() -> String:
	return "generate_random_number"

func get_node_type() -> String:
	return "RNG"

# Return value:
#	On valid: return "" (and empty string)
#	On invalid: return an error message string
func validate_self() -> String:
	return ""

func load_data(data: Dictionary) -> void:
	_on_type_option_button_item_selected(data["Type"])
	if data["Type"] == 0:	# Int
		min_value_spin_box.value = int(data["MinValue"])
		max_value_spin_box.value = int(data["MaxValue"])
	elif data["Type"] == 1:	# Float
		min_value_spin_box.value = float(data["MinValue"])
		max_value_spin_box.value = float(data["MaxValue"])

func get_data() -> Dictionary:
	var min_value
	var max_value
	if type_option_button.selected == 0:	# Int
		min_value = int(min_value_spin_box.value)
		max_value = int(max_value_spin_box.value)
	elif type_option_button.selected == 1:	# Float
		min_value = float(min_value_spin_box.value)
		max_value = float(max_value_spin_box.value)

	return {
		"Type": type_option_button.selected,
		"MinValue": min_value,
		"MaxValue": max_value
	}

func _configure_spin_boxes(is_int: bool) -> void:
	min_max_container.show()
	if is_int:
		min_value_spin_box.rounded = true
		min_value_spin_box.step = 1
		max_value_spin_box.rounded = true
		max_value_spin_box.step = 1
	else:
		min_value_spin_box.rounded = false
		min_value_spin_box.step = 0.1
		max_value_spin_box.rounded = false
		max_value_spin_box.step = 0.1

func _on_type_option_button_item_selected(index: int) -> void:
	if index == 0:	# Int
		_configure_spin_boxes(true)
	elif index == 1:	# Float
		_configure_spin_boxes(false)
	else:
		min_max_container.hide()
