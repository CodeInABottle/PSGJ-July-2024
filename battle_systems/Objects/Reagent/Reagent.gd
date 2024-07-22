class_name BattlfieldReagent
extends Area2D

enum State { IDLE, HOLD_TRIGGER, HOLDING, DROPPED }

@export var reagent_drop_location: BattlefieldReagentDropLocation
@export var reagent_type: TypeChart.ResonateType = TypeChart.ResonateType.NONE

var _original_position: Vector2
var _at_drop_zone: bool = false
var _tween: Tween
var _state: State = State.IDLE

func _ready() -> void:
	_original_position = global_position

func _physics_process(_delta: float) -> void:
	match _state:
		State.IDLE, State.HOLD_TRIGGER: pass
		State.HOLDING:
			if _tween:
				_tween.kill()
			global_position = get_global_mouse_position()
		State.DROPPED:
			if _tween:
				_tween.kill()
			_tween = create_tween()
			_tween.tween_property(self, "global_position", _original_position, 0.25)\
				.set_trans(Tween.TRANS_BACK)\
				.set_ease(Tween.EASE_OUT)
			_state = State.IDLE

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if _state == State.HOLD_TRIGGER\
			and mouse_event.is_pressed() and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_state = State.HOLDING
		elif _state == State.HOLDING\
			and mouse_event.is_released() and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if _at_drop_zone:
				reagent_drop_location.add(reagent_type)
			_state = State.DROPPED

func is_holding() -> bool:
	return _state == State.HOLDING

func _can_grab() -> bool:
	return _state == State.IDLE\
		and (PlayerStats.alchemy_points > 0 or reagent_type == TypeChart.ResonateType.NONE)

func _on_mouse_entered() -> void:
	if _can_grab():
		_state = State.HOLD_TRIGGER

func _on_mouse_exited() -> void:
	if _state == State.HOLD_TRIGGER:
		if global_position != _original_position:
			_state = State.DROPPED
		else:
			_state = State.IDLE

func _on_area_entered(area: Area2D) -> void:
	if _state != State.HOLDING: return

	var parent: Node = area.get_parent()
	if parent is BattlefieldReagentDropLocation:
		_at_drop_zone = true

func _on_area_exited(area: Area2D) -> void:
	if _state != State.HOLDING: return

	var parent: Node = area.get_parent()
	if parent is BattlefieldReagentDropLocation:
		_at_drop_zone = false
