class_name BattlefieldTutorial
extends Node

enum State { NONE, TOUR, RECIPE_BOOK, FINISHED }
enum TourState {
	HELLO_MESSAGE,
	HP_POTION,
	AP_POTION,
	ENEMY_HEALTH,
	REAGENTS,
	PAPER_TOWEL,
	CANDLES,
	CHEAT_SHEET,
	CHEAT_SHEET_2
}

@onready var battlefield: BattlefieldManager = $".."
@onready var table: BattlefieldTable = %Table
@onready var tour_screen: Control = %TourScreen
@onready var recipe_book_tutorial: Control = %RecipeBookTutorial
@onready var crafting: Control = %Crafting
@onready var selecting_recipe: Control = %SelectingRecipe
@onready var recipe_page: Control = %RecipePage
@onready var sparkles: Control = %Sparkles
@onready var end: Control = %End
@onready var battle_blocker: Panel = %BattleBlocker

var _state: State
var _tour_state: TourState

func _ready() -> void:
	recipe_book_tutorial.hide()
	crafting.hide()
	selecting_recipe.hide()
	recipe_page.hide()
	sparkles.hide()
	battle_blocker.hide()
	end.hide()
	table.recipe_display_closed.connect(
		func() -> void:
			if complete(): return
			if _state == State.RECIPE_BOOK:
				next_state()
	)
	set_process(false)

func complete() -> bool:
	return _state == State.FINISHED

func activate() -> void:
	set_process(true)
	_state = State.TOUR
	_tour_state = TourState.HELLO_MESSAGE
	next_state()

func next_state() -> void:
	if complete(): return

	match _state:
		State.TOUR:
			tour_screen.get_child(0).show()
		State.RECIPE_BOOK:
			crafting.show()
		State.FINISHED:
			set_process(false)

func next_tour_state() -> void:
	if complete(): return

	match _tour_state:
		TourState.HELLO_MESSAGE:
			_tour_state = TourState.HP_POTION
		TourState.HP_POTION:
			_tour_state = TourState.AP_POTION
		TourState.AP_POTION:
			_tour_state = TourState.ENEMY_HEALTH
		TourState.ENEMY_HEALTH:
			_tour_state = TourState.REAGENTS
		TourState.REAGENTS:
			_tour_state = TourState.PAPER_TOWEL
		TourState.PAPER_TOWEL:
			_tour_state = TourState.CANDLES
		TourState.CANDLES:
			_tour_state = TourState.CHEAT_SHEET
		TourState.CHEAT_SHEET:
			_tour_state = TourState.CHEAT_SHEET_2
		TourState.CHEAT_SHEET_2:
			recipe_book_tutorial.show()
			_state = State.RECIPE_BOOK

func _on_tutorial_text_button_pressed() -> void:
	if complete(): return

	crafting.hide()
	selecting_recipe.show()

func _on_table_recipe_page_displayed() -> void:
	if complete(): return

	recipe_page.show()

func _on_enemy_entity_capture_status_animated() -> void:
	if complete(): return

	battle_blocker.hide()
	sparkles.show()
	battlefield.process_mode = Node.PROCESS_MODE_DISABLED

func _on_sparkles_tutorial_button_pressed() -> void:
	if complete(): return

	sparkles.hide()
	end.show()

func _on_last_tutorial_button_pressed() -> void:
	if complete(): return

	end.hide()
	selecting_recipe.hide()
	battlefield.process_mode = Node.PROCESS_MODE_INHERIT
	_state = State.FINISHED

func _on_table_recipe_clicked() -> void:
	if complete(): return

	recipe_page.hide()
	battle_blocker.show()
