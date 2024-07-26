class_name TestTube
extends Control

const RETURN_SPEED: float = 0.25

signal slot_requested(area: Area2D, reset_callback: Callable)

enum State { IDLE, HOVERING, HOLDING, DROPPED, RETURNING }

@onready var test_tube: MarginContainer = %TestTube
@onready var background: TextureRect = %Background
@onready var foreground: TextureRect = %Foreground
@onready var drop_detector: Area2D = %DropDetector

var _alchemy_bench: WorkbenchMenu
var _state: State = State.IDLE
var _original_position: Vector2
var _at_drop_point: bool = false
var _tween: Tween
var shadow_name: String

func initialize(alchemy_bench: WorkbenchMenu) -> void:
	_alchemy_bench = alchemy_bench
	_original_position = global_position
	background.self_modulate = EnemyDatabase.get_shadow_color(shadow_name)

func _process(_delta: float) -> void:
	if _state == State.IDLE: return

	if _state == State.HOVERING and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_state = State.HOLDING
		_alchemy_bench.hands_full = true
		test_tube.z_index = 1
	elif _state == State.HOLDING and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_state = State.DROPPED
		_alchemy_bench.hands_full = false
		test_tube.z_index = 0

	match _state:
		State.IDLE, State.HOVERING, State.RETURNING: pass
		State.HOLDING:
			test_tube.global_position = get_global_mouse_position() - test_tube.pivot_offset
		State.DROPPED:
			_release()

func drop() -> void:
	_state = State.RETURNING
	_alchemy_bench.hands_full = false
	test_tube.z_index = 0
	reset_placement()

func _release() -> void:
	# Check if we on the drop point
	if _at_drop_point:
		slot_requested.emit(
			drop_detector.get_overlapping_areas()[0],
			self
		)
	else:
		reset_placement()
	_state = State.IDLE
	foreground.self_modulate = Color.WHITE

func reset_placement() -> void:
	_reset_tween()
	_tween.tween_property(test_tube, "global_position", _original_position, RETURN_SPEED)
	_tween.tween_callback(
		func() -> void:
			test_tube.global_position = _original_position
			if _state == State.RETURNING:
				_state = State.IDLE
	)

func _reset_tween() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()

func _on_area_2d_mouse_entered() -> void:
	if _state != State.IDLE: return
	if _alchemy_bench.hands_full: return

	_state = State.HOVERING
	foreground.self_modulate = Color("fbf236")

func _on_area_2d_mouse_exited() -> void:
	if _state != State.HOVERING: return

	_state = State.IDLE
	foreground.self_modulate = Color.WHITE

func _on_drop_detector_area_entered(_area: Area2D) -> void:
	if _state != State.HOLDING: return

	_at_drop_point = true

func _on_drop_detector_area_exited(_area: Area2D) -> void:
	if _state != State.HOLDING: return

	_at_drop_point = false
