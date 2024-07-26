class_name BattlefieldReagentDropLocation
extends Node2D

const WATER_REAGENT: PackedScene = preload("res://battle_systems/Objects/Reagent/AnimatedReagents/water_reagent.tscn")
const WATER_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WaterOrbStill.png")
const FIRE_REAGENT: PackedScene = preload("res://battle_systems/Objects/Reagent/AnimatedReagents/fire_reagent.tscn")
const FIRE_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/FireOrbStill.png")
const EARTH_REAGENT: PackedScene = preload("res://battle_systems/Objects/Reagent/AnimatedReagents/earth_reagent.tscn")
const EARTH_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/EarthOrbStill.png")
const WIND_REAGENT: PackedScene = preload("res://battle_systems/Objects/Reagent/AnimatedReagents/wind_reagent.tscn")
const WIND_ORB_STILL: Texture = preload("res://assets/sprites/combat/Reagents/WindOrbStill.png")

signal ability_execute_requested(ability_name: String)

class Data:
	var follow_node: PathFollow2D
	var animated_sprite: AnimatedSprite2D
	var reagent: TypeChart.ResonateType

@export var speed: float = 10.0
@export var reagents: Array[BattlfieldReagent] = []

@onready var path_2d: Path2D = %Path2D
@onready var recipe_controller: BattlefieldRecipeController = %RecipeController
@onready var text_box_animator: AnimationPlayer = %TextBoxAnimator
@onready var description_label: Label = %DescriptionLabel
@onready var combine_point: Marker2D = %CombinePoint
@onready var apex_point: Marker2D = %ApexPoint

var _reagent_data: Array[Data] = []
var _equipped_ability_cache: PackedStringArray
var _description_out: bool = false
var _tween: Tween
var _ability_activated: bool = false
var entity_tracker: BattlefieldEntityTracker
var control_shield: Panel

func _ready() -> void:
	_equipped_ability_cache = PlayerStats.get_all_equipped_abilities()
	recipe_controller.pressed.connect(_on_recipe_chosen)
	text_box_animator.animation_finished.connect(
		func(animation_name: String) -> void:
			if animation_name != "SlideOut": return
			description_label.text = ""
	)
	recipe_controller.mouse_hovered.connect(
		func(ability_name: String) -> void:
			if is_holding_something(): return

			var info: Dictionary = EnemyDatabase.get_ability_info(ability_name)
			if info.is_empty(): return

			description_label.text = "Damage: " + str(info["damage"])
			if not info["description"].is_empty():
				description_label.text += "\nAdditional Effects:\n" + info["description"]
			text_box_animator.play("SlideIn")
			_description_out = true
	)
	recipe_controller.mouse_left.connect(
		func(_ability_name: String) -> void:
			if not _description_out: return

			text_box_animator.play("SlideOut")
			_description_out = false
	)

func _physics_process(delta: float) -> void:
	if _ability_activated: return

	for data: Data in _reagent_data:
		if data.is_queued_for_deletion(): continue

		data.follow_node.progress_ratio += delta * speed
		data.animated_sprite.global_rotation_degrees = 0
		if data.follow_node.progress_ratio > 0.5:
			data.animated_sprite.z_index = -1
		else:
			data.animated_sprite.z_index = 1

func add(reagent: TypeChart.ResonateType) -> void:
	if reagent == TypeChart.ResonateType.NONE:
		clear()
		return
	_create_floating_reagent(reagent)
	_validate_recipe()

func clear(return_ap:bool = true) -> void:
	for data: Data in _reagent_data:
		if data.is_queued_for_deletion(): continue
		if return_ap:
			PlayerStats.alchemy_points += entity_tracker.player_entity.get_cost(data.reagent)
		data.follow_node.queue_free()
	_reagent_data.clear()
	recipe_controller.hide_pages()

func is_holding_something() -> bool:
	for reagent: BattlfieldReagent in reagents:
		if reagent.is_holding(): return true
	return false

