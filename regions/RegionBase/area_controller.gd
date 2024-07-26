class_name GameArea
extends Node2D

@onready var warp_points: Node = %WarpPoints
@onready var setup_timer: Timer = %SetupTimer
@onready var intro_layer: IntroLayer = %IntroLayer
@onready var pickups: Node2D = %Pickups

var fader_controller: CanvasLayer
var _warp_points: Array[Marker2D] = []
var _area_pickups: Array = []

func _ready() -> void:
	# Do what we need
	for warp_point: Marker2D in warp_points.get_children():
		_warp_points.push_back(warp_point)
	setup_timer.timeout.connect(_on_setup_timeout)
	setup_timer.start()
	
	init_pickups()
	
	# Alert the level manager we done setting up
	LevelManager.level_loaded.emit(self)

func init_pickups() -> void:
	_area_pickups = pickups.get_children()
	for pickup: PickupItem in _area_pickups:
		pickup.pickup_interaction_ended.connect(on_item_picked_up)

func start_at(entry_id: int) -> void:
	# Check if valid entry ID
	if entry_id < 0 or entry_id > _warp_points.size(): return

	# Warp and load
	PlayerStats.player.teleport_to(_warp_points[entry_id].get_global_position())
	SaveManager.attempt_load()
	refresh_pickups.call_deferred()

func _on_setup_timeout() -> void:
	MenuManager.fader_controller.fade_in_complete.connect(on_fade_in_complete)
	MenuManager.fader_controller.fade_in()

func on_fade_in_complete() -> void:
	MenuManager.fader_controller.fade_in_complete.disconnect(on_fade_in_complete)
	intro_layer.trigger()

func refresh_pickups() -> void:
	for index: int in LevelManager.area_pickup_status[LevelManager.region_name]:
		if _area_pickups[index].get_parent() != null:
			pickups.remove_child(_area_pickups[index])

func on_item_picked_up(index: int) -> void:
	LevelManager.area_pickup_status[LevelManager.region_name].append(index)
