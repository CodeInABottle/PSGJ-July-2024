extends Node2D

@onready var shadow: Sprite2D = %Shadow

var _original_shadow_frame_idx: int

func _ready() -> void:
	_original_shadow_frame_idx = shadow.frame

func set_shadow_frame(frame_idx: int) -> void:
	if frame_idx < 0 or frame_idx > (shadow.hframes * shadow.vframes): return

	shadow.frame = frame_idx

func reset() -> void:
	shadow.frame = _original_shadow_frame_idx
