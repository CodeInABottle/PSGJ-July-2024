extends Node2D

func _ready():
	for child: Node in get_children():
		child.index = child.get_index()
