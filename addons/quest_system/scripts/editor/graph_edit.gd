@tool
class_name QuestEditorGraphEdit
extends GraphEdit


signal open_button_pressed
signal save_button_pressed
signal new_button_pressed
signal graph_edit_changed


const BUTTONS: Dictionary = {
	'New': 'new_button_pressed',
	'Open': 'open_button_pressed',
	'Save': 'save_button_pressed'
}

@export var graph_node: PackedScene

var active_quest_data: QuestData

var _node_list: Array[QuestEditorGraphNode] = []
var _quest_data_label: Label


func _ready() -> void:
	_create_menu_buttons()
	_create_menu_label()


func _create_menu_buttons() -> void:
	var menu: HBoxContainer = get_menu_hbox()
	for index in range(BUTTONS.keys().size()):
		var button: Button = _create_button(BUTTONS.keys()[index])
		button.pressed.connect(func(): emit_signal(BUTTONS[BUTTONS.keys()[index]]))
		menu.add_child(button)
		menu.move_child(button, index)


func _create_menu_label() -> void:
	var menu: HBoxContainer = get_menu_hbox()
	var label: Label = Label.new()
	menu.add_child(label)
	_quest_data_label = label
	update_quest_data_label()


func update_quest_data_label() -> void:
	var quest_data_path: String = active_quest_data.get_path() if active_quest_data and not active_quest_data.get_path().is_empty() else 'Not Saved'
	var saved_text: String = '' if active_quest_data and not active_quest_data.changes_not_saved else ' (*)'
	_quest_data_label.text = 'Quest: %s%s' % [quest_data_path, saved_text]


func _create_button(text: String) -> Button:
	var new_button: Button = Button.new()
	new_button.text = text
	return new_button


func _delete_all_nodes() -> void:
	var node_names: Array[StringName] = []
	for node in _node_list:
		node_names.append(node.name)
	delete_nodes_request.emit(node_names)


func _connections_filter(connection: Dictionary, node_name: StringName) -> bool:
	return connection['from_node'] == node_name


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
		node_name = ('%s_%d' % [action.name, active_quest_data.get_node_id()]).validate_node_name()
	if node_position == Vector2.INF:
		node_position = ((scroll_offset + size / 5) / zoom).snapped(Vector2(snapping_distance, snapping_distance))

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


func save_to_active_quest_data() -> void:
	active_quest_data.graph_edit_zoom = get_zoom()
	active_quest_data.graph_edit_scroll_offset = get_scroll_offset()
	active_quest_data.actions = {}

	for node in _node_list as Array[QuestEditorGraphNode]:
		var node_name: StringName = node.name
		active_quest_data.actions[node_name] = {
			'position': node.get_position_offset(),
			'size': node.get_size(),
			'class': node.action,
			'connections': get_connection_list().filter(_connections_filter.bind(node_name))
		}
		if node.action is QuestActionLogicStart:
			active_quest_data.quest_name = node.action.get('quest_name')
			active_quest_data.quest_description = node.action.get('quest_description')
			active_quest_data.start_action = node_name


func load_from_active_quest_data() -> void:
	var connection_list: Array[Dictionary] = []

	set_zoom(active_quest_data.graph_edit_zoom)
	set_scroll_offset(active_quest_data.graph_edit_scroll_offset)

	_delete_all_nodes()
	for action_name in active_quest_data.actions:
		var action_class: QuestAction = active_quest_data.actions[action_name]['class']
		var size: Vector2 = active_quest_data.actions[action_name].get('size', Vector2.INF)
		var position: Vector2 = active_quest_data.actions[action_name].get('position', Vector2.INF)
		var connections: Array = active_quest_data.actions[action_name].get('connections', [])
		add_node(action_class, action_name, position, size)
		connection_list.append_array(connections)

	for connection in connection_list:
		connect_node(connection['from_node'], connection['from_port'], connection['to_node'], connection['to_port'])

	active_quest_data.changes_not_saved = false
	update_quest_data_label()
