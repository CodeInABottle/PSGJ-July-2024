class_name BattlefieldAIEntity
extends BattlefieldEntity

signal actions_completed

@export var max_health: int = 200

@onready var htn_planner: HTNPlanner = %HTNPlanner

var health: int

func _ready() -> void:
	health = max_health

func update(delta: float) -> void:
	pass

func issue_actions() -> void:
	pass
