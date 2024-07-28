class_name LeashArea
extends Area2D

@export_enum("DisableOnItem", "DisableOnShadow") var disable_type: String

@export var hint_dialogue: Dialogue

@export var redirect_marker: Marker2D
@export var disable_leash_name: String


func _ready() -> void:
	body_exited.connect(on_body_exited)
	is_disabled()

func is_disabled() -> bool:
	match disable_type:
		"DisableOnItem":
			var items: Dictionary = PlayerStats.get_inventory_items()
			if items.keys().has(disable_leash_name):
				queue_free()
				return true
			else:
				return false
		"DisableOnShadow":
			var unlocked_shadows: PackedStringArray = PlayerStats.get_all_unlocked_shadows()
			if unlocked_shadows.has(disable_leash_name):
				queue_free()
				return true
			else:
				return false
		_:
			return true

func on_body_exited(exited_body: Node2D) -> void:
	if not is_disabled():
		redirect_player()

func redirect_player() -> void:
	if hint_dialogue != null:
		PlayerStats.player.play_hint(hint_dialogue)
	PlayerStats.player.redirect(redirect_marker.get_global_position())
