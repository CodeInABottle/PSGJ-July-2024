class_name BattlefieldReagentHolder
extends Sprite2D

@export var drop_location: BattlefieldReagentDropLocation

var _held_reagent := TypeChart.ResonateType.NONE

func _physics_process(_delta: float) -> void:
	if texture == null: return
	global_position = get_global_mouse_position()

	if has_something() and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if drop_location.mouse_entered:
			drop_location.add(texture, _held_reagent)
		drop()

func hold(sprite: Texture, reagent: TypeChart.ResonateType) -> void:
	global_position = get_global_mouse_position()
	texture = sprite
	_held_reagent = reagent

func drop() -> void:
	texture = null
	_held_reagent = TypeChart.ResonateType.NONE

func has_something() -> bool:
	return texture != null
