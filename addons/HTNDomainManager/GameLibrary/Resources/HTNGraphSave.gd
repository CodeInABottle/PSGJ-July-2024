@icon("res://addons/HTNDomainManager/PluginSystem/Icons/Sandwich.svg")
class_name HTNGraphSave
extends Resource

## Used only for assembling data into graph plugin
## CRITICAL: DO NOT ALTER/TOUCH OR GRAPH MAY NOT BE ABLE TO BE ASSEMBLED

@export var root_key: StringName

# Connections of the different nodes
@export var connections: Array[Dictionary]

# { node_key (StringName) : node_type (String) }
@export var node_types: Dictionary

# { node_key (StringName) : position (Vector2) }
@export var node_positions: Dictionary

# { node_key (StringName) : data (Dictionary) }
@export var node_data: Dictionary
