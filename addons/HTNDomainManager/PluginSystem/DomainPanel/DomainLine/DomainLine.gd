@tool
class_name HTNDomainLine
extends HBoxContainer

@onready var domain_button: Button = %DomainButton

var _manager: HTNDomainManager

func initialize(manager: HTNDomainManager, domain_name: String) -> void:
	_manager = manager
	domain_button.text = domain_name

func _on_delete_button_pressed() -> void:
	HTNGlobals.warning_box.open(
		"You are about to delete this domain.\nThis will affect all Domain Link nodes that use this.\nContinue?",
		func() -> void:
			HTNFileManager.delete_domain(domain_button.text)
			_manager.tab_container.delete_tab_if_open(domain_button.text)
			HTNGlobals.domains_updated.emit()
			queue_free(),
		Callable()
	)

func _on_domain_button_pressed() -> void:
	_manager.load_domain(domain_button.text)
