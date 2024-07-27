class_name BattlefieldTutorial
extends Node

enum State { NONE, TOUR, RECIPE_BOOK, RECIPE_PAGE, CLOSE_BOOK, CREATE_RECIPE, END_TURN, FINISHED }
enum TourState {
	HELLO_MESSAGE,
	HP_POTION,
	AP_POTION,
	ENEMY_HEALTH,
	REAGENTS,
	PAPER_TOWEL,
	CANDLES,
	CHEAT_SHEET,
	CHEAT_SHEET_2,
	FINISHED
}

@onready var tour_screen: Control = %TourScreen

var _state: State
var _tour_state: TourState
var _started_tour: bool = false

func _ready() -> void:
	set_process(false)

func activate() -> void:
	set_process(true)
	_state = State.TOUR
	_tour_state = TourState.HELLO_MESSAGE
	_started_tour = false

func _physics_process(_delta: float) -> void:
	match _state:
		State.NONE: pass
		State.TOUR:
			if not _started_tour:
				tour_screen.get_child(0).show()
				_started_tour = true
		State.RECIPE_BOOK:
			pass
		State.RECIPE_PAGE:
			pass
		State.CLOSE_BOOK:
			pass
		State.CREATE_RECIPE:
			pass
		State.END_TURN:
			pass
		State.FINISHED:
			set_process(false)

func next_tour_state() -> void:
	if _state == State.FINISHED: return

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
			_tour_state = TourState.FINISHED
		TourState.FINISHED:
			_state = State.RECIPE_BOOK
