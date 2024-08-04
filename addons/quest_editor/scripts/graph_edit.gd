@tool
class_name QuestEditorGraphEdit
extends GraphEdit


signal graph_edit_changed
signal node_data_dropped(at_position: Vector2, data: Variant)
signal cut_node_request


@export var graph_node: PackedScene

var _node_default_position: Vector2 = Vector2(200, 200)
var _node_list: Array[QuestEditorGraphNode] = []
var _quest_data_label: Label
var _mouse_entered: bool = false


func _ready() -> void:
	cut_node_request.connect(_on_cut_nodes_request)
	mouse_entered.connect(_on_mouse_interacted.bind(true))
	mouse_exited.connect(_on_mouse_interacted.bind(false))


func _on_mouse_interacted(entered: bool) -> void:
	_mouse_entered = entered


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


func _on_cut_nodes_request() -> void:
	_create_node_clipboard(true)


func _on_copy_nodes_request() -> void:
	_create_node_clipboard(false)


func _create_node_clipboard(delete_node: bool) -> void:
	var selected_node_list: Array = _node_list.filter(_is_node_selected)
	var clipboard: Array = selected_node_list.reduce(_make_node_array.bind(delete_node), [])
	DisplayServer.clipboard_set(var_to_str(clipboard))


func _is_node_selected(node: QuestEditorGraphNode) -> bool:
	return node.selected


func _make_node_array(array: Array, node: QuestEditorGraphNode, delete_node: bool) -> Array:
	array.append({
		'name': node.name,
		'connections': get_connection_list().filter(_connections_filter.bind(node.name)),
		'position': node.get_position_offset(),
		'size': node.get_size(),
		'action': node.action
	})

	if delete_node:
		delete_nodes_request.emit([node.name] as Array[StringName])

	return array


func _on_paste_nodes_request() -> void:
	var clipboard: Variant = str_to_var(DisplayServer.clipboard_get())
	if typeof(clipboard) != TYPE_ARRAY:
		return

	var connections: Array[Dictionary] = []
	var node_names: Dictionary = {}
	var selected_node_list: Array = clipboard
	var position_offset: Vector2 = get_local_mouse_position() if _mouse_entered else Vector2(200, 200)
	var paste_position: Vector2 = (scroll_offset + position_offset) / zoom
	var start_position: Vector2 = selected_node_list.reduce(_calculate_node_rect, Rect2(0, 0, 0, 0)).position

	for node in selected_node_list:
		if typeof(node) != TYPE_DICTIONARY:
			continue
		elif not node.get('action') is QuestAction:
			continue

		var node_position: Vector2 = node.get('position', Vector2.ZERO)
		var node_size: Vector2 = node.get('size', Vector2.ZERO)
		var node_name: String = node.get('name', '')
		var node_connections: Array[Dictionary] = node.get('connections', [])
		var new_node: QuestEditorGraphNode = add_node(node['action'], '', paste_position + node_position - start_position, node_size)
		node_names[node_name] = new_node.name
		connections.append_array(node_connections)

	_connect_pasted_nodes(connections, node_names)
	set_selected(null)


func _on_duplicate_nodes_request() -> void:
	var node_names: Dictionary = {}
	var connections: Array[Dictionary] = []

	var selected_node_list: Array = _node_list.filter(_is_node_selected)
	var selected_node_rect: Rect2 = selected_node_list.reduce(_calculate_node_rect, Rect2(0, 0, 0, 0))
	var paste_position: Vector2 = Vector2(selected_node_rect.position.x, selected_node_rect.position.y + selected_node_rect.size.y + 20)
	var start_position: Vector2 = selected_node_rect.position

	for node in selected_node_list:
		var action_string: String = var_to_str(node.action)
		var new_node: QuestEditorGraphNode = add_node(str_to_var(action_string), '', paste_position + node.position_offset - start_position, node.size)
		node_names[node.name] = new_node.name
		connections.append_array(get_connection_list().filter(_connections_filter.bind(node.name)))

	_connect_pasted_nodes(connections, node_names)


func _calculate_node_rect(rect: Rect2, node: Variant) -> Rect2:
	var node_rect: Rect2
	if node is QuestEditorGraphNode:
		node_rect = Rect2(node.position_offset, node.size)
	elif typeof(node) == TYPE_DICTIONARY:
		node_rect = Rect2(node.get('position', Vector2.ZERO), node.get('size', Vector2.ZERO))
	else:
		return rect

	if rect == Rect2(0, 0, 0, 0):
		rect = node_rect
	else:
		rect = rect.merge(node_rect)
	return rect


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


func _connect_pasted_nodes(connections: Array, pasted_names: Dictionary) -> void:
	for connection in connections:
		if not pasted_names.has(connection['from_node']) or not pasted_names.has(connection['to_node']):
			continue
		connect_node(pasted_names[connection['from_node']], connection['from_port'], pasted_names[connection['to_node']], connection['to_port'])


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
