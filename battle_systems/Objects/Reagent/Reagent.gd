extends Area2D

@export var reagent_drop_location: BattlefieldReagentDropLocation
@export var reagent_type: TypeChart.ResonateType = TypeChart.ResonateType.NONE

var _original_position: Vector2
var _hold_trigger: bool = false
var _is_holding: bool = false
var _at_drop_zone: bool = false

func _ready() -> void:
	_original_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	if not _hold_trigger: return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.is_pressed() and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_is_holding = true
		elif mouse_event.is_released() and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if _at_drop_zone:
				reagent_drop_location.add(reagent_type)
			_is_holding = false

func _physics_process(_delta: float) -> void:
	if not _hold_trigger: return

	if _is_holding:
		global_position = get_global_mouse_position()
	else:
		global_position = _original_position

func _on_mouse_entered() -> void:
	if _is_holding\
		or (PlayerStats.alchemy_points <= 0 and reagent_type != TypeChart.ResonateType.NONE): return
	_hold_trigger = true

func _on_mouse_exited() -> void:
	if _is_holding: return

	_hold_trigger = false

func _on_area_entered(area: Area2D) -> void:
	if not _is_holding: return
	var parent: Node = area.get_parent()
	if parent is BattlefieldReagentDropLocation:
		_at_drop_zone = true

func _on_area_exited(area: Area2D) -> void:
	if not _is_holding: return
	var parent: Node = area.get_parent()
	if parent is BattlefieldReagentDropLocation:
		_at_drop_zone = false
