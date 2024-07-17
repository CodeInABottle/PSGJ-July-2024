@tool
class_name HTNDomainManager
extends Control

# Toolbar
@onready var task_panel_button: Button = %TaskPanelButton
@onready var goto_panel_button: Button = %GotoPanelButton
@onready var graph_tools_toggle: CheckButton = %GraphToolsToggle
@onready var clear_graph_button: Button = %ClearGraphButton
@onready var build_domain_button: Button = %BuildDomainButton
@onready var domain_panel_button: Button = %DomainPanelButton
# Containers
@onready var tab_container: HTNTabGraphManager = %TabContainer
@onready var task_panel: HTNTaskPanelManager = %TaskPanel
@onready var goto_panel: HTNGoToManager = %GotoPanel
@onready var domain_panel: HTNDomainPanel = %DomainPanel
# Other
@onready var left_v_separator: VSeparator = %LeftVSeparator
@onready var right_v_separator: VSeparator = %RightVSeparator

func _ready() -> void:
	HTNGlobals.warning_box = %WarningBox
	HTNGlobals.effect_editor = %EffectEditor
	HTNGlobals.condition_editor = %ConditionEditor
	HTNGlobals.notification_handler = %NotificationHandler
	HTNGlobals.validator = %Validator

	graph_tools_toggle.toggled.connect(
		func() -> void: HTNGlobals.graph_tool_bar_toggled.emit()
	)
	HTNGlobals.graph_altered.connect(_update_toolbar_buttons)
	HTNGlobals.graph_tab_changed.connect(
		func() -> void:
			%NodeSpawnMenu.hide()
	)
	HTNGlobals.current_graph_changed.connect(_update_toolbar_buttons)
	HTNGlobals.domains_updated.connect(_update_domain_button)
	HTNGlobals.tab_access_requested.connect(load_domain)

	left_v_separator.hide()
	right_v_separator.hide()

	tab_container.initialize()
	task_panel.initialize()
	goto_panel.initialize()
	domain_panel.initialize(self)

	_update_toolbar_buttons()
	_update_domain_button()

func load_domain(domain_name: String) -> void:
	if domain_name.is_empty(): return
	if HTNGlobals.current_graph != null:
		if domain_name == HTNGlobals.current_graph.domain_name:
			return

	if not tab_container.switch_to_tab(domain_name):
		%DomainLoader.load_domain(domain_name)
	_update_toolbar_buttons()

func _update_toolbar_buttons() -> void:
	if HTNGlobals.current_graph == null:
		graph_tools_toggle.disabled = true
		build_domain_button.disabled = true
		goto_panel_button.disabled = true
		clear_graph_button.disabled = true
		goto_panel_button.set_pressed_no_signal(false)
		goto_panel.hide()
	else:
		graph_tools_toggle.disabled = false

		if HTNGlobals.current_graph.is_saved:
			build_domain_button.disabled = true
		else:
			build_domain_button.disabled = false

		if HTNGlobals.current_graph.nodes.size() <= 1:
			clear_graph_button.disabled = true
		else:
			clear_graph_button.disabled = false
		goto_panel_button.disabled = false

func _update_domain_button() -> void:
	if HTNFileManager.check_if_no_domains():
		domain_panel_button.disabled = true
	else:
		domain_panel_button.disabled = false

func _on_task_panel_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		task_panel.show()
		left_v_separator.show()
		goto_panel_button.set_pressed_no_signal(false)
		goto_panel.hide()
	else:
		task_panel.hide()
		left_v_separator.hide()

func _on_goto_panel_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		goto_panel.show()
		left_v_separator.show()
		task_panel_button.set_pressed_no_signal(false)
		task_panel.hide()
	else:
		goto_panel.hide()
		left_v_separator.hide()

func _on_domain_panel_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		right_v_separator.show()
		domain_panel.show()
	else:
		domain_panel.hide()
		right_v_separator.hide()

func _on_clear_graph_button_pressed() -> void:
	if not HTNGlobals.current_graph: return
	HTNGlobals.warning_box.open(
		"You are about to remove nodes for this graph.\nContinue?",
		HTNGlobals.current_graph.clear,
		Callable()
	)

func _on_build_domain_button_pressed() -> void:
	build_domain_button.disabled = true
	if HTNGlobals.current_graph == null: return

	if not HTNGlobals.validator.validate(HTNGlobals.current_graph): return
	if not HTNDomainSaver.save(HTNGlobals.notification_handler, HTNGlobals.current_graph): return

	HTNGlobals.notification_handler.send_message("Build Complete! Graph Saved!")
	HTNGlobals.current_graph.is_saved = true
	domain_panel.refresh(self)
	HTNGlobals.domains_updated.emit()

func _on_graph_tools_toggle_toggled(toggled_on: bool) -> void:
	HTNGlobals.graph_tool_bar_toggled.emit(toggled_on)
