class_name MoveDetailsContainer
extends MarginContainer

@onready var name_label: Label = %NameLabel
@onready var components: Array[TextureRect] = [
	%TextureRect, %TextureRect2, %TextureRect3, %TextureRect4
]
@onready var damage_type_label: Label = %DamageTypeLabel
@onready var description_label: Label = %DescriptionLabel

func update_details(move_name: String) -> void:
	var move_data: Dictionary = EnemyDatabase.get_ability_info(move_name)
	if move_data.is_empty(): return

	name_label.text = move_name
	damage_type_label.text = str(move_data.damage) + " DMG | Type: "\
		+ TypeChart.ResonateType.find_key(move_data.resonate)
	description_label.text = move_data.description

	for idx: int in 4:
		if idx < move_data.cost.size():
			var type: TypeChart.ResonateType = move_data.cost[idx]
			components[idx].texture = TypeChart.get_texture(type)
			components[idx].show()
		else:
			components[idx].hide()
