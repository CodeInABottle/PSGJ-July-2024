class_name BattlefieldReagentDropLocation
extends Node2D

signal ability_execute_requested(ability_name: String)

class Data:
	var follow_node: PathFollow2D
	var sprite: Sprite2D
	var reagent: TypeChart.ResonateType

@export var speed: float = 10.0
@export var reagent_holder: BattlefieldReagentHolder

@onready var path_2d: Path2D = %Path2D
@onready var recipe_page: BattlefieldRecipePage = %RecipePage

var _reagent_data: Array[Data] = []
var _equipped_ability_cache: PackedStringArray
var mouse_entered: bool = false

func _ready() -> void:
	recipe_page.hide()
	_equipped_ability_cache = PlayerStats.get_all_equipped_abilities()
	recipe_page.pressed.connect(
		func() -> void:
			var ability_name: String = recipe_page.get_ability_name()
			clear(false)
			ability_execute_requested.emit(ability_name)
	)

func _physics_process(delta: float) -> void:
	for data: Data in _reagent_data:
		data.follow_node.progress_ratio += delta * speed
		data.sprite.global_rotation_degrees = 0
		if data.follow_node.progress_ratio > 0.5:
			data.sprite.z_index = -1
		else:
			data.sprite.z_index = 1

func add(sprite: Texture, reagent: TypeChart.ResonateType) -> void:
	if reagent == TypeChart.ResonateType.NONE:
		clear()
		return

	_create_floating_reagent(sprite, reagent)
	_validate_recipe()

func clear(return_ap:bool = true) -> void:
	for data: Data in _reagent_data:
		if data.is_queued_for_deletion(): continue
		data.follow_node.queue_free()
		if return_ap:
			PlayerStats.alchemy_points += 1
	_reagent_data.clear()
	recipe_page.hide()

func _validate_recipe() -> void:
	# Run validation checks
	var valid_recipies: Array[String] = []
	for equipped_ability_name: String in _equipped_ability_cache:
		var components: Array[TypeChart.ResonateType] = EnemyDatabase.get_ability_recipe(equipped_ability_name)
		if _is_valid_recipe(components):
			valid_recipies.push_back(equipped_ability_name)

	if valid_recipies.is_empty():
		recipe_page.hide()
	else:
		# Passed checks
		recipe_page.show()
		var right_recipe: Texture = null
		if _reagent_data.size() > 1:
			right_recipe = _reagent_data[1].sprite.texture
		if valid_recipies.size() > 1:
			recipe_page.set_data(valid_recipies[0], _reagent_data[0].sprite.texture, right_recipe)
		else:
			recipe_page.set_data(valid_recipies[0], _reagent_data[0].sprite.texture, right_recipe)

func _is_valid_recipe(components: Array[TypeChart.ResonateType]) -> bool:
	if components.size() != _reagent_data.size(): return false

	var component_copy: Array[TypeChart.ResonateType] = components.duplicate(true)

	for data: Data in _reagent_data:
		if component_copy.is_empty():
			return false

		if data.reagent not in component_copy:
			return false
		component_copy.erase(data.reagent)

	return true

func _create_floating_reagent(sprite: Texture, reagent: TypeChart.ResonateType) -> void:
	# Create pathfollow2D
	var follow_instance: PathFollow2D = PathFollow2D.new()
	path_2d.add_child(follow_instance)
	if _reagent_data.size() > 0:
		var offset: float = _reagent_data[-1].follow_node.progress_ratio + 1.0 / (_reagent_data.size() + 1)
		while offset >= 1.0:
			offset -= 1.0
		follow_instance.progress_ratio = offset

	# Create Sprite
	var sprite_instance: Sprite2D = Sprite2D.new()
	follow_instance.add_child(sprite_instance)
	sprite_instance.scale = Vector2(0.25, 0.25)
	sprite_instance.texture = sprite

	# Set Data
	var data: Data = Data.new()
	data.follow_node = follow_instance
	data.sprite = sprite_instance
	data.reagent = reagent
	_reagent_data.push_back(data)
	PlayerStats.alchemy_points -= 1

func _on_area_2d_mouse_entered() -> void:
	if reagent_holder.has_something():
		mouse_entered = true

func _on_area_2d_mouse_exited() -> void:
	mouse_entered = false
