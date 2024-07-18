class_name BattlefieldReagentDropLocation
extends Node2D

class Data:
	var follow_node: PathFollow2D
	var sprite: Sprite2D
	var reagent: TypeChart.ResonateType

@export var speed := 10.0
@export var reagent_holder: BattlefieldReagentHolder
@export var table: BattlefieldTable

@onready var path_2d: Path2D = %Path2D

var _reagents: Array[Data] = []
var mouse_entered := false

func _physics_process(delta: float) -> void:
	for data: Data in _reagents:
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

	var follow_instance := PathFollow2D.new()
	path_2d.add_child(follow_instance)
	if _reagents.size() > 0:
		var offset := _reagents[-1].follow_node.progress_ratio + 1.0 / (_reagents.size() + 1)
		while offset >= 1.0:
			offset -= 1.0
		follow_instance.progress_ratio = offset
	var sprite_instance := Sprite2D.new()
	follow_instance.add_child(sprite_instance)
	sprite_instance.scale = Vector2(0.25, 0.25)
	sprite_instance.texture = sprite
	var data := Data.new()
	data.follow_node = follow_instance
	data.sprite = sprite_instance
	data.reagent = reagent
	_reagents.push_back(data)
	table.battlefield_manager.alchemy_points -= 1

func clear() -> void:
	for data: Data in _reagents:
		if data.is_queued_for_deletion(): continue
		data.follow_node.queue_free()
		table.battlefield_manager.alchemy_points += 1
	_reagents.clear()

func _on_area_2d_mouse_entered() -> void:
	if reagent_holder.has_something():
		mouse_entered = true

func _on_area_2d_mouse_exited() -> void:
	mouse_entered = false
