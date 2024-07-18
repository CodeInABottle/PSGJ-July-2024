extends Area2D

@export var table: BattlefieldTable
@export var reagent_holder: BattlefieldReagentHolder
@export var reagent_type := TypeChart.ResonateType.NONE

@onready var sprite_2d: Sprite2D = $Sprite2D

var _hold_trigger := false

func _process(_delta: float) -> void:
	if _hold_trigger and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		reagent_holder.hold(sprite_2d.texture, reagent_type)
		_hold_trigger = false

func _on_mouse_entered() -> void:
	if reagent_holder.has_something() or\
		(table.battlefield_manager.alchemy_points <= 0 and reagent_type != TypeChart.ResonateType.NONE): return
	_hold_trigger = true

func _on_mouse_exited() -> void:
	_hold_trigger = false
