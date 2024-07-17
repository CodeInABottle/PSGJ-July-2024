@tool
class_name HTNDomainPanel
extends VBoxContainer

const DOMAIN_LINE = preload("res://addons/HTNDomainManager/PluginSystem/DomainPanel/DomainLine/domain_line.tscn")

@onready var searchbar: LineEdit = %Searchbar
@onready var domain_container: VBoxContainer = %DomainContainer

func initialize(manager: HTNDomainManager) -> void:
	hide()
	refresh(manager)

func refresh(manager: HTNDomainManager) -> void:
	# Clear the old set
	for child: HTNDomainLine in domain_container.get_children():
		if child.is_queued_for_deletion(): continue
		child.queue_free()

	searchbar.editable = false

	var domain_names: Array = HTNFileManager.get_all_domain_names()
	if domain_names.is_empty(): return

	domain_names.sort()

	for domain_name: String in domain_names:
		var domain_line_instance: HTNDomainLine = DOMAIN_LINE.instantiate()
		domain_container.add_child(domain_line_instance)
		domain_line_instance.initialize(manager, domain_name)
	searchbar.editable = true

func _on_searchbar_text_changed(new_text: String) -> void:
	var filter_santized := new_text.to_lower()
	for child: HTNDomainLine in domain_container.get_children():
		var line_name: String = child.domain_button.text.to_lower()
		if filter_santized.is_empty() or line_name.contains(filter_santized):
			child.show()
		else:
			child.hide()
