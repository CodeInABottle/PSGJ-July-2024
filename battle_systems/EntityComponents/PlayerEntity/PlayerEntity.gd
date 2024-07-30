class_name BattlefieldPlayerEntity
extends BattlefieldEntity

@export var attack_position: Marker2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _tween: Tween

func take_damage(damage_data: Dictionary) -> void:
	if damage_data["damage"] == 0: return

	LevelManager.audio_anchor.play_sfx("attack_hit")
	animation_player.play("Hurt")
	entity_tracker.damage_taken.emit(true, damage_data)
	PlayerStats.health -= damage_data["damage"]
	_spawn_damage_number(damage_data["damage"], true)

func heal(value: int) -> void:
	PlayerStats.health += value
	_spawn_damage_number(value, false)

func regen_ap() -> void:
	PlayerStats.regen_alchemy_points(ap_penality)
	if ap_penality > 0:
		_play_ap_effect()
	ap_penality = 0

func attack(ability_name: String) -> void:
	# Visual Attack Logic
	var ability_data: Dictionary = EnemyDatabase.get_ability_attack(ability_name)
	var enemy_position: Vector2 = entity_tracker.enemy_entity.get_attack_position()

	entity_tracker.attack_prompt.set_data("Blob", ability_name)

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
	var ability: BattlefieldAbility = EnemyDatabase.get_ability_data(ability_name)

	# Record for AI use
	entity_tracker.enemy_entity.short_term_memory.push_back({
		"damage": damage_data["damage"],
		"ap_used": ability.ap_cost
	})

	entity_tracker.enemy_entity.take_damage(damage_data)
	entity_tracker.add_modification_stacks(ability)
	actions_done += 1
