@tool
class_name QuestEditorGraphEdit
extends GraphEdit


signal graph_edit_changed
signal node_data_dropped(at_position: Vector2, data: Variant)


@export var graph_node: PackedScene

var _node_default_position: Vector2 = Vector2(200, 200)
var _node_list: Array[QuestEditorGraphNode] = []
var _quest_data_label: Label


func _generate_id() -> String:
	var length: int = 8
	var result: String
	for index in range(length):
		result += '%02x' % (randi() % 256)
	return result


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is GDScript


func _drop_data(at_position: Vector2, data: Variant) -> void:
	node_data_dropped.emit(at_position, data)


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


func _on_end_node_move() -> void:
	graph_edit_changed.emit()


func _on_node_property_changed() -> void:
	graph_edit_changed.emit()


func add_node(action: QuestAction, node_name: StringName = '', node_position: Vector2 = Vector2.INF, node_size: Vector2 = Vector2.INF) -> void:
	if node_name.is_empty():
		node_name = '%s_%s' % [action.node_name, _generate_id()]

	if node_position == Vector2.INF:
		node_position = _node_default_position

	var new_node := graph_node.instantiate() as QuestEditorGraphNode
	new_node.name = node_name
	new_node.set_position_offset(node_position)
	if not node_size == Vector2.INF:
		new_node.set_size(node_size)

	new_node.set_action(action)

	var debug_name_label: Label = Label.new()
	debug_name_label.text = node_name
	new_node.add_child(debug_name_label)

	add_child(new_node)
	_node_list.append(new_node)
	new_node.property_changed.connect(_on_node_property_changed)
	graph_edit_changed.emit()


func get_new_node_position(at_position: Vector2) -> Vector2:
	return ((scroll_offset + at_position) / zoom).snapped(Vector2(snapping_distance, snapping_distance))


func update_variables(variables: QuestVariables) -> void:
	graph_edit_changed.emit()
	for node in _node_list as Array[QuestEditorGraphNode]:
		node.action.variables = variables
		node._create_controls()


func get_nodes() -> Array[QuestEditorGraphNode]:
	return _node_list


func clear() -> void:
	var node_names: Array[StringName] = []
	for node in _node_list:
		node_names.append(node.name)
	delete_nodes_request.emit(node_names)
