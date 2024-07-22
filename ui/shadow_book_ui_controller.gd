class_name ShadowBookUI
extends Control

signal book_clicked(book: ShadowBookUI)
signal book_released(book: ShadowBookUI)
signal mouse_entered_book(book: ShadowBookUI)
signal mouse_exited_book(book: ShadowBookUI)
signal book_slotted(book: ShadowBookUI)
signal book_unslotted(book: ShadowBookUI)

@export var shadow_texture: TextureRect
@export var highlight: Panel
@export var collision_area: Area2D
@export var contents_control: Control

var shadow_name: String
var is_clicked: bool = false
var is_slotted: bool = false
var click_offset: Vector2 = Vector2.ZERO


const SLOT_OFFSET: Vector2 = Vector2(15.0, -75.0)
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
				if is_slotted:
					book_unslotted.emit(self)
				is_slotted = false

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
	is_clicked= false
	book_released.emit(self)
	var position_tween: Tween = create_tween()
	position_tween.tween_property(shadow_texture, "position", Vector2.ZERO, 0.25)
	highlight.hide()

func go_to_slot(slot: Area2D) -> void:
	is_slotted = true
	is_clicked= false
	book_released.emit(self)
	book_slotted.emit(self)
	var position_tween: Tween = create_tween()
	var slot_position: Vector2 = slot.get_global_position()
	position_tween.tween_property(shadow_texture, "global_position", slot_position + SLOT_OFFSET, 0.1)
	
func on_mouse_entered() -> void:
	mouse_entered_book.emit(self)
	highlight.show()
	var highlight_tween: Tween = highlight.create_tween()
	var shadow_tween: Tween = shadow_texture.create_tween()
	highlight_tween.tween_property(highlight, "scale", Vector2(1.1, 1.1), 0.1)
	shadow_tween.tween_property(shadow_texture, "scale", Vector2(1.1, 1.1), 0.1)
	
func on_mouse_exited() -> void:
	if not is_clicked:
		mouse_exited_book.emit(self)
		highlight.hide()
		var highlight_tween: Tween = highlight.create_tween()
		var shadow_tween: Tween = shadow_texture.create_tween()
		highlight_tween.tween_property(highlight, "scale", Vector2(1.0, 1.0), 0.1)
		shadow_tween.tween_property(shadow_texture, "scale", Vector2(1.0, 1.0), 0.1)
	
