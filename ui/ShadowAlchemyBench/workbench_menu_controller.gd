class_name WorkbenchMenu
extends Control

const TEST_TUBE_ANCHOR: PackedScene = preload("res://ui/ShadowAlchemyBench/TestTube/test_tube_anchor.tscn")
const MAX_BOOKS: int = 17

@onready var slotted_moves_container: SlottedMovesContainer = %SlottedMovesContainer
@onready var move_details_panel: MoveDetailsContainer = %MoveDetailsPanel
@onready var shadow_container: HBoxContainer = %ShadowBooks
@onready var shadow_slots: Node = %ShadowSlots
@onready var _slot_data: Dictionary = {
	%ShadowSlot1: {
		"beaker": $AlchemyBench/TextureRect,
		"sprite": $ShadowSlots/ShadowSlot1/Sprite2D,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot2: {
		"beaker": $AlchemyBench/TextureRect2,
		"sprite": $ShadowSlots/ShadowSlot2/Sprite2D,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot3: {
		"beaker": $AlchemyBench/TextureRect3,
		"sprite": $ShadowSlots/ShadowSlot3/Sprite2D,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot4: {
		"beaker": $AlchemyBench/TextureRect4,
		"sprite": $ShadowSlots/ShadowSlot4/Sprite2D,
		"test_tube": null,
		"full": false
	},
	%ShadowSlot5: {
		"beaker": $AlchemyBench/TextureRect5,
		"sprite": $ShadowSlots/ShadowSlot5/Sprite2D,
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
	move_details_panel.clear()
	slotted_moves_container.ability_hovered.connect(
		func(ability_name: String) -> void:
			move_details_panel.update_sign_details(ability_name, true)
	)
	slotted_moves_container.ability_unhovered.connect(
		func() -> void:
			move_details_panel.clear()
	)
	slotted_shadows = PlayerStats.get_equipped_shadows()
	var idx: int = 0
	for area: Area2D in _slot_data:
		if idx >= slotted_shadows.size():
			_slot_data[area]["beaker"].hide()
		area.mouse_entered.connect( func() -> void: _on_area_mouse_entered(area) )
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
		_slot_data[_area_entered]["sprite"].texture = null
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
		test_tube.hovered.connect(move_details_panel.update_sign_details.bind(false))
		test_tube.unhovered.connect(move_details_panel.clear)

	for test_tube: TestTube in shadow_container.get_children():
		var index: int = slotted_shadows.find(test_tube.shadow_name)
		if index == -1: continue

		var area: Area2D = shadow_slots.get_child(index)
		test_tube.test_tube.global_position = area.get_child(0).global_position - test_tube.pivot_offset
		test_tube.hide()
		_slot_data[area]["test_tube"] = test_tube
		_slot_data[area]["full"] = true
		_slot_data[area]["beaker"].self_modulate = test_tube.background.self_modulate
		_slot_data[area]["beaker"].show()
		_set_sprite_data(area, test_tube.shadow_name)
	if shadow_container.get_child_count() > 0:
		slotted_moves_container.refresh_slotted_moves()

func on_fade_out_complete() -> void:
	MenuManager.fader_controller.fade_out_complete.disconnect(on_fade_out_complete)
	LevelManager.unload_menu()

func _set_sprite_data(area: Area2D, shadow_name: String) -> void:
	var enemy_data: Dictionary = EnemyDatabase.get_shadow_icon_data(shadow_name)
	_slot_data[area]["sprite"].texture = enemy_data["texture"]
	_slot_data[area]["sprite"].hframes = enemy_data["frame_size"].x
	_slot_data[area]["sprite"].vframes = enemy_data["frame_size"].y
	_slot_data[area]["sprite"].frame = enemy_data["frame_index"]

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
		_set_sprite_data(area, test_tube.shadow_name)
	else:
		test_tube.reset_placement()

func _on_close_button_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	PlayerStats.set_equipped_shadows(slotted_shadows)
	MenuManager.fader_controller.fade_out_complete.connect(on_fade_out_complete)
	MenuManager.fader_controller.fade_out()
