class_name OneshotHintArea
extends HintArea


func on_body_entered(entered_body: Node2D) -> void:
	if entered_body is Player:
		entered_body.play_hint(hint_dialogue)
		queue_free()
