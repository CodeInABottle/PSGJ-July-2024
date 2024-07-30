class_name ConditionalSpawner
extends Node2D

@export var npc_scene: PackedScene
@export var spawn_name: String
@export_enum("Shadow", "TempStatus") var spawn_type: String = "Shadow"

func _ready() -> void:
	match spawn_type:
		"Shadow":
			if PlayerStats.get_all_unlocked_shadows().has(spawn_name):
				var spawned_npc: Node = npc_scene.instantiate()
				add_child(spawned_npc)
		"TempStatus":
			if LevelManager.temp_statuses.has(spawn_name):
				var spawned_npc: Node = npc_scene.instantiate()
				add_child(spawned_npc)

