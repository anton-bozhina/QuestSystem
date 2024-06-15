@tool
class_name QuestEditorQuestDataAction
extends Node


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


func editor_data_to_quest_data(graph_edit: QuestEditorGraphEdit, quest_data: QuestData) -> void:
	quest_data.graph_edit_zoom = graph_edit.get_zoom()
	quest_data.graph_edit_scroll_offset = graph_edit.get_scroll_offset()
	quest_data.actions = {}

	for node in graph_edit._node_list as Array[QuestEditorGraphNode]:
		var node_name: StringName = node.name
		#node.action.variables = {}
		#node.action.tree = null
		quest_data.actions[node_name] = {
			'position': node.get_position_offset(),
			'size': node.get_size(),
			'class': node.action,
			'connections': graph_edit.get_connection_list().filter(_connections_filter.bind(node_name))
		}
		if node.action is QuestActionLogicStart:
			quest_data.quest_name = node.action.get('quest_name')
			quest_data.quest_description = node.action.get('quest_description')
			quest_data.start_action = node_name


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
