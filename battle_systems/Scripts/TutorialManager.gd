class_name BattlefieldTutorial
extends Node

@onready var battlefield: BattlefieldManager = $".."
@onready var table: BattlefieldTable = %Table

@onready var tutorial: Control = %Tutorial
@onready var hello_message: Control = %HelloMessage
@onready var recipe_book_tutorial: Control = %RecipeBookTutorial
@onready var drag_and_drop: Control = %DragAndDrop
@onready var failed_drag_and_drop: Control = %FailedDragAndDrop
@onready var selecting_recipe: Control = %SelectingRecipe
@onready var sparkles: Control = %Sparkles
@onready var end: Control = %End

func activate() -> void:
	if _get_tutorial_state("started") or _get_tutorial_state("used_first_ability")\
		or _get_tutorial_state("first_combat_wisdom_complete"): return
	hello_message.show()

func _get_tutorial_state(state_name: String) -> bool:
	return SaveManager.tutorial_save_dictionary.get("tutorial_" + state_name, false)

func _set_tutorial_state(state_name: String, state: bool) -> void:
	SaveManager.tutorial_save_dictionary["tutorial_" + state_name] = state

func _on_cheat_sheet_p_2_tutorial_pressed() -> void:
	_set_tutorial_state("started", true)

func _on_table_recipe_display_opened() -> void:
	recipe_book_tutorial.hide()

func _on_table_recipe_display_closed() -> void:
	if _get_tutorial_state("used_first_ability"): return
	drag_and_drop.show()

func _on_table_reagent_added(type: TypeChart.ResonateType) -> void:
	if _get_tutorial_state("used_first_ability"): return
	drag_and_drop.hide()
	failed_drag_and_drop.hide()
	if type == TypeChart.ResonateType.EARTH:
		selecting_recipe.show()
	else:
		table.reagent_drop_handler.clear()
		failed_drag_and_drop.show()

func _on_table_recipe_clicked() -> void:
	selecting_recipe.hide()
	_set_tutorial_state("used_first_ability", true)

func _on_enemy_entity_capture_status_animated() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	sparkles.show()
	battlefield.process_mode = Node.PROCESS_MODE_DISABLED

func _on_last_tutorial_button_pressed() -> void:
	_set_tutorial_state("first_combat_wisdom_complete", true)

func _on_sparkles_tutorial_button_pressed() -> void:
	battlefield.process_mode = Node.PROCESS_MODE_INHERIT
	end.show()
