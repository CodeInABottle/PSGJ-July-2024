class_name MoveDetailsContainer
extends MarginContainer

@onready var name_label: Label = %NameLabel
@onready var component_container: HBoxContainer = %Components
@onready var components: Array[TextureRect] = [
	%TextureRect, %TextureRect2, %TextureRect3, %TextureRect4
]
@onready var damage_type_label: Label = %DamageTypeLabel
@onready var description_label: Label = %DescriptionLabel

# Tag [Shadow Name | Ability Name]
func update_sign_details(tag: String, is_ability: bool) -> void:
	if is_ability:
		_set_ability_details(tag)
		name_label.show()
		component_container.show()
		damage_type_label.show()
	else:
		_set_shadow_details(tag)

func clear() -> void:
	name_label.hide()
	component_container.hide()
	damage_type_label.hide()
	description_label.text = "Hover over an ability for more information."

func _set_ability_details(move_name: String) -> void:
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

func _set_shadow_details(shadow_name: String) -> void:
	component_container.hide()
	damage_type_label.hide()
	name_label.text = shadow_name
	name_label.show()
	var abilities: Array[String] = EnemyDatabase.get_abilities_from_shadow(shadow_name)
	description_label.text = ""
	for ability_name: String in abilities:
		description_label.text += "- " + ability_name + "\n"
	description_label.show()
