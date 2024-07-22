class_name MoveDetailsContainer
extends PanelContainer

@export var name_label: Label
@export var type_label: Label
@export var damage_label: Label
@export var notes_label: Label
@export var efficiency_label: Label

@export var cost_labels: Array[Label]

func update_details(move_name: String) -> void:
	var move_data: Dictionary = EnemyDatabase.get_ability_info(move_name)
	if move_data:
		name_label.text = move_name
		damage_label.text = str(move_data.damage) + " DMG"
		notes_label.text = move_data.description
		efficiency_label.text = str(move_data.efficiency) + "x"
		type_label.text = TypeChart.ResonateType.find_key(move_data.resonate)
		
		hide_cost()
		
		var type_index: int = 0
		for type: TypeChart.ResonateType in move_data.cost:
			cost_labels[type_index].text = TypeChart.ResonateType.find_key(type)
			cost_labels[type_index].show()
			type_index += 1

func hide_cost() -> void:
	for label: Label in cost_labels:
		label.hide()
