extends Node2D

func _ready() -> void:
	for child: Node in get_children():
		child.index = child.get_index()
