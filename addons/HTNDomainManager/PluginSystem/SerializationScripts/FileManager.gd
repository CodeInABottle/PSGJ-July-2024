@tool
class_name HTNFileManager
extends Node

const TASK_PATH := "res://addons/HTNDomainManager/Data/Tasks/"
const SCRIPT_PATH := "res://addons/HTNDomainManager/Data/Scripts/"
const DOMAIN_PATH := "res://addons/HTNDomainManager/Data/Domains/"
const GRAPH_SAVE_PATH := "res://addons/HTNDomainManager/Data/GraphSaves/"
#region Task Script Template
const FILE_TEMPLATE := "extends HTNTask
# IMPORTANT: For more information on what these functions do, refer to the
# documentation by pressing F1 on your keyboard and searching
# for HTNTask`. Happy scripting! :D

func run_operation(HTN_finished_op_callback: Callable, agent: Node, world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_effects(world_state: Dictionary) -> void:
	pass # Replace with function body

func apply_expected_effects(world_state: Dictionary) -> void:
	pass # Replace with function body"
#endregion

static func check_if_task_name_exists(task_name: String) -> bool:
	var files: PackedStringArray = DirAccess.get_files_at(TASK_PATH)
	return task_name + ".tres" in files

static func check_if_domain_name_exists(domain_name: String) -> HTNDomain:
	var files: PackedStringArray = DirAccess.get_files_at(DOMAIN_PATH)
	for file: String in files:
		if file.replace(".tres", "") == domain_name:
			return load(DOMAIN_PATH + file)
	return null

static func check_if_no_domains() -> bool:
	return DirAccess.get_files_at(DOMAIN_PATH).is_empty()

# NOTE: Time Complexity: O(N) where N is every domain linked
# Utilizes DFS for searching
static func check_if_domain_links_to_self(original_domain_name: String, domain_name_link: String) -> bool:
	var file_names: PackedStringArray = DirAccess.get_files_at(DOMAIN_PATH)
	var domain_files: Dictionary = {}
	for file: String in file_names:
		domain_files[file.replace(".tres", "")] = load(DOMAIN_PATH + file)
	# Lazy Checks
	# - Check if same
	if original_domain_name == domain_name_link: return true
	# - Check if there's no domains to check
	if domain_files.is_empty(): return false
	# - Check if domain exists
	if original_domain_name not in domain_files: return false
	# - Check if the linking domain has any domains within
	var domain_names: Array = domain_files[domain_name_link]["domain_map"].values()
	if domain_names.is_empty(): return false
	# - Check if original domain is within this linking domain
	if original_domain_name in domain_names: return true

	# DFS Search
	var closed_set: Array[StringName] = [original_domain_name]
	for cur_domain_name: StringName in domain_names:
		# Check if current domain name has any domains linked
		var sub_domain_list: Array = domain_files[cur_domain_name]["domain_map"].values()
		if cur_domain_name not in closed_set:
			closed_set.push_back(cur_domain_name)

		if sub_domain_list.is_empty(): continue

		# Dig deeper
		if _check_if_domain_links_helper(domain_files, closed_set, cur_domain_name, original_domain_name):
			return true
		# Found nothing
		if cur_domain_name not in closed_set:
			closed_set.push_back(cur_domain_name)

	# Does not link at any time
	return false

static func _check_if_domain_links_helper(domain_files: Dictionary, closed_set: Array[StringName],
		current_domain_name: String, original_domain_name: String) -> bool:
	for cur_domain_name: StringName in domain_files[current_domain_name]["domain_map"].values():
		# Already Searched
		if cur_domain_name in closed_set: continue

		# Check if sub domain name is the same as the original root domain
		if cur_domain_name == original_domain_name: return true

		# Check if current domain name has any domains linked
		var sub_domain_list: Array = domain_files[cur_domain_name]["domain_map"].values()
		if sub_domain_list.is_empty():
			if cur_domain_name not in closed_set:
				closed_set.push_back(cur_domain_name)
			continue

		# Dig deeper
		if _check_if_domain_links_helper(domain_files, closed_set, cur_domain_name, original_domain_name):
			return true
		# Found nothing
		if cur_domain_name not in closed_set:
			closed_set.push_back(cur_domain_name)

	# Does not link at any time
	return false

static func get_all_domain_files() -> Dictionary:
	var domain_files: Dictionary = {}
	var files: PackedStringArray = DirAccess.get_files_at(DOMAIN_PATH)
	for file: String in files:
		var file_name: String = file.replace(".tres", "")
		if file_name in domain_files: continue
		domain_files[file_name] = load(DOMAIN_PATH + file)
	return domain_files

static func get_all_task_files() -> Dictionary:
	var task_files: Dictionary = {}
	var files: PackedStringArray = DirAccess.get_files_at(TASK_PATH)
	for file: String in files:
		var file_name: String = file.replace(".tres", "")
		if file_name in task_files: continue
		task_files[file_name] = load(TASK_PATH + file)
	return task_files

static func get_all_task_names() -> Array:
	var tasks: Array[String] = []
	tasks.assign(DirAccess.get_files_at(TASK_PATH))
	return tasks.map(
		func(task_file_name: String) -> String:
			return task_file_name.replace(".tres", "")
	)

static func get_all_domain_names() -> Array:
	var domains: Array[String] = []
	domains.assign(DirAccess.get_files_at(DOMAIN_PATH))
	return domains.map(
		func(domain_file_name: String) -> String:
			return domain_file_name.replace(".tres", "")
	)

static func get_awaiting_task_state(task_name: String) -> bool:
	var path := TASK_PATH + task_name + ".tres"
	assert(FileAccess.file_exists(path), "This task: " + task_name + " doesn't exists.")
	var task: HTNTask = load(path)
	return task.requires_awaiting

static func toggle_awaiting_task_state(task_name: String, state: bool) -> void:
	var path := TASK_PATH + task_name + ".tres"
	assert(FileAccess.file_exists(path), "This task: " + task_name + " doesn't exists.")
	var task: HTNTask = load(path)
	task.requires_awaiting = state
	ResourceSaver.save(task, path)

static func create_task(task_name: String) -> bool:
	if task_name.is_empty(): return false
	if check_if_task_name_exists(task_name): return false

	var file_name: String = task_name.to_pascal_case()
	var script_path := SCRIPT_PATH + task_name +".gd"
	var script: Script = _build_script(file_name, script_path)
	if script == null: return false

	var task_resource: HTNTask = _build_resource(script, file_name)
	if task_resource == null:
		DirAccess.remove_absolute(script_path)
		return false

	return true

static func edit_script(task_name: String) -> void:
	if task_name.is_empty(): return

	var script_path := SCRIPT_PATH + task_name + ".gd"
	if not FileAccess.file_exists(script_path): return

	var script := load(script_path)
	EditorInterface.edit_script(script)
	EditorInterface.set_main_screen_editor("Script")

static func delete_task(task_name: String) -> bool:
	if task_name.is_empty(): return false
	return _delete_files(
		"Script", SCRIPT_PATH + task_name + ".gd",
		"Task Resource File", TASK_PATH + task_name + ".tres"
	)

static func delete_domain(domain_name: String) -> bool:
	if domain_name.is_empty(): return false
	return _delete_files(
		"Graph Save", GRAPH_SAVE_PATH + domain_name + ".tres",
		"Domain", DOMAIN_PATH + domain_name + ".tres"
	)

static func _delete_files(file_type1: String, file_path1: String, file_type2: String, file_path2: String) -> bool:
	var found_file1 := false
	var found_file2 := false
	if FileAccess.file_exists(file_path1):
		found_file1 = true
	if FileAccess.file_exists(file_path2):
		found_file2 = true

	if found_file1 and found_file2:
		DirAccess.remove_absolute(file_path1)
		DirAccess.remove_absolute(file_path2)
		return true
	else:
		var error_message: String = "Missing Files::"
		if not found_file1:
			error_message += file_type1 + " File"
			push_error(file_path1)
		if not found_file1 and not found_file2:
			error_message += " and "
		if not found_file2:
			error_message += file_type2 + " File"
			push_error(file_path2)
		return false

static func _build_script(task_name: String, path: String) -> Script:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return null

	var data: String = FILE_TEMPLATE
	var write_data := data.split("\n")
	for line in write_data:
		file.store_line(line)
	file.close()

	return load(path)

static func _build_resource(script: Script, file_name: String) -> Resource:
	var path: String = TASK_PATH + file_name + ".tres"
	var resource_file: = Resource.new()
	resource_file.set_script(script)

	var result = ResourceSaver.save(resource_file, path)
	if result != OK:
		push_error("BUILDING RESOURCE FAILED::" + str(result))
		return null
	return resource_file
