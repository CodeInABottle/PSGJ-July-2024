class_name SlottedMovesContainer
extends MarginContainer

const ABILITY_LABEL: LabelSettings = preload("res://ui/ShadowAlchemyBench/AbilityLabel.tres")

signal ability_hovered(ability_name: String)
signal ability_unhovered

@export var workbench_menu: WorkbenchMenu

@onready var ability_container: VBoxContainer = %AbilityContainer

func _ready() -> void:
	_create_label("None", false)

func refresh_slotted_moves() -> void:
	_clear()

	if workbench_menu.slotted_shadows.is_empty():
		_create_label("None", false)
	else:
		for slotted_shadow_name: String in workbench_menu.slotted_shadows:
			_add_shadow_moves(slotted_shadow_name)

func _clear() -> void:
	for child: Control in ability_container.get_children():
		if child.is_queued_for_deletion(): continue

		child.queue_free()

func _add_shadow_moves(shadow_name: String) -> void:
	var enemy_data: BattlefieldEnemyData = EnemyDatabase.get_enemy_data(shadow_name)
	if enemy_data == null: return
	for ability: BattlefieldAbility in enemy_data.abilities:
		_create_label(ability.name)

func _create_label(text: String, is_ability: bool = true) -> void:
	var label_instance: Label = Label.new()
	ability_container.add_child(label_instance)
	label_instance.label_settings = ABILITY_LABEL
	if is_ability:
		label_instance.mouse_filter = Control.MOUSE_FILTER_STOP
		label_instance.mouse_entered.connect(
			func() -> void:
				print(text)
				ability_hovered.emit(text)
		)
		label_instance.mouse_exited.connect(
			func() -> void:
				ability_unhovered.emit()
		)
		label_instance.text = "-" + text
	else:
		label_instance.text = text
