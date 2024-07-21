class_name ShadowBookUI
extends Control

signal book_clicked(book: ShadowBookUI)
signal book_released(book: ShadowBookUI)

@export var shadow_texture: TextureRect
@export var highlight: Panel
@export var collision_area: Area2D

var shadow_name: String
var is_clicked: bool = false
var click_offset: Vector2 = Vector2.ZERO

const SLOT_OFFSET: Vector2 = Vector2(12.0, -43.0)
const LERP_SPEED: float = 15.0

func _ready() -> void:
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func _process(delta: float) -> void:
	if is_clicked and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		shadow_texture.set_global_position(shadow_texture.get_global_position().lerp(get_global_mouse_position() + click_offset, delta * LERP_SPEED))
	elif is_clicked:
		on_click_released()
		

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				book_clicked.emit(self)
				click_offset = shadow_texture.get_global_position() - get_global_mouse_position()
				if click_offset.length() > 85.0:
					click_offset = Vector2(-12.0, -43.0)
				is_clicked = true

func on_click_released() -> void:
	if is_clicked:
		if collision_area.has_overlapping_areas():
			var no_slots: bool = true
			for area in collision_area.get_overlapping_areas():
				if area.is_in_group("shadow_slot"):
					go_to_slot(area)
					no_slots = false
					break
			if no_slots:
				return_to_shelf()
				on_mouse_exited()
		else:
			return_to_shelf()
			on_mouse_exited()

func return_to_shelf() -> void:
	book_released.emit(self)
	is_clicked= false
	var position_tween: Tween = create_tween()
	position_tween.tween_property(shadow_texture, "position", Vector2.ZERO, 0.25)
	highlight.hide()

func go_to_slot(slot: Area2D) -> void:
	book_released.emit(self)
	is_clicked= false
	var position_tween: Tween = create_tween()
	var slot_position: Vector2 = slot.get_global_position()
	position_tween.tween_property(shadow_texture, "global_position", slot_position + SLOT_OFFSET, 0.1)
	
func on_mouse_entered() -> void:
	highlight.show()
	var position_tween: Tween = create_tween()
	position_tween.tween_property(self, "position:y", -20.0, 0.1)
	
func on_mouse_exited() -> void:
	if not is_clicked:
		highlight.hide()
		var position_tween: Tween = create_tween()
		position_tween.tween_property(self, "position:y", 0.0, 0.1)
	
