class_name ShadowDetailsContainer
extends PanelContainer

@export var name_label: Label
@export var type_label: Label
@export var move_labels: Array[Label]

func update_details(shadow_name: String) -> void:
	var enemy_data: BattlefieldEnemyData = EnemyDatabase.get_enemy_data(shadow_name)
	if enemy_data:
		name_label.text = enemy_data.name
		type_label.text = TypeChart.ResonateType.find_key(enemy_data.resonate)
		
		hide_moves()
		
		var ability_index: int = 0
		for ability: BattlefieldAbility in enemy_data.abilities:
			move_labels[ability_index].text = ability.name
			move_labels[ability_index].show()
			ability_index += 1

func hide_moves() -> void:
	for label: Label in move_labels:
		label.hide()
