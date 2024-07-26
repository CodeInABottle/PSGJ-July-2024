class_name SlottedMovesContainer
extends MarginContainer

const ABILITY_ITEM: PackedScene = preload("res://ui/ShadowAlchemyBench/SlottedMovesPanel/AbilityItem/ability_item.tscn")

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
	var item_instance: HBoxContainer = ABILITY_ITEM.instantiate()
	ability_container.add_child(item_instance)
	if is_ability:
		var data: Dictionary = EnemyDatabase.get_ability_info(text)
		item_instance.mouse_entered.connect( func() -> void: ability_hovered.emit(text) )
		item_instance.mouse_exited.connect( func() -> void: ability_unhovered.emit() )
		item_instance.set_data("-" + text, TypeChart.get_symbol_texture(data["resonate"]))
	else:
		item_instance.set_data(text, null)
