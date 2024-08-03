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


func add_node(action: QuestAction, node_name: StringName = '', node_position: Vector2 = Vector2.INF, node_size: Vector2 = Vector2.INF) -> QuestEditorGraphNode:
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

	#var debug_name_label: Label = Label.new()
	#debug_name_label.text = node_name
	#new_node.add_child(debug_name_label)

	add_child(new_node)
	_node_list.append(new_node)
	new_node.property_changed.connect(_on_node_property_changed)
	graph_edit_changed.emit()

	return new_node


func get_new_node_position(at_position: Vector2) -> Vector2:
	return ((scroll_offset + at_position) / zoom).snapped(Vector2(snapping_distance, snapping_distance))


func update_variables(variables: Array[QuestVariables], node_references: Dictionary) -> void:
	graph_edit_changed.emit()
	for node in _node_list as Array[QuestEditorGraphNode]:
		node.action.variables = variables
		node.action.node_references = node_references
		node._create_controls()


func get_nodes() -> Array[QuestEditorGraphNode]:
	return _node_list


func clear() -> void:
	var node_names: Array[StringName] = []
	for node in _node_list:
		node_names.append(node.name)
	delete_nodes_request.emit(node_names)


func _on_cut_nodes_request() -> void:
	_create_node_clipboard(true)


func _on_copy_nodes_request() -> void:
	_create_node_clipboard(false)


func _create_node_clipboard(delete_node: bool) -> void:
	var clipboard: Dictionary = {}
	for node in _node_list:
		if not node.selected:
			continue

		clipboard[node.name] = {
			'connections': get_connection_list().filter(_connections_filter.bind(node.name)),
			'position': node.get_position_offset(),
			'size': node.get_size(),
			'action': node.action
		}

		if delete_node:
			delete_nodes_request.emit([node.name])

	DisplayServer.clipboard_set(var_to_str(clipboard))


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


func _sort_nodes(first: StringName, second: StringName, data: Dictionary) -> bool:
	return data[first].get('position', Vector2.ZERO).x < data[second].get('position', Vector2.ZERO).x


func _on_paste_nodes_request() -> void:
	if typeof(str_to_var(DisplayServer.clipboard_get())) != TYPE_DICTIONARY:
		return

	set_selected(null)

	var clipboard: Dictionary = str_to_var(DisplayServer.clipboard_get())
	var start_position: Vector2 = (scroll_offset + get_local_mouse_position()) / zoom
	var first_position: Vector2 = Vector2.INF
	var connections: Array[Dictionary] = []
	var node_names: Dictionary = {}

	var sorted_keys: Array = clipboard.keys()
	sorted_keys.sort_custom(_sort_nodes.bind(clipboard))

	for node in sorted_keys:
		if not clipboard[node].get('action') is QuestAction:
			continue

		var node_position: Vector2 = clipboard[node].get('position', Vector2.ZERO)
		var node_size: Vector2 = clipboard[node].get('size', Vector2.ZERO)
		var node_connections: Array[Dictionary] = clipboard[node].get('connections', [])
		if first_position == Vector2.INF:
			first_position = node_position
		var new_node = add_node(clipboard[node]['action'], '', start_position + node_position - first_position, node_size)
		node_names[node] = new_node.name
		connections.append_array(node_connections)


	for connection in connections:
		if not node_names.has(connection['from_node']) or not node_names.has(connection['to_node']):
			continue
		connect_node(node_names[connection['from_node']], connection['from_port'], node_names[connection['to_node']], connection['to_port'])
