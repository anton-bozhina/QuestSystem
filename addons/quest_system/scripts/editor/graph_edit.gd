@tool
class_name QuestEditorGraphEdit
extends GraphEdit


signal graph_edit_changed

@export var graph_node: PackedScene

var _node_list: Array[QuestEditorGraphNode] = []
var _quest_data_label: Label


func _create_button(text: String) -> Button:
	var new_button: Button = Button.new()
	new_button.text = text
	return new_button


func clear() -> void:
	var node_names: Array[StringName] = []
	for node in _node_list:
		node_names.append(node.name)
	delete_nodes_request.emit(node_names)


func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	if from_node != to_node:
		connect_node(from_node, from_port, to_node, to_port)
		graph_edit_changed.emit()


func _on_delete_nodes_request(node_names: Array[StringName]) -> void:
	for node_name in node_names:
		for connection in get_connection_list():
			if connection['from_node'] == node_name or connection['to_node'] == node_name:
				disconnect_node(connection['from_node'], connection['from_port'], connection['to_node'], connection['to_port'])

		var node: GraphNode = get_node(NodePath(node_name))
		_node_list.erase(node)
		node.name = node.name + '_to_delete'
		node.queue_free()
		graph_edit_changed.emit()


func _on_disconnection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	disconnect_node(from_node, from_port, to_node, to_port)
	graph_edit_changed.emit()


func _on_node_property_changed() -> void:
	graph_edit_changed.emit()


func _on_end_node_move() -> void:
	graph_edit_changed.emit()


func add_node(action: QuestAction, node_name: StringName = '', node_position: Vector2 = Vector2.INF, node_size: Vector2 = Vector2.INF) -> void:
	if node_name.is_empty():
		node_name = OS.get_unique_id()
	if node_position == Vector2.INF:
		node_position = ((scroll_offset + size / 3) / zoom).snapped(Vector2(snapping_distance, snapping_distance))

	var new_node := graph_node.instantiate() as QuestEditorGraphNode
	new_node.name = node_name
	new_node.set_position_offset(node_position)
	if not node_size == Vector2.INF:
		new_node.set_size(node_size)
	new_node.set_action(action)
	add_child(new_node)
	_node_list.append(new_node)
	new_node.property_changed.connect(_on_node_property_changed)
	graph_edit_changed.emit()


func update_variables(variables: Dictionary) -> void:
	graph_edit_changed.emit()

	for node in _node_list as Array[QuestEditorGraphNode]:
		node.action.variables = variables
		node._create_controls()
