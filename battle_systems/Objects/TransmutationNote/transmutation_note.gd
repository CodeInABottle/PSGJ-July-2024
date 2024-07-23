extends Area2D

@export var drop_location: BattlefieldReagentDropLocation
@export var transmutation_page: TextureRect

func _ready() -> void:
	transmutation_page.hide()

func _on_mouse_entered() -> void:
	if drop_location.is_holding_something() or transmutation_page.visible: return
	transmutation_page.show()

func _on_mouse_exited() -> void:
	transmutation_page.hide()
