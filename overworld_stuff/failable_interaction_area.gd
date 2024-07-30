class_name FailableInteractable
extends Interactable

@export var interaction_host: Node

func is_valid() -> bool:
	return await interaction_host.is_valid()
