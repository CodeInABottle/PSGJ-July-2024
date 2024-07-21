class_name WorkbenchMenuLayer
extends CanvasLayer

@export var shadow_slots: Array[Area2D]
@export var details_panel: Panel
@export var shadow_books_container: HBoxContainer
@export var shadow_book_scene: PackedScene

var shadow_book_map: Dictionary = {}
var current_selected_index: int = -1

const MAX_BOOKS: int = 17

func _ready() -> void:
	create_shadow_books()
	
	initialize_shadow_books.call_deferred()

func create_shadow_books() -> void:
	for index: int in range(MAX_BOOKS):
		var new_shadow_book: ShadowBookUI = shadow_book_scene.instantiate()
		shadow_books_container.add_child(new_shadow_book)

func initialize_shadow_books() -> void:
	var shadow_books: Array = shadow_books_container.get_children()
	var shadow_index: int = 0
	for book: ShadowBookUI in shadow_books:
		shadow_book_map[book] = shadow_index
		book.book_clicked.connect(on_book_clicked)
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
