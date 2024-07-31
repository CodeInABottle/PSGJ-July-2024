extends Control

const DISABLE_LOADING: bool = false

@export var item_list: ItemList
@export var item_name_label: Label
@export var item_icon: TextureRect
@export var item_description: Label
@export var details_panel: PanelContainer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var background: TextureRect = $Background
@onready var save_string: LineEdit = %SaveString
@onready var items_panel: PanelContainer = %ItemsPanel
@onready var buttons: Control = %Buttons
@onready var music_settings: Control = %MusicSettings
@onready var browser_shield: Control = %BrowserShield

var _is_opened: bool = false
var can_close: bool = false

func _ready() -> void:
	MenuManager.pause_menu = self
	item_list.item_selected.connect(_on_item_selected)
	background.visibility_changed.connect(_open)
	hide_all()
	music_settings.hide()
	browser_shield.hide()

func hide_all() -> void:
	item_list.deselect_all()
	items_panel.hide()
	details_panel.hide()

func _open() -> void:
	if not background.visible: return

	can_close = false
	animation_player.play("JumpUp")
	await animation_player.animation_finished
	animation_player.play("DisplayButton")
	await animation_player.animation_finished
	_is_opened = true
	can_close = true

func _populate_item_list() -> void:
	item_list.clear()
	for item_name: String in PlayerStats.get_inventory_items():
		var item: InventoryItem = InventoryDatabase.get_item(item_name)
		for index: int in range(PlayerStats.inventory_items[item_name]):
			item_list.add_item(item.item_name, item.item_icon)

func _update_details() -> void:
	if item_list.is_anything_selected():
		var selected_item_index: int = item_list.get_selected_items()[0]
		var item: InventoryItem = InventoryDatabase.get_item(item_list.get_item_text(selected_item_index))
		item_name_label.text = item.item_name
		item_icon.texture = item.item_icon
		item_description.text = item.item_description

func _on_item_selected(_index: int) -> void:
	_update_details()
	details_panel.show()

func _on_translucent_to_black_complete() -> void:
	MenuManager.toggle_pause_no_fade()
	MenuManager.fader_controller.translucent_to_black_complete.disconnect(_on_translucent_to_black_complete)
	LevelManager.respawn()

func _on_close_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	if not _is_opened or not can_close: return
	hide_all()
	MenuManager.toggle_pause()

func _on_save_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	animation_player.play_backwards("DisplayButton")
	await animation_player.animation_finished
	animation_player.play("MoveLeft")
	await animation_player.animation_finished
	if DISABLE_LOADING:
		browser_shield.show()
	animation_player.play("SlideSaveUp")
	save_string.text = SaveManager.generate_save_string()

func _on_respawn_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	MenuManager.fader_controller.translucent_to_black_complete.connect(_on_translucent_to_black_complete)
	MenuManager.fader_controller.translucent_to_black()

func _on_inventory_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	if items_panel.is_visible_in_tree():
		hide_all()
		animation_player.play("DisplayButton")
	else:
		# For some reason this is bugging out, idk why
		# Will look into it more later ~ Yolo
		#animation_player.play_backwards("DisplayButton")
		#await animation_player.animation_finished

		buttons.hide()
		_populate_item_list()
		items_panel.show()

func _on_back_from_save_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	if DISABLE_LOADING:
		browser_shield.hide()
	animation_player.play_backwards("SlideSaveUp")
	await animation_player.animation_finished
	animation_player.play_backwards("MoveLeft")
	await animation_player.animation_finished
	animation_player.play("DisplayButton")

func _on_clipboard_button_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	DisplayServer.clipboard_set(save_string.text)
	animation_player.play("Copied")

func _on_close_inventory_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	_on_inventory_pressed()

func _on_settings_pressed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	music_settings.show()

func _on_music_settings_closed() -> void:
	LevelManager.audio_anchor.play_sfx("accept_button")
	music_settings.hide()
