class_name OneshotLeashArea
extends LeashArea

func redirect_player() -> void:
	if hint_dialogue != null:
		PlayerStats.player.play_hint(hint_dialogue)
	PlayerStats.player.redirect(redirect_marker.get_global_position())
	queue_free()
