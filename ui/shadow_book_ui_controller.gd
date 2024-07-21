class_name ShadowBookUI
extends PanelContainer

signal book_clicked(book: ShadowBookUI)

@export var shadow_texture: TextureRect
@export var highlight: Panel

var shadow_name: String

func _ready() -> void:
	gui_input.connect(on_gui_input)

func _process(_delta: float) -> void:
	pass

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			book_clicked.emit(self)
