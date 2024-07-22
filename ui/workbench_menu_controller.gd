class_name WorkbenchMenu
extends Control

@export var shadow_slots: Array[Area2D]
@export var creature_details_panel: ShadowDetailsContainer
@export var move_details_panel: MoveDetailsContainer
@export var shadow_books_container: HBoxContainer
@export var shadow_book_scene: PackedScene
@export var slotted_moves_container: SlottedMovesContainer
@export var close_button: Button

var shadow_book_map: Dictionary = {}
var current_selected_index: int = -1
var unlocked_shadows: PackedStringArray = []
var slotted_shadows: Array[String] = []

const MAX_BOOKS: int = 17

signal click_released()

func _ready() -> void:
	LevelManager.menu_loaded.emit(self)
	gui_input.connect(on_gui_input)
	slotted_moves_container.move_selected.connect(on_move_selected)
	close_button.pressed.connect(on_close_button_pressed)

	create_shadow_books()
	initialize_shadow_books.call_deferred()

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				click_released.emit()

func create_shadow_books() -> void:
	unlocked_shadows = PlayerStats.get_all_unlocked_shadows()

	for index: int in range(unlocked_shadows.size()):
		var new_shadow_book: ShadowBookUI = shadow_book_scene.instantiate()
		shadow_books_container.add_child(new_shadow_book)

func initialize_shadow_books() -> void:
	var shadow_books: Array = shadow_books_container.get_children()
	var shadow_index: int = 0
	for book: ShadowBookUI in shadow_books:
		shadow_book_map[book] = shadow_index
		book.book_clicked.connect(on_book_clicked)
		book.book_released.connect(on_book_released)
		book.mouse_entered_book.connect(on_mouse_entered_book)
		book.mouse_exited_book.connect(on_mouse_exited_book)
		book.book_slotted.connect(on_book_slotted)
		book.book_unslotted.connect(on_book_unslotted)
		click_released.connect(book.on_click_released)
		shadow_index += 1

func _process(_delta: float) -> void:
	pass

func on_book_clicked(book: ShadowBookUI) -> void:
	if current_selected_index != -1:
		var last_book: ShadowBookUI = shadow_book_map.find_key(current_selected_index)
		last_book.highlight.hide()
	current_selected_index = shadow_book_map[book]
	print("book #", current_selected_index)
	book.highlight.show()

func on_book_released(book: ShadowBookUI) -> void:
	pass

func on_mouse_entered_book(book:ShadowBookUI) -> void:
	var book_shadow_name: String = get_shadow_name_from_book(book)
	creature_details_panel.update_details(book_shadow_name)
	move_details_panel.hide()
	slotted_moves_container.clear_selection()
	creature_details_panel.show()

func on_mouse_exited_book(book:ShadowBookUI) -> void:
	creature_details_panel.hide()

func on_book_slotted(book:ShadowBookUI) -> void:
	var book_shadow_name: String = get_shadow_name_from_book(book)
	slotted_shadows.append(book_shadow_name)
	slotted_moves_container.refresh_slotted_moves()
	book.on_mouse_exited()

func on_book_unslotted(book:ShadowBookUI) -> void:
	var book_shadow_name: String = get_shadow_name_from_book(book)
	slotted_shadows.erase(book_shadow_name)
	slotted_moves_container.refresh_slotted_moves()

func get_shadow_name_from_book(book:ShadowBookUI) -> String:
	var book_index: int = shadow_book_map[book]
	var book_shadow_name: String = unlocked_shadows[book_index]
	return book_shadow_name

func on_move_selected(move_name: String) -> void:
	move_details_panel.update_details(move_name)
	move_details_panel.show()

func on_close_button_pressed() -> void:
	MenuManager.fader_controller.fade_out_complete.connect(on_fade_out_complete)
	MenuManager.fader_controller.fade_out()

func on_fade_out_complete() -> void:
	MenuManager.fader_controller.fade_out_complete.disconnect(on_fade_out_complete)
	LevelManager.unload_menu()




