extends Control

@export var buttons: Array[MarginContainer] = []

@onready var tutorial_manager: BattlefieldTutorial = %TutorialManager

var _index: int = 0

func _ready() -> void:
	for child: Control in get_children():
		child.hide()

	for button: MarginContainer in buttons:
		button.pressed.connect(
		func() -> void:
			tutorial_manager.next_tour_state()
			button.get_parent().hide()
			_index += 1
			if _index < get_child_count():
				get_child(_index).show()
		)
