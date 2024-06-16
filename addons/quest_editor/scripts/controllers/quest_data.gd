@tool
class_name QuestEditorQuestDataController
extends Node


func _get_editor_version() -> String:
	return owner.get_meta('version', '0.0')


func _path_filter(class_data: Dictionary, class_path: String) -> bool:
	return class_data['path'] == class_path


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


func _clear_from_node(connection: Dictionary) -> Dictionary:
	connection.erase('from_node')
	return connection


func editor_data_to_quest_data(graph_edit: QuestEditorGraphEdit, quest_data: QuestData) -> void:
	var result: Dictionary = {
		'editor': {
			'version': _get_editor_version(),
			'graph_edit_zoom': graph_edit.get_zoom(),
			'graph_edit_scroll_offset': graph_edit.get_scroll_offset(),
			'nodes': {}
		},
		'name': '',
		'description': '',
		'variables': quest_data.quest_variables,
		'start_action': '',
		'actions': {}
	}

	quest_data.graph_edit_zoom = graph_edit.get_zoom()
	quest_data.graph_edit_scroll_offset = graph_edit.get_scroll_offset()
	quest_data.actions = {}

	for node in graph_edit.get_nodes() as Array[QuestEditorGraphNode]:
		var node_name: StringName = node.name
		#node.action.variables = {}
		#node.action.tree = null
		quest_data.actions[node_name] = {
			'position': node.get_position_offset(),
			'size': node.get_size(),
			'class': node.action,
			'connections': graph_edit.get_connection_list().filter(_connections_filter.bind(node_name))
		}

		var action_class_path: String = node.action.get_script().get_path()
		var filtered_classes: Array[Dictionary] = ProjectSettings.get_global_class_list().filter(_path_filter.bind(action_class_path))
		if filtered_classes.is_empty():
			continue

		var action_class_name = filtered_classes[0]['class']
		result['actions'][node_name] = {
			'class': action_class_name,
			'connections': graph_edit.get_connection_list().filter(_connections_filter.bind(node_name)).map(_clear_from_node),
			'properties': {}
		}
		result['editor']['nodes'][node_name] = {
			'position': node.get_position_offset(),
			'size': node.get_size(),
		}
		for control in node.control_list:
			result['actions'][node_name]['properties'][node.control_list[control]] = control.get_property_value()


		if node.action is QuestActionLogicStart:
			quest_data.quest_name = node.action.get('quest_name')
			quest_data.quest_description = node.action.get('quest_description')
			quest_data.start_action = node_name

			result['name'] = node.action.get('quest_name')
			result['description'] = node.action.get('quest_description')
			result['start_action'] = node_name


	var file = FileAccess.open('res://new_quest_system.quest', FileAccess.WRITE)
	file.store_string(JSON.stringify(result, '\t'))
	file.close()


func quest_data_to_editor_data(graph_edit: QuestEditorGraphEdit, quest_data: QuestData) -> void:
	var connection_list: Array[Dictionary] = []

	graph_edit.clear()
	graph_edit.set_zoom(quest_data.graph_edit_zoom)
	graph_edit.set_scroll_offset(quest_data.graph_edit_scroll_offset)

	for action_name in quest_data.actions:
		var action_class: QuestAction = quest_data.actions[action_name]['class']
		var size: Vector2 = quest_data.actions[action_name].get('size', Vector2.INF)
		var position: Vector2 = quest_data.actions[action_name].get('position', Vector2.INF)
		var connections: Array = quest_data.actions[action_name].get('connections', [])
		graph_edit.add_node(action_class, action_name, position, size)
		connection_list.append_array(connections)

	for connection in connection_list:
		graph_edit.connect_node(connection['from_node'], connection['from_port'], connection['to_node'], connection['to_port'])
