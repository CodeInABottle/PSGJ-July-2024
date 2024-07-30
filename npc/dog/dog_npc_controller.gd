class_name DogNPC
extends BaseNPC

@export var pet_manager: Petter

func _ready() -> void:
	detection_area.body_entered.connect(on_body_entered_detect_area)
	detection_area.body_exited.connect(on_body_exited_detect_area)
	detection_area.get_child(0).shape.radius = notice_radius
	LevelManager.world_event_occurred.connect(on_world_event)
	pet_manager.pet_started.connect(on_pet_started)
	pet_manager.pet_stopped.connect(on_pet_stopped)
	
	if SaveManager.load_pending:
		PlayerStats.save_loaded.connect(init_npc)
	else:
		init_npc.call_deferred()

func wait_at_point(_world_state: Dictionary) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var wait_time: float = rng.randf_range(0.5, 5.0)
	var chance: float = rng.randf_range(0.0, 100.0)
	if chance < 50.0:
		npc_sprite.play("wag")
	else:
		npc_sprite.play("idle")
	await get_tree().create_timer(wait_time).timeout

func on_pet_started() -> void:
	npc_sprite.z_index = 2
	_is_being_pet = true

func on_pet_stopped() -> void:
	npc_sprite.z_index = 0
	_is_being_pet = false
	petting_finished.emit()

func get_pet(_world_state: Dictionary) -> void:
	npc_sprite.play("wag")
	move_and_slide()
