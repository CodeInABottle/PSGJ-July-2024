extends TextureRect

@export var treat_as_dummy: bool = false

@onready var label: Label = %Label
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	label.text = "0x"
	if treat_as_dummy: return
	hide()

func set_amount(amount: int, blink: bool) -> void:
	if amount <= 0:
		animation_player.stop()
		hide()
		return

	label.text = str(amount) + "x"
	if blink:
		animation_player.play("Blink")
	else:
		animation_player.stop()
	show()
