class_name BattlefieldTutorial
extends Node

const FIRST_COMPOUND: Array[String] = [
	"Armored Snail", "Bombardier Beetle", "Morph Ferret", "Celestial Canine", "Niter Tiger"
]

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
@onready var residue_1: Control = %Residue1
@onready var residue_1b: Control = %Residue1b
@onready var resonating_residues: Control = %ResonatingResidues
@onready var resonating_residues_b: Control = %ResonatingResiduesB

var _fighting_first_compound_opponent: bool = false

func activate() -> void:
	if not _get_tutorial_state("first_combat_wisdom_complete"):
		hello_message.show()

	if battlefield.enemy_name in FIRST_COMPOUND and not _get_tutorial_state("first_compound"):
		if _get_tutorial_state("first_residue"):
			resonating_residues.show()
		else:
			resonating_residues_b.show()

func _get_tutorial_state(state_name: String) -> bool:
	return SaveManager.tutorial_save_dictionary.get("tutorial_" + state_name, false)

func _set_tutorial_state(state_name: String, state: bool) -> void:
	SaveManager.tutorial_save_dictionary["tutorial_" + state_name] = state

func _on_table_recipe_display_opened() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	recipe_book_tutorial.hide()

func _on_table_recipe_display_closed() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	drag_and_drop.show()

func _on_table_reagent_added(type: TypeChart.ResonateType) -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	drag_and_drop.hide()
	failed_drag_and_drop.hide()
	if type == TypeChart.ResonateType.EARTH:
		selecting_recipe.show()
	else:
		table.reagent_drop_handler.clear()
		failed_drag_and_drop.show()

func _on_table_recipe_clicked() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	selecting_recipe.hide()

func _on_enemy_entity_capture_status_animated() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	sparkles.show()
	battlefield.process_mode = Node.PROCESS_MODE_DISABLED

func _on_last_tutorial_button_pressed() -> void:
	_set_tutorial_state("first_combat_wisdom_complete", true)

func _on_sparkles_tutorial_button_pressed() -> void:
	if _get_tutorial_state("first_combat_wisdom_complete"): return
	battlefield.process_mode = Node.PROCESS_MODE_INHERIT
	end.show()

func _on_enemy_status_indicator_residue_added() -> void:
	if _get_tutorial_state("first_residue"): return
	residue_1.show()

func _on_tutorial_text_button_pressed() -> void:
	_set_tutorial_state("first_residue", true)
	if _fighting_first_compound_opponent:
		_set_tutorial_state("first_compound", true)

func _on_review_pressed() -> void:
	_on_win_pressed()
	#residue_1.show()
	residue_1b.show()

func _on_win_pressed() -> void:
	resonating_residues.hide()
	_fighting_first_compound_opponent = true
