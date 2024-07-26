class_name WorkbenchMenu
extends Control

const TEST_TUBE_ANCHOR: PackedScene = preload("res://ui/ShadowAlchemyBench/TestTube/test_tube_anchor.tscn")
const MAX_BOOKS: int = 17

@onready var creature_details_panel: ShadowDetailsContainer = %CreatureDetailsPanel
@onready var slotted_moves_container: SlottedMovesContainer = %SlottedMovesContainer
@onready var move_details_panel: MoveDetailsContainer = %MoveDetailsPanel
@onready var shadow_container: HBoxContainer = %ShadowBooks
@onready var _slot_data: Dictionary = {
	%ShadowSlot1: {
		"beaker": $AlchemyBench/TextureRect,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot2: {
		"beaker": $AlchemyBench/TextureRect2,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot3: {
		"beaker": $AlchemyBench/TextureRect3,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot4: {
		"beaker": $AlchemyBench/TextureRect4,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot5: {
		"beaker": $AlchemyBench/TextureRect5,
		"test_tube": null,
		"full": false
	}
}

var _area_entered: Area2D = null
var _unlocked_shadows: PackedStringArray
var hands_full: bool = false
var slotted_shadows: Array[String] = []

func _ready() -> void:
	LevelManager.menu_loaded.emit(self)
	move_details_panel.hide()
	slotted_moves_container.ability_hovered.connect(
		func(ability_name: String) -> void:
			move_details_panel.update_details(ability_name)
			move_details_panel.show()
	)
	slotted_moves_container.ability_unhovered.connect(
		func() -> void:
			move_details_panel.hide()
	)

	for area: Area2D in _slot_data:
		_slot_data[area]["beaker"].hide()
		area.mouse_entered.connect(
			func() -> void:
				_on_area_mouse_entered(area)
		)
		area.mouse_exited.connect(_on_area_mouse_exited)

	create_shadow_books()
	call_deferred("initialize_shadow_books")

func _unhandled_input(event: InputEvent) -> void:
	if _area_entered == null: return

	if event is InputEventMouseButton and event.is_pressed()\
			and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_slot_data[_area_entered]["full"] = false
		slotted_shadows.erase(_slot_data[_area_entered]["test_tube"].shadow_name)
		_slot_data[_area_entered]["test_tube"].drop()
		_slot_data[_area_entered]["beaker"].hide()
		_slot_data[_area_entered]["test_tube"].show()
		_area_entered = null
		slotted_moves_container.refresh_slotted_moves()

func create_shadow_books() -> void:
	_unlocked_shadows = PlayerStats.get_all_unlocked_shadows()

	for shadow_name: String in _unlocked_shadows:
		var test_tube: TestTube = TEST_TUBE_ANCHOR.instantiate()
		shadow_container.add_child(test_tube)
		test_tube.shadow_name = shadow_name
		test_tube.slot_requested.connect(_on_slot_requested)

func initialize_shadow_books() -> void:
	for test_tube: TestTube in shadow_container.get_children():
		test_tube.initialize(self)

func on_fade_out_complete() -> void:
	MenuManager.fader_controller.fade_out_complete.disconnect(on_fade_out_complete)
	LevelManager.unload_menu()

func _on_area_mouse_entered(area: Area2D) -> void:
	if _area_entered: return
	if not _slot_data[area]["full"]: return

	_area_entered = area

func _on_area_mouse_exited() -> void:
	_area_entered = null

func _on_slot_requested(area: Area2D, test_tube: TestTube) -> void:
	assert(area in _slot_data, "Uhh what happened?")
	if not _slot_data[area]["full"]:
		test_tube.hide()
		slotted_shadows.push_back(test_tube.shadow_name)
		slotted_moves_container.refresh_slotted_moves()
		_slot_data[area]["test_tube"] = test_tube
		_slot_data[area]["full"] = true
		_slot_data[area]["beaker"].self_modulate = test_tube.background.self_modulate
		_slot_data[area]["beaker"].show()
	else:
		test_tube.reset_placement()

func _on_close_button_pressed() -> void:
	MenuManager.fader_controller.fade_out_complete.connect(on_fade_out_complete)
	MenuManager.fader_controller.fade_out()
