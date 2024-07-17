@tool
extends Node

signal graph_altered
signal graph_tab_changed
signal current_graph_changed
signal task_created
signal task_deleted
signal graph_tool_bar_toggled(button_state: bool)
signal node_name_altered
signal domains_updated
signal tab_access_requested(domain_name: String)

const ON_PORT_BLUE: Array[String] = ["Method", "Always True Method", "Quit"]
const ON_PORT_GREEN: Array[String] = ["Task", "Domain", "Applicator", "Splitter", "RNG", "Quit"]
const NODES: Dictionary = {
	"Root": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/RootNode/htn_root_node.tscn"),
	"Actions": {
		"Applicator": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/ApplicatorNode/htn_applicator_node.tscn"),
		"Task": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/TaskNode/htn_task_node.tscn"),
		"Domain": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/DomainNode/htn_domain_node.tscn"),
		"Quit": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/QuitNode/htn_quit_node.tscn"),
	},
	"Methods": {
		"Always True Method": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/MethodNode/AlwaysTrue/htn_always_true_method_node.tscn"),
		"Method": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/MethodNode/Original/htn_method_node.tscn"),
	},
	"Misc": {
		"Splitter": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/SplitterNode/htn_splitter_node.tscn"),
		"Comment": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/CommentNode/htn_comment_node.tscn"),
	},
	"Modules": {
		"RNG": preload("res://addons/HTNDomainManager/PluginSystem/Nodes/ModuleNodes/RandomNode/htn_random_node.tscn")
	}
}

var warning_box: HTNWarningBox
var effect_editor: HTNEffectEditor
var condition_editor: HTNConditionEditor
var notification_handler: HTNNotificaionHandler
var validator: HTNGraphValidator
var current_graph: HTNDomainGraph = null:
	set(value):
		current_graph = value
		current_graph_changed.emit()

func get_root() -> PackedScene:
	return NODES["Root"]

func get_packed_node_as_flat(node_type: String) -> PackedScene:
	if node_type == "Root": return NODES["Root"]

	for category: String in NODES.keys():
		if category == "Root": continue
		for type: String in NODES[category].keys():
			if type == node_type:
				return NODES[category][type]
	push_error("Couldn't load node type of " + node_type)
	return null

func get_categories() -> Array:
	return NODES.keys()

func get_sub_nodes_from_categories(category: String) -> Array:
	return NODES[category].keys()
