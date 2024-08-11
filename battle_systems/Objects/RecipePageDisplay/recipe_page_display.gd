class_name RecipePageDisplay
extends Panel

signal display_closed

@onready var pages: Array[BattlefieldRecipePage] = [
	%RecipePage, %RecipePage2, %RecipePage3, %RecipePage4, %RecipePage5,
	%RecipePage6, %RecipePage7, %RecipePage8, %RecipePage9, %RecipePage10,
	%RecipePage11, %RecipePage12
]
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var description_label: Label = %DescriptionLabel
@onready var book_close_button: Button = %BookCloseButton

var _playing_backwards: bool = false

func _ready() -> void:
	hide()
	animation_player.animation_finished.connect(
		func(_animation_name: String) -> void:
			if not _playing_backwards: return
			_playing_backwards = false
			hide()
			display_closed.emit()
	)

	description_label.text = "Hover over a page for more info."
	var abilities: PackedStringArray = PlayerStats.get_all_equipped_abilities()
	var idx: int = 0
	for page: BattlefieldRecipePage in pages:
		page.mouse_hovered.connect(func() -> void: _on_mouse_hovered(idx))
		page.mouse_left.connect(func() -> void: _on_mouse_left(idx))
		if idx < abilities.size():
			var ability_data: Dictionary = EnemyDatabase.get_ability_info(abilities[idx])
			page.set_data(
				abilities[idx],
				ability_data["resonate"],
				EnemyDatabase.get_ability_recipe_textures(abilities[idx])
			)
		else:
			page.hide()
		idx += 1

func open() -> void:
	show()
	book_close_button.disabled = false
	animation_player.play("FlyIn")

func _on_mouse_hovered(page_index: int) -> void:
	if not pages[page_index].visible:
		description_label.text = "Hover over a page for more info."
		return

	pages[page_index].wiggle()
	var data: Dictionary = EnemyDatabase.get_ability_info(pages[page_index].get_ability_name())
	description_label.text = "Damage: " + str(data["damage"])
	if not data["description"].is_empty():
		description_label.text += "\nAdditional Effects:\n" + data["description"]

func _on_mouse_left(page_index: int) -> void:
	pages[page_index].stop_wiggling()
	description_label.text = "Hover over a page for more info."

func _on_book_close_button_pressed() -> void:
	if LevelManager.audio_anchor:
		LevelManager.audio_anchor.play_sfx("accept_button")
	book_close_button.disabled = true
	_playing_backwards = true
	animation_player.play("FlyIn", -1, -1, true)
