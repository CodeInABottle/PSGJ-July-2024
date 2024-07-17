@icon("res://addons/HTNDomainManager/GameLibrary/Resources/Icons/HUB.svg")
extends Node

# Emitted by self
signal agent_removed
signal agent_awaiting_orders
# Emitted to self
signal orders_issued(agent_link: HTNAgentLink)

var _agent_ID_dumps: Array[String] = []
var _agent_current_ID: int = 0

# { group_tag (String) : { agent_ID (String) : link (HTNAgentLink) } }
var _agent_groups: Dictionary = {}
var _total_agents: int = 0

# { group_tag (String) : [ (link (HTNAgentLink))... ] }
var _awaiting_agents: Dictionary = {}
var _total_awaiting_agents: int = 0

func _ready() -> void:
	orders_issued.connect(_on_orders_issued)

func register(agent_link: HTNAgentLink, group_tag: String="global") -> void:
	assert(not group_tag.is_empty(), "group_tag can't be empty.")

	if group_tag not in _agent_groups:
		_agent_groups[group_tag] = {}

	var agent_ID: String
	if _agent_ID_dumps.is_empty():
		agent_ID = "Agent_"+str(_agent_current_ID)
		_agent_current_ID += 1
	else:
		agent_ID = _agent_ID_dumps.pop_back()

	agent_link._link_ID = agent_ID
	agent_link._group_tag = group_tag
	_agent_groups[group_tag][agent_ID] = agent_link
	_total_agents += 1

func unregister(agent_link: HTNAgentLink) -> void:
	_agent_groups[agent_link._group_tag].erase(agent_link._link_ID)
	if _agent_groups[agent_link._group_tag].is_empty():
		_agent_groups.erase(agent_link._group_tag)
	_agent_ID_dumps.push_back(agent_link._link_ID)
	_total_agents -= 1

	_on_orders_issued(agent_link)
	agent_removed.emit()

func get_total_agent_count() -> int:
	return _total_agents

func get_total_agents_by_group(group_tag: String) -> int:
	if group_tag not in _agent_groups: return 0

	return _agent_groups[group_tag].size()

func get_group_counts() -> Dictionary:
	var data: Dictionary = {}
	for group_tag: String in _agent_groups.keys():
		data[group_tag] = _agent_groups[group_tag].size()
	return data

func get_total_awaiting_agents() -> int:
	return _total_awaiting_agents

func get_total_awaiting_agents_by_group(group_tag: String) -> int:
	if group_tag not in _awaiting_agents: return 0
	return _awaiting_agents[group_tag].size()

func get_random_awaiting_agent() -> HTNAgentLink:
	var random_key = _awaiting_agents.keys().pick_random()
	return _awaiting_agents[random_key].pick_random()

func get_random_awaiting_agent_by_group(group_tag: String) -> HTNAgentLink:
	if group_tag not in _awaiting_agents: return null
	return _awaiting_agents[group_tag].pick_random()

func get_agent_by_group(group_tag: String, idx: int = 0) -> HTNAgentLink:
	if group_tag not in _awaiting_agents: return null
	if _awaiting_agents[group_tag].size() == 0: return null
	if idx > _awaiting_agents[group_tag].size(): return null
	if abs(idx)-1 > _awaiting_agents[group_tag].size(): return null

	return _awaiting_agents[group_tag][idx]

func get_every_agent_data(accessor: Callable) -> Array:
	var agents: Array = []
	for group_tag: String in _agent_groups.keys():
		for agent_ID: String in _agent_groups[group_tag]:
			agents.push_back(accessor.call(_agent_groups[group_tag][agent_ID]))
	return agents

func get_agent_data_by_group(group_tag: String, accessor: Callable) -> Array:
	if group_tag not in _agent_groups: return []

	var agents: Array = []
	for agent_ID: String in _agent_groups[group_tag]:
		agents.push_back(accessor.call(_agent_groups[group_tag][agent_ID]))
	return agents

func request_orders(agent_link: HTNAgentLink) -> void:
	if agent_link in _awaiting_agents: return

	if agent_link._group_tag not in _awaiting_agents:
		_awaiting_agents[agent_link._group_tag] = []
	_awaiting_agents[agent_link._group_tag].push_back(agent_link)
	_total_awaiting_agents += 1
	agent_awaiting_orders.emit()

func reassign_agent_group(agent_link: HTNAgentLink, new_group_tag: String) -> void:
	if agent_link._group_tag == new_group_tag: return
	if new_group_tag.is_empty(): return

	# Remove from old groups
	_agent_groups[agent_link._group_tag].erase(agent_link._link_ID)
	var reassign_awaiting_list := false
	if _awaiting_agents.has(agent_link._group_tag):
		if _awaiting_agents[agent_link._group_tag].has(agent_link):
			_awaiting_agents[agent_link._group_tag].erase(agent_link)
			reassign_awaiting_list = true

	if new_group_tag not in _agent_groups:
		_agent_groups[new_group_tag] = {}
	_agent_groups[new_group_tag][agent_link._link_ID] = agent_link
	if reassign_awaiting_list:
		if new_group_tag not in _awaiting_agents:
			_awaiting_agents[new_group_tag] = []
		_awaiting_agents[new_group_tag].push_back(agent_link)

func _on_orders_issued(agent_link: HTNAgentLink) -> void:
	if agent_link._group_tag not in _awaiting_agents: return
	if agent_link not in _awaiting_agents[agent_link._group_tag]: return

	_awaiting_agents[agent_link._group_tag].erase(agent_link)
	if _awaiting_agents[agent_link._group_tag].is_empty():
		_awaiting_agents.erase(agent_link._group_tag)

	_total_awaiting_agents -= 1
