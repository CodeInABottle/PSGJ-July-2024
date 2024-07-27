class_name BattlefieldPlayerEntity
extends BattlefieldEntity

@export var attack_position: Marker2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _tween: Tween

func take_damage(damage_data: Dictionary) -> void:
	if damage_data["damage"] == 0: return

	animation_player.play("Hurt")
	entity_tracker.damage_taken.emit(true, damage_data)
	print("Player taken damage: ", damage_data["damage"])
	PlayerStats.health -= damage_data["damage"]

func heal(value: int) -> void:
	print("Player healed: ", value)
	PlayerStats.health += value

func regen_ap() -> void:
	PlayerStats.regen_alchemy_points(ap_penality)
	ap_penality = 0

func attack(ability_name: String) -> void:
	# Visual Attack Logic
	var ability_data: Dictionary = EnemyDatabase.get_ability_attack(ability_name)
	var enemy_position: Vector2 = entity_tracker.enemy_entity.get_attack_position()

	if ability_data["attack"] == null:
		if _tween:
			_tween.kill()
		_tween = create_tween()
		_tween.tween_callback(
			func() -> void:
				_internal_attack_logic(ability_name)
		)
	else:
		var attack_packed_scene: Node2D = (ability_data["attack"] as PackedScene).instantiate()
		attack_node.add_child(attack_packed_scene)
		if ability_data["is_moving"]:
			attack_node.global_position = attack_position.global_position
			if _tween:
				_tween.kill()
			_tween = create_tween()
			print("Enemy position: ", enemy_position)
			_tween.tween_property(attack_node, "global_position", enemy_position, ability_data["movement_speed"])
			_tween.tween_callback(
				func() -> void:
					attack_packed_scene.queue_free()
					_internal_attack_logic(ability_name)
			)
		else:
			attack_packed_scene.global_position = enemy_position
			await get_tree().create_timer(ability_data["life_time"]).timeout
			attack_packed_scene.queue_free()
			_internal_attack_logic(ability_name)

func _internal_attack_logic(ability_name: String) -> void:
	var damage_data: Dictionary = EnemyDatabase.get_ability_damage_data(ability_name)
	entity_tracker.enemy_entity.take_damage(damage_data)
	var ability: BattlefieldAbility = EnemyDatabase.get_ability_data(ability_name)
	entity_tracker.add_modification_stacks(ability)
	actions_done += 1
