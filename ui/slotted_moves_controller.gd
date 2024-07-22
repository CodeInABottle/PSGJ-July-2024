class_name SlottedMovesContainer
extends PanelContainer

signal move_selected(move_name: String)

@export var move_list: ItemList
@export var workbench_menu: WorkbenchMenu

func _ready() -> void:
	move_list.item_selected.connect(on_move_selected)

func refresh_slotted_moves() -> void:
	move_list.clear()
	for slotted_shadow_name: String in workbench_menu.slotted_shadows:
		add_shadow_moves(slotted_shadow_name)
	
	if workbench_menu.slotted_shadows.is_empty():
		hide()
	else:
		show()

func add_shadow_moves(shadow_name: String) -> void:
	var enemy_data: BattlefieldEnemyData = EnemyDatabase.get_enemy_data(shadow_name)
	if enemy_data:
		var ability_index: int = 0
		for ability: BattlefieldAbility in enemy_data.abilities:
			move_list.add_item(ability.name)
		
func on_move_selected(index: int) -> void:
	var move_name: String = move_list.get_item_text(index)
	move_selected.emit(move_name)

func clear_selection() -> void:
	move_list.deselect_all()
