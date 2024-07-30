@tool
extends Control

@export var location: String = "":
	set(value):
		location = value
		%Label.text = location
		%LabelFake.text = location

@onready var label_container: PanelContainer = %LabelContainer
@onready var label: Label = %Label
@onready var outline: TextureRect = %Outline
@onready var label_container_shadow: PanelContainer = %LabelContainerShadow
@onready var label_fake: Label = %LabelFake

func hide_all() -> void:
	outline.hide()
	label_container.modulate.a = 0
	label.hide()
	label_container_shadow.modulate.a = 0
	label_fake.hide()

func show_all() -> void:
	outline.show()
	label_container.modulate.a = 1
	label.show()
	label_container_shadow.modulate.a = 1
	label_fake.show()

func _on_button_mouse_entered() -> void:
	show_all()

func _on_button_mouse_exited() -> void:
	hide_all()
