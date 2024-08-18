@tool
class_name QuestEditorQuestDataController
extends Node


@export var graph_edit: QuestEditorGraphEdit
@export var variable_tree: QuestEditVariableTree

var quest_file_path: String


func get_quest_data() -> Dictionary:
	var quest_data: Dictionary = {
		'name': '',
		'description': '',
		'variables': variable_tree.get_variables(),
		'node_references': variable_tree.get_references(),
		'start_action': '',
		'actions': {}
	}

	var editor_data: Dictionary = {
		'version': _get_editor_version(),
		'graph_edit_zoom': graph_edit.get_zoom(),
		'graph_edit_scroll_offset': var_to_str(graph_edit.get_scroll_offset()),
		'nodes': {}
	}

	for node in graph_edit.get_nodes() as Array[QuestEditorGraphNode]:
		var node_name: StringName = node.name
		var node_action: QuestAction = node.action if node.action else QuestAction.new(variable_tree.get_quest_variables(), variable_tree.get_references())

		quest_data['actions'][node_name] = {
			'class': QuestSystem.get_action_class_name(node_action.get_script()),
			'connections': graph_edit.get_connection_list().filter(_connections_filter.bind(node_name)).map(_clear_connection),
			'properties': []
		}

		editor_data['nodes'][node_name] = {
			'position': var_to_str(node.get_position_offset()),
			'size': var_to_str(node.get_size()),
		}
		for control in node.control_list:
			quest_data['actions'][node_name]['properties'].append({
				'name': node.control_list[control],
				'value': control.get_property_value()
			})

		if node.action is QuestActionLogicStart:
			quest_data['name'] = node.action.get('quest_name')
			quest_data['description'] = node.action.get('quest_description')
			quest_data['start_action'] = node_name

	return {
		'quest_data': quest_data,
		'editor_data': editor_data
	}


func _get_editor_version() -> String:
	return owner.get_meta('version', '0.0')


func _path_filter(class_data: Dictionary, class_path: String) -> bool:
	return class_data['path'] == class_path


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


func _clear_connection(connection: Dictionary) -> Dictionary:
	connection.erase('from_node')
	connection.erase('to_port')
	return connection


func _add_from_node(connection: Dictionary, from_node: StringName) -> Dictionary:
	connection['from_node'] = from_node
	connection['to_port'] = 0
	return connection


func get_quest_name() -> String:
	return get_quest_data()['quest_data'].get('name', '')


func get_quest_file_path() -> String:
	return quest_file_path


func save_quest_data(save_path: String) -> void:
	var quest_data: Dictionary = get_quest_data()

	var quest_data_file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	quest_data_file.store_string(JSON.stringify(quest_data['quest_data'], '\t'))
	quest_data_file.close()

	var editor_data_file: FileAccess = FileAccess.open(save_path + '.editor', FileAccess.WRITE)
	editor_data_file.store_string(JSON.stringify(quest_data['editor_data'], '\t'))
	editor_data_file.close()


func load_quest_data(load_path: String) -> void:
	var connection_list: Array[Dictionary] = []

	var json: JSON = JSON.new()
	var quest_data: Dictionary = {}
	var editor_data: Dictionary = {}

	var quest_data_file: FileAccess = FileAccess.open(load_path, FileAccess.READ)
	if quest_data_file:
		if json.parse(quest_data_file.get_as_text()) == OK:
			quest_data = json.data
		quest_data_file.close()


	var editor_data_file: FileAccess = FileAccess.open(load_path + '.editor', FileAccess.READ)
	if editor_data_file:
		if json.parse(editor_data_file.get_as_text()) == OK:
			editor_data = json.data
		editor_data_file.close()

	graph_edit.clear()
	graph_edit.set_zoom(editor_data.get('graph_edit_zoom', 0))
	graph_edit.set_scroll_offset(str_to_var(editor_data.get('graph_edit_scroll_offset', var_to_str(Vector2.ZERO))))

	variable_tree.set_variables(quest_data.get('variables', {}))
	variable_tree.set_references(quest_data.get('node_references', {}).keys())

	var actions: Dictionary = quest_data.get('actions', {})
	var nodes: Dictionary = editor_data.get('nodes', {})

	for action_name in actions:
		var action_record: Dictionary = actions.get(action_name, {})
		var action_class_script: GDScript = QuestSystem.get_action_script(action_record.get('class', ''))
		var action: QuestAction
		if not action_class_script:
			action = QuestAction.new(variable_tree.get_quest_variables(), variable_tree.get_references())
		else:
			action = action_class_script.new(variable_tree.get_quest_variables(), variable_tree.get_references(), action_record.get('properties', []))

		var size: Vector2 = str_to_var(nodes.get(action_name, {}).get('size', var_to_str(Vector2.INF)))
		var position: Vector2 = str_to_var(nodes.get(action_name, {}).get('position', var_to_str(Vector2.INF)))
		graph_edit.add_node(action, action_name, position, size)

		connection_list.append_array(action_record.get('connections', []).map(_add_from_node.bind(action_name)))

	for connection in connection_list:
		graph_edit.connect_node(connection['from_node'], connection['from_port'], connection['to_node'], connection['to_port'])

	quest_file_path = load_path


func apply_quest_data(all_data: Dictionary) -> void:
	var connection_list: Array[Dictionary] = []

	var editor_data: Dictionary = all_data.get('editor_data', {})
	var quest_data: Dictionary = all_data.get('quest_data', {})

	graph_edit.clear()

	variable_tree.set_variables(quest_data.get('variables', {}))
	variable_tree.set_references(quest_data.get('node_references', {}).keys())

	var actions: Dictionary = quest_data.get('actions', {})
	var nodes: Dictionary = editor_data.get('nodes', {})

	for action_name in actions:
		var action_record: Dictionary = actions.get(action_name, {})
		var action_class_script: GDScript = QuestSystem.get_action_script(action_record.get('class', ''))
		var action: QuestAction
		if not action_class_script:
			action = QuestAction.new(variable_tree.get_quest_variables(), variable_tree.get_references())
		else:
			action = action_class_script.new(variable_tree.get_quest_variables(), variable_tree.get_references(), action_record.get('properties', []))

		var size: Vector2 = str_to_var(nodes.get(action_name, {}).get('size', var_to_str(Vector2.INF)))
		var position: Vector2 = str_to_var(nodes.get(action_name, {}).get('position', var_to_str(Vector2.INF)))
		graph_edit.add_node(action, action_name, position, size)

		connection_list.append_array(action_record.get('connections', []).map(_add_from_node.bind(action_name)))

	for connection in connection_list:
		graph_edit.connect_node(connection['from_node'], connection['from_port'], connection['to_node'], connection['to_port'])
