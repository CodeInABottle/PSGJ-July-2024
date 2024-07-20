class_name BattlefieldCombatStateMachine
extends Node

# {state_name (StringName): state_node (Node)}
var _states: Dictionary = {}
var _last_state: StringName = ""
# Execute _last_state's exit and current_state's enter
var _transfer_waiting: bool = false
var _is_enabled: bool = false
var current_state: StringName

func _ready() -> void:
	for child: Node in get_children():
		if child.name in _states: continue
		assert(child.has_method("enter"), "Node: " + child.name + " does not have an enter method!")
		assert(child.has_method("exit"), "Node: " + child.name + " does not have an exit method!")
		assert(child.has_method("update"), "Node: " + child.name + " does not have an update method!")
		_states[child.name] = child
		if current_state.is_empty():
			current_state = child.name
	assert(_states.size() > 0, "There are no states in the state machine!")

func start() -> void:
	_states[current_state].enter()

func switch_state(state_name: StringName) -> void:
	if state_name not in _states: return

	_is_enabled = false
	_last_state = current_state
	current_state = state_name
	print(current_state)
	_transfer_waiting = true
	_is_enabled = true

func update(delta: float) -> void:
	if not _is_enabled: return

	if _transfer_waiting:
		_transfer_waiting = false
		_states[_last_state].exit()
		_states[current_state].enter()

	_states[current_state].update(delta)
