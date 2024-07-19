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
signal level_loaded(Node)

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
"area_0": "res://areas/area_0.tscn",
"area_1": "res://areas/area_1.tscn",
"area_0_cellar": "res://areas/area_0_cellar.tscn",
"area_0_player_house_F1": "res://areas/area_0_player_house_F1.tscn",
}
# Set as the first level to be loaded
# -- Used by `load_entry_point()` only
# -- entry_id used is 0
var _entry_point: String = ""

# Anchors
var master_node: Node
var world_anchor: Node
var canvas_layer: CanvasLayer

## Tracking Data
# Intended to be where to spawn at in the level, if applicable
var _entry_id: int = -1
# Used to track path for load_threaded_request
var _loading_level_path := ""
# Can be used to access this level and any of its content, if applicable
var loaded_level: Node = null
# Can be used to check what is the currently loaded level
var region_name: String

#endregion

func _ready() -> void:
	level_loaded.connect(_on_level_loaded)
	master_node = get_node_or_null("/root/Main")
	world_anchor = get_node_or_null("/root/Main/World")
	canvas_layer = get_node_or_null("/root/Main/CanvasLayer")
	
	load_world("main_menu")

# Used to check the progress of the threaded load call
func _process(_delta) -> void:
	if loaded_level or _loading_level_path == "": return
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
	_async_load(region)
	return true

# Used to pause the WorldAnchor Node and its children
# Intention: Use when loading a "sub" level like a build's interior or battle scene
# Usage: Fade to black, call this function once full black, Fade from black to clear
# -- Hides the current level
# -- Then, sets the process_mode of the Node to be disabled
func disable_world_node() -> void:
	for child: Node in world_anchor.get_children():
		child.hide()

	world_disabled.emit()
	# This should be the _process, _physics_process, and the various _input functions
	world_anchor.process_mode = Node.PROCESS_MODE_DISABLED


# Used to unpause the WorldAnchor Node and its children
# Intention: Use when unloading a "sub" level like a build's interior or battle scene
# Usage: Fade to black, call this function once full black, Fade from black to clear
# -- Shows the current level
# -- Then, sets the process_mode of the Node to be inherit
func enable_world_node() -> void:
	for child: Node in world_anchor.get_children():
		child.show()

	world_enabled.emit()
	# This should be the _process, _physics_process, and the various _input functions
	world_anchor.process_mode = Node.PROCESS_MODE_INHERIT


func _unload_level() -> void:
	if loaded_level: loaded_level.queue_free()
	loaded_level = null
	_loading_level_path = ""
	region_name = ""

# Starts the async loading
func _async_load(path: String) -> void:
	if loaded_level: return

	_loading_level_path = path
	ResourceLoader.load_threaded_request(path)

# Called by the _process loop in this script
func _async_update(path: String) -> void:
	var status = ResourceLoader.load_threaded_get_status(path, [])

	if status == ResourceLoader.THREAD_LOAD_LOADED:	# Finished
		var packed_resource = ResourceLoader.load_threaded_get(path)
		var level = packed_resource.instantiate()
		# FOR WHO EVER IS READING THIS, THIS LINE BELOW STAYS LIKE THIS
		# YOU SHALL NOT CHANGE IT OR IT'LL BREAK
		await get_tree().create_timer(0.0).timeout	# Wait a full engine frame
		world_anchor.add_child(level)
		loaded_level = level
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

func get_save_data() -> Dictionary:
	return {
		"area": region_name
	}