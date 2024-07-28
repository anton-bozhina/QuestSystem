@tool
class_name QuestNode
extends Node

@export var quest_data: QuestData:
	set(value):
		quest_data = value
		if Engine.is_editor_hint():
			if value:
				node_references = value.node_references
				for reference in node_references:
					node_references[reference] = NodePath()
			else:
				node_references = {}
@export var node_references: Dictionary
@export var activate_on_start: bool = true
@export var call_perform_deferred: bool = false

var active: bool = false : set = set_active, get = is_active
var active_nodes: Dictionary = {}
var quest_variables: QuestVariables = QuestVariables.new()

var _actions_to_process: Array[QuestAction] = []
var _node_objects: Dictionary = {}


func _ready() -> void:
	if not quest_data or Engine.is_editor_hint():
		return

	_add_action_to_process(quest_data.start_action)
	for reference in node_references:
		if node_references[reference] is NodePath:
			_node_objects[reference] = get_node_or_null(node_references[reference])
	quest_variables.set_variables(quest_data.variables.get('local', {}))
	QuestSystem.set_global_variables(quest_data.variables.get('global', {}))
	set_active(activate_on_start)


func _process(delta: float) -> void:
	if not active or _actions_to_process.is_empty():
		return

	var action := _actions_to_process.pop_front() as QuestAction
	if call_perform_deferred:
		action.perform.call_deferred()
	else:
		action.perform()


func _add_action_to_process(action_name: StringName) -> void:
	var action_data: Dictionary = _get_action_data(action_name)
	var action: QuestAction = action_data['action']
	action.performed.connect(_on_action_performed.bind(action_name), CONNECT_ONE_SHOT)
	active_nodes[action_name] = action_data
	_add_log('[%s] Action %s perform planned.' % [action_name, action_data['class']])
	_actions_to_process.append(action)


func _get_action_data(action_name: StringName) -> Dictionary:
	var action_record: Dictionary = quest_data.actions.get(action_name, {})
	var action_class_name: StringName = action_record.get('class', 'QuestAction')
	var action_connections: Array = action_record.get('connections', [])
	var action_properties: Array = action_record.get('properties', [])
	var variables: Array[QuestVariables] = [quest_variables, QuestSystem.get_global_variables()]
	var action_class := QuestSystem.get_action_script(action_class_name).new(variables, _node_objects, action_properties) as QuestAction
	return {
		'action': action_class,
		'class': action_class_name,
		'connections': action_connections
	}


func _on_action_performed(from_slot: int, action_name: StringName) -> void:
	_add_log('[%s] Action performed.' % [action_name])
	var action_connections: Array = active_nodes[action_name]['connections']
	active_nodes.erase(action_name)
	for connection in action_connections:
		if connection['from_port'] == from_slot:
			_add_action_to_process(connection['to_node'])


func _add_log(log_text: String) -> void:
	QuestSystem.add_log(quest_data.get_path(), log_text)


func set_active(value: bool) -> void:
	active = value
	_add_log('Quest activation set to %s.' % active)


func is_active() -> bool:
	return active


func set_save_data(save_data: Dictionary) -> void:
	_add_log('Quest is loading.')
	set_active(false)
	for action_name in active_nodes:
		var action: QuestAction = active_nodes[action_name]['action']
		#action.free()
	active_nodes.clear()

	quest_data = load(save_data['quest_data'])
	quest_variables = QuestVariables.new(save_data['quest_variables'])
	node_references = save_data['node_references']
	for reference in node_references:
		if node_references[reference] is NodePath:
			_node_objects[reference] = get_node_or_null(node_references[reference])

	call_perform_deferred = save_data['call_perform_deferred']
	for action_name in save_data['active_nodes']:
		_add_action_to_process(action_name)

	_add_log('Quest loaded.')
	set_active(save_data['active'])


func get_save_data() -> Dictionary:
	return {
		'quest_data': quest_data.get_path(),
		'quest_variables': quest_variables.get_variables(),
		'node_references': node_references,
		'active_nodes': active_nodes.keys(),
		'call_perform_deferred': call_perform_deferred,
		'active': is_active()
	}
