@tool
class_name HTNDomainNode
extends HTNBaseNode

const EMPTY_DOMAIN_NAME = "N/A"
const NO_DOMAINS_TO_LINK := "WARNING:There are no domains to link to.\nConsider making one or deleting this node."
const SELF_LINK := """WARNING: You've selected the same domain as the currently being edited domain.
Assuming all build rules are satisfied, when running the currently being edited domain within the HTN Planner Scene Node,
it may cause an infinite loop while planning or running the plan due to an infinite recursion.
TLDR: This may cause a stack overflow due to recursion."""

@onready var warning_symbol: TextureRect = %WarningSymbol
@onready var domain_option_button: OptionButton = %DomainOptionButton

func initialize() -> void:
	super()
	warning_symbol.hide()
	HTNGlobals.domains_updated.connect(_refresh)
	_refresh()

func get_node_name() -> String:
	if domain_option_button.item_count == 0: return ""

	var domain_name: String = domain_option_button.get_item_text(domain_option_button.selected)
	if domain_name == EMPTY_DOMAIN_NAME: return ""

	return domain_name

func get_node_type() -> String:
	return "Domain"

# Return value:
#	On valid: return "" (and empty string)
#	On invalid: return an error message string
func validate_self() -> String:
	if get_node_name().is_empty():
		return "Node created with no domains to link to..."
	return ""

func load_data(data: Dictionary) -> void:
	for idx: int in domain_option_button.item_count:
		if domain_option_button.get_item_text(idx) == data["domain"]:
			domain_option_button.select(idx)
			_on_domain_option_button_item_selected(idx)
			return
	domain_option_button.select(0)
	_on_domain_option_button_item_selected(0)
	warning_symbol.show()
	warning_symbol.tooltip_text = "Domain: " + data["domain"] + " was not found,\nSelecting first input as default."

func get_data() -> Dictionary:
	return {
		"domain": get_node_name()
	}

func _refresh() -> void:
	var domain_names: Array = HTNFileManager.get_all_domain_names()
	if domain_names.is_empty():
		warning_symbol.tooltip_text = NO_DOMAINS_TO_LINK
		warning_symbol.show()
		return

	domain_names.sort()

	# Parse the currently selected task name
	var last_item: String
	if domain_option_button.item_count == 1:
		last_item = domain_option_button.get_item_text(0)
		if last_item == EMPTY_DOMAIN_NAME:
			last_item = ""
	elif domain_option_button.item_count > 1:
		last_item = domain_option_button.get_item_text(domain_option_button.selected)

	domain_option_button.clear()

	# Add all the task names
	var idx := 0
	for domain_name: String in domain_names:
		domain_option_button.add_item(domain_name)
		if not last_item.is_empty() and domain_name == last_item:
			domain_option_button.select(idx)
			_on_domain_option_button_item_selected(idx)
		idx += 1
	if last_item.is_empty():
		domain_option_button.select(0)
		_on_domain_option_button_item_selected(0)

func _on_domain_option_button_item_selected(index: int) -> void:
	if HTNGlobals.current_graph == null: return
	# No Domains Selected
	if get_node_name().is_empty(): return

	# Check if domain links to itself
	if HTNFileManager.check_if_domain_links_to_self(HTNGlobals.current_graph.domain_name, get_node_name()):
		warning_symbol.tooltip_text = SELF_LINK
		warning_symbol.show()
	else:
		warning_symbol.hide()
	HTNGlobals.graph_altered.emit()

func _on_show_link_button_pressed() -> void:
	var target: String = get_node_name()
	if target.is_empty(): return
	HTNGlobals.tab_access_requested.emit(target)
