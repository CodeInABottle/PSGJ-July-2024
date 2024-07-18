class_name BattlefieldManager
extends Node

const AI_ENTITY = preload("res://battle_systems/EntityComponents/BaseAIEntity/ai_entity.tscn")

@onready var initiative_tracker: BattlefieldInitiativeTracker = %InitiativeTracker
@onready var combat_state_machine: BattlefieldCombatStateMachine = %CombatStateMachine
@onready var player_entity: BattlefieldPlayerEntity = %PlayerEntity
@onready var entity_spawn_location: Marker2D = %EntitySpawnLocation

var _finished_setup := false

# TEMP
func _ready() -> void:
	setup_battle("Chicken")

func setup_battle(enemy_name_encounter: String) -> void:
	initiative_tracker.register_entity(player_entity)
	_generate_AI(enemy_name_encounter)

	initiative_tracker.initialize_order()
	combat_state_machine.switch_state("InitiativeFetch")
	combat_state_machine.start()
	_finished_setup = true

func _physics_process(delta: float) -> void:
	if not _finished_setup: return

	combat_state_machine.update(delta)

func _generate_AI(enemy_name_encounter: String) -> void:
	var ai_entity_instance := AI_ENTITY.instantiate()
	entity_spawn_location.add_child(ai_entity_instance)
	ai_entity_instance.load_AI(EnemyDatabase.get_enemy_data(enemy_name_encounter))
	initiative_tracker.register_entity(ai_entity_instance)
