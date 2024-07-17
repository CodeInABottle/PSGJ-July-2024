class_name HTNStateManager
extends Node
## [color=red][b]This is only used by the HTN Planner. DO NOT USE.[/b][/color]

enum PlanState { IDLE, SETUP, RUN, WAIT, EFFECT, FINISHED }

@onready var htn_planner: HTNPlanner = $".."

var _plan_state: PlanState = PlanState.IDLE
var _running_plan := false
#{
	#"Domain": current_domain_name,
	#"TaskKey": task_key
#}
var _current_task: Dictionary
var _plan: Array[Dictionary]
var _world_state_copy: Dictionary
var _agent: Node

func start(agent: Node, plan: Array[Dictionary], world_state_copy: Dictionary) -> void:
	_agent = agent
	_plan = plan
	_world_state_copy = world_state_copy
	_plan_state = PlanState.SETUP
	_running_plan = true

func update() -> void:
	if not _running_plan: return

	match _plan_state:
		PlanState.IDLE: pass	# Intended to do nothing
		PlanState.SETUP: _setup()
		PlanState.RUN: _run()
		PlanState.WAIT: pass	# Intended to do nothing
		PlanState.EFFECT: _effect()
		PlanState.FINISHED: _finished()

func on_interrupt() -> void:
	if _plan_state != PlanState.WAIT: return

	_plan_state = PlanState.IDLE
	_running_plan = false
	htn_planner._is_planning = false
	htn_planner.finished.emit()

func _setup() -> void:
	_current_task = _plan.pop_front()
	_plan_state = PlanState.RUN

func _run() -> void:
	if HTNDatabase.is_quit_early(_current_task["Domain"], _current_task["TaskKey"]):
		_plan_state = PlanState.FINISHED
		return
	elif HTNDatabase.has_task(_current_task["Domain"], _current_task["TaskKey"]):
		var task: HTNTask = HTNDatabase.get_task(_current_task["Domain"], _current_task["TaskKey"])
		task.run_operation(func() -> void: _plan_state = PlanState.EFFECT, _agent, _world_state_copy)
		if task.requires_awaiting:
			_plan_state = PlanState.WAIT
			return
	_plan_state = PlanState.EFFECT

func _effect() -> void:
	var task_key: StringName = _current_task["TaskKey"]
	var domain: String = _current_task["Domain"]
	if HTNDatabase.has_task(domain, task_key):
		var task: HTNTask = HTNDatabase.get_task(domain, task_key)
		task.apply_effects(_world_state_copy)
	elif HTNDatabase.domain_has(domain, "modules", task_key):
		HTNDatabase.apply_module(domain, task_key, _world_state_copy)
	else:	# Apply Effects from Applicator Node
		HTNDatabase.apply_effects(domain, task_key, _world_state_copy)
	_plan_state = PlanState.FINISHED

func _finished() -> void:
	if htn_planner.enable_debugging:
		print_debug(_agent, "::Finished Task Operation: ",
			HTNDatabase.get_task_name(_current_task["Domain"], _current_task["TaskKey"])
		)
	if _plan.is_empty():
		_plan_state = PlanState.IDLE
		_current_task = {}
		_plan.clear()
		_world_state_copy.clear()
		_agent = null
		_running_plan = false
		htn_planner._is_planning = false
		if not htn_planner._queued_AI_behavior.is_empty():
			htn_planner.domain_name = htn_planner._queued_AI_behavior
			htn_planner._queued_AI_behavior = ""
		htn_planner.finished.emit()
	else:
		_plan_state = PlanState.SETUP