func _validate_recipe() -> void:
	# Run validation checks
	var valid_recipies: Array[Dictionary] = []
	for equipped_ability_name: String in _equipped_ability_cache:
		var components: Array[TypeChart.ResonateType] = EnemyDatabase.get_ability_recipe(equipped_ability_name)
		if _is_valid_recipe(components):
			valid_recipies.push_back({
				"name": equipped_ability_name,
				"type": EnemyDatabase.get_ability_resonance(equipped_ability_name),
				"textures": EnemyDatabase.get_ability_recipe_textures(equipped_ability_name)
			})

	if valid_recipies.is_empty():
		recipe_controller.hide_pages()
	else:
		# Passed checks
		recipe_controller.set_data(valid_recipies)

func _is_valid_recipe(components: Array[TypeChart.ResonateType]) -> bool:
	if components.is_empty(): return false
	if _reagent_data.is_empty(): return false
	if components.size() != _reagent_data.size(): return false

	# Check if recipe is valid for each component
	var component_copy: Array[TypeChart.ResonateType] = components.duplicate(true)
	for data: Data in _reagent_data:
		if data.reagent in component_copy:
			component_copy.erase(data.reagent)

		if component_copy.is_empty():
			return true

	return false

func _create_floating_reagent(reagent: TypeChart.ResonateType) -> void:
	var ap_cost: int = entity_tracker.player_entity.get_cost(reagent)
	if PlayerStats.alchemy_points >= ap_cost:
		PlayerStats.alchemy_points -= ap_cost
	else:
		return

	# Create pathfollow2D
	var follow_instance: PathFollow2D = PathFollow2D.new()
	path_2d.add_child(follow_instance)
	if _reagent_data.size() > 0:
		var offset: float = _reagent_data[-1].follow_node.progress_ratio + 1.0 / (_reagent_data.size() + 1)
		while offset >= 1.0:
			offset -= 1.0
		follow_instance.progress_ratio = offset

	# Create the animated orb
	var animated_reagent: AnimatedSprite2D
	match reagent:
		TypeChart.ResonateType.WATER:
			animated_reagent = WATER_REAGENT.instantiate()
		TypeChart.ResonateType.FIRE:
			animated_reagent = FIRE_REAGENT.instantiate()
		TypeChart.ResonateType.EARTH:
			animated_reagent = EARTH_REAGENT.instantiate()
		TypeChart.ResonateType.AIR:
			animated_reagent = WIND_REAGENT.instantiate()
	follow_instance.add_child(animated_reagent)


	# Set Data
	var data: Data = Data.new()
	data.follow_node = follow_instance
	data.animated_sprite = animated_reagent
	data.reagent = reagent
	_reagent_data.push_back(data)

func _on_recipe_chosen(ability_name: String) -> void:
	control_shield.show()
	await text_box_animator.animation_finished
	_ability_activated = true

	# Reset the tween
	if _tween:
		_tween.kill()
	_tween = create_tween()

	# Detach from path follow and "craft"
	for data: Data in _reagent_data:
		var reagent_orb: AnimatedSprite2D = data.follow_node.get_child(0)
		var global_pos: Vector2 = reagent_orb.global_position
		data.follow_node.remove_child(reagent_orb)
		add_child(reagent_orb)
		reagent_orb.z_index = 5
		reagent_orb.global_rotation_degrees = 0
		reagent_orb.global_position = global_pos

		_tween.tween_property(reagent_orb, "global_position", apex_point.global_position, 0.1)
		_tween.tween_property(reagent_orb, "global_position", combine_point.global_position, 0.25)
		_tween.tween_property(reagent_orb, "self_modulate", Color(1, 1, 1, 0), 0.1)
		_tween.tween_callback(reagent_orb.queue_free)

	# Clear cache here
	clear(false)

	# Report attack
	_tween.tween_callback(
		func() -> void:
			ability_execute_requested.emit(ability_name)
			_ability_activated = false
			control_shield.hide()
	)
