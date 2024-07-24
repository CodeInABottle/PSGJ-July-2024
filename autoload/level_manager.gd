extends Node

## Used as an autoload
## Requires this setup as the main scene
## Master (main scene: Node)
## └── WorldAnchor (Node)

## Recommends a Handshake from the levels you load
## -- Recommended to create a base scene you can inherit from
## Example of the handshake script on the level's root node
##
## // Level1.gd
## extends Node3D
##
## # A Parent node of Marker3D children
## @onready var entry_points: Node3D = $EntryPoints
## @onready var player: Player = $Player
##
## func _ready() -> void:
##   LevelManager.level_loaded.emit(self)
##
## func start_at(entry_id: int) -> void:
##   if entry_id < 0 or entry_id >= entry_points.get_child_count():
##      push_error("Invalid Entry ID: " + str(entry_id))
##      return
##
##  player.global_position = entry_points.get_child(entry_id).global_position
##


## Emitted by other scripts; self connects to this
signal level_loaded(level: Node)
signal menu_unloaded()
signal menu_loaded()

## Emitted by this script; Others connect to this
# Used to let individual nodes the state of the game
signal game_paused
signal game_unpaused
# Used to pause the process loops of the World Node
signal world_disabled
signal world_enabled

#region Variables
# { "level_name" (String) : scene_path (String) }
# ie. { "level_name": "path to scene" }
var _levels: Dictionary = {
"main_menu": "res://ui/main_menu.tscn",
"Newbert Town": "res://regions/Region1_CentraDivide/area_0_newbert_town.tscn",
"Remembrance": "res://regions/Region1_CentraDivide/area_1_remembrance.tscn",

# OLD -- Deprecated
"area_0": "res://old_areas/area_0.tscn",
"area_1": "res://old_areas/area_1.tscn",
"area_0_cellar": "res://old_areas/area_0_cellar.tscn",
"area_0_player_house_F1": "res://old_areas/area_0_player_house_F1.tscn",
}

# checkpoints
# checkpoint_name (String) : [area_name (String), entry_id(int)]
var _checkpoints: Dictionary = {
	"start" : ["Newbert Town", 0],
	"home" : ["Newbert Town", 2],
	"cat_bridge" : ["Newbert Town", 1]
}

# Set as the first level to be loaded
# -- Used by `load_entry_point()` only
# -- entry_id used is 0
var _entry_point: String = "Newbert Town"
#var _entry_point: String = "area_0"

# used by is_paused() utility function
var _is_paused: bool = false

# Anchors
var master_node: Node
var world_anchor: Node
var menu_anchor: Node
var canvas_layer: CanvasLayer

## Tracking Data
# Intended to be where to spawn at in the level, if applicable
var _entry_id: int = -1
# Used to track path for load_threaded_request
var _loading_level_path: String = ""
# Can be used to access this level and any of its content, if applicable
var loaded_level: Node = null
var loaded_menu: Node = null

# Can be used to check what is the currently loaded level
var region_name: String
var current_modifiers: Array[String] = []
var current_checkpoint: String = "start"
var current_anchor: Node

#endregion

func _ready() -> void:
	master_node = get_node_or_null("/root/Main")
	world_anchor = get_node_or_null("/root/Main/World")
	canvas_layer = get_node_or_null("/root/Main/CanvasLayer")
	menu_anchor = get_node_or_null("/root/Main/Menu")

	# Check if using F5 or F6 to play scene
	# -- On F6, nope out
	if master_node == null: return

	level_loaded.connect(_on_level_loaded)
	menu_loaded.connect(on_menu_loaded)

	load_world("main_menu")

# Used to check the progress of the threaded load call
func _process(_delta: float) -> void:
	if (loaded_level or _loading_level_path == "") and current_anchor == world_anchor: return
	elif (loaded_menu or _loading_level_path == "") and current_anchor == menu_anchor: return
	elif current_anchor == null : return
	_async_update(_loading_level_path)

# Used to load the first level only
# -- Shortcut version of load_world
# -- Assumes there's a fixed entry point to spawn a player, if applicable
func load_entry_point() -> void:
	load_world(_entry_point)

