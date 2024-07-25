class_name BattlefieldPlayerEntity
extends BattlefieldEntity

@export var attack_position: Marker2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _tween: Tween

func take_damage(damage_data: Dictionary) -> void:
	if damage_data["damage"] == 0: return

	animation_player.play("Hurt")
	entity_tracker.damage_taken.emit(true, damage_data)
	PlayerStats.health -= damage_data["damage"]

func heal(value: int) -> void:
	PlayerStats.health += value

func attack(ability_name: String) -> void:
	# Visual Attack Logic
	var attack_data: Dictionary = EnemyDatabase.get_ability_attack(ability_name)
	var enemy_position: Vector2 = entity_tracker.enemy_entity.get_attack_position()
	var attack_instance: Node2D = (attack_data["attack"] as PackedScene).instantiate()
	attack_node.add_child(attack_instance)
	if attack_data["is_moving"]:
		attack_node.global_position = attack_position.global_position
		if _tween:
			_tween.kill()
		_tween = create_tween()
		print("Enemy position: ", enemy_position)
		_tween.tween_property(attack_node, "global_position", enemy_position, attack_data["movement_speed"])
		_tween.tween_callback(
			func() -> void:
				attack_instance.queue_free()
				_internal_attack_logic(ability_name)
		)
	else:
		attack_instance.global_position = enemy_position
		await get_tree().create_timer(attack_data["life_time"]).timeout
		attack_instance.queue_free()
		_internal_attack_logic(ability_name)


func _internal_attack_logic(ability_name: String) -> void:
	var damage_data: Dictionary = EnemyDatabase.get_ability_damage_data(ability_name)
	entity_tracker.enemy_entity.take_damage(damage_data)
	entity_tracker.add_modification_stacks(EnemyDatabase.get_ability_data(ability_name))