# You want to fade to black before using this
# -- world_name comes from the _level dictionary
# -- entry point is where you would load a player at or set some state in the level
func load_world(world_name: String, entry_id: int=0) -> bool:
	var region: String = _levels.get(world_name,"")	# Fetch level path
	if region == "": return false

	game_paused.emit()	# Alert listening scripts, the game is about to be paused
	_unload_level()	# Unload current level, if applicable

	# Record the tracking data
	_entry_id = entry_id
	region_name = world_name

	# Begin loading
	_async_load(region, world_anchor)
	return true

func load_menu(menu_name: String, _args: Array = []) -> void:
	match menu_name:
		"workbench":
			disable_world_node()
			_async_load("res://ui/workbench_menu.tscn", menu_anchor)
		"battle":
			disable_world_node()
			_async_load("res://battle_systems/battlefield.tscn", menu_anchor)

func unload_menu() -> void:
	if loaded_menu: loaded_menu.queue_free()
	loaded_menu = null
	enable_world_node()
	menu_unloaded.emit()
	current_anchor = null

# Used to pause the WorldAnchor Node and its children
# Intention: Use when loading a "sub" level like a build's interior or battle scene
# Usage: Fade to black, call this function once full black, Fade from black to clear
# -- Hides the current level
# -- Then, sets the process_mode of the Node to be disabled
func disable_world_node() -> void:
	#for child: Node in world_anchor.get_children():
		#child.hide()

	world_disabled.emit()
	_is_paused = true
	# This should be the _process, _physics_process, and the various _input functions
	world_anchor.process_mode = Node.PROCESS_MODE_DISABLED

func is_paused() -> bool:
	return _is_paused

# Used to unpause the WorldAnchor Node and its children
# Intention: Use when unloading a "sub" level like a build's interior or battle scene
# Usage: Fade to black, call this function once full black, Fade from black to clear
# -- Shows the current level
# -- Then, sets the process_mode of the Node to be inherit
func enable_world_node() -> void:
	for child: Node in world_anchor.get_children():
		child.show()

	world_enabled.emit()
	_is_paused = false
	# This should be the _process, _physics_process, and the various _input functions
	world_anchor.process_mode = Node.PROCESS_MODE_INHERIT


func _unload_level() -> void:
	if loaded_level: loaded_level.queue_free()
	loaded_level = null
	_loading_level_path = ""
	current_anchor = null
	region_name = ""

# Starts the async loading
func _async_load(path: String, anchor: Node) -> void:
	current_anchor = anchor

	if loaded_level and current_anchor == world_anchor: return


	_loading_level_path = path
	ResourceLoader.load_threaded_request(path)

# Called by the _process loop in this script
func _async_update(path: String) -> void:
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path, [])

	if status == ResourceLoader.THREAD_LOAD_LOADED:	# Finished
		var packed_resource: PackedScene = ResourceLoader.load_threaded_get(path)
		var level: Node = packed_resource.instantiate()
		# FOR WHO EVER IS READING THIS, THIS LINE BELOW STAYS LIKE THIS
		# YOU SHALL NOT CHANGE IT OR IT'LL BREAK
		await get_tree().create_timer(0.0).timeout	# Wait a full engine frame
		current_anchor.add_child(level)
		if current_anchor == world_anchor:
			loaded_level = level
		elif current_anchor == menu_anchor:
			loaded_menu = level

	elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:	# Used to grab loading progress
		pass
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		push_error("FAILED TO LOAD")
	elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("[", path, "] is a invalid path.")

# Called on Handshake signal from level
func _on_level_loaded(level: Node) -> void:
	loaded_level = level
	# Check if level has a "start_at" function to pass the entry ID
	if level.has_method("start_at"):
		# Tell that level, all data is synced up here
		level.start_at(_entry_id)

	# Tell listening node, you ok to continue
	game_unpaused.emit()

func on_menu_loaded(menu: Node) -> void:
	loaded_menu = menu
	loaded_level.hide()
	MenuManager.fader_controller.fade_in()

func get_save_data() -> Dictionary:
	return {
		"area": region_name,
		"modifiers": current_modifiers,
		"checkpoint": current_checkpoint
	}

func respawn() -> void:
	load_world(_checkpoints[current_checkpoint][0], _checkpoints[current_checkpoint][1])

func update_checkpoint(checkpoint_name: String) -> void:
	if _checkpoints.keys().has(checkpoint_name):
		current_checkpoint = checkpoint_name
