class_name QuestNode
extends Node

enum Status {
	INACTIVE,
	ACTIVE,
	FINISHED
}

@export var quest_data: QuestData
@export var active: bool = true

var quest_status: Status = Status.INACTIVE

var quest_variables: QuestVariables
var active_actions: Array[StringName] = []
var next_to_activate: StringName


func _ready() -> void:
	_process_action(quest_data.start_action)


func _process_action(action_name: String) -> void:
	if not active:
		return

	active_actions.append(action_name)
	var action_record: Dictionary = quest_data.actions.get(action_name, {})
	var action_class_name: StringName = action_record.get('class', 'QuestAction')
	var action_connections: Array = action_record.get('connections', [])
	var action_properties: Array = action_record.get('properties', [])
	var action_class := QuestSystem.get_action_script(action_class_name).new(quest_variables, action_properties) as QuestAction
	action_class.performed.connect(_on_action_performed.bind(action_name))
	print('Выполняем задачу ', action_class_name)
	action_class.perform()


func _on_action_performed(action_name: String) -> void:
	prints('задача выполнена')
	var action_record: Dictionary = quest_data.actions.get(action_name, {})
	var action_connections: Array = action_record.get('connections', [])
	for connection in action_connections:
		_process_action(connection['to_node'])

		#if not active_quest_actions.has(connection['to_node']):
			#active_quest_actions.append(connection['to_node'])

	#pass



func set_save_data(save_data: Dictionary) -> void:
	pass


func get_save_data() -> Dictionary:
	return {}


#var wait_actions: Array[StringName] = []
#var active_quest_actions: Array[StringName] = []
#var quest_variables: QuestVariables
#
#
#func _ready() -> void:
	#if wait_actions.is_empty():
		#wait_actions.append(quest_data.start_action)
	#set_active(active)
#
#
#func _process(delta: float) -> void:
	#if not active:
		#return
#
	#_process_action()
#
#
#func _process_action() -> void:
	#if active_quest_actions.is_empty():
		#return
#
	#var action_name: StringName = active_quest_actions.pop_front()
	#var action_record: Dictionary = quest_data.actions.get(action_name, {})
	#var action_class_name: StringName = action_record.get('class', 'QuestAction')
	#var action_connections: Array = action_record.get('connections', [])
	#var action_properties: Array = action_record.get('properties', [])
	##print(action_record)
	#var action_class := QuestSystem.get_action_script(action_class_name).new(quest_variables, action_properties) as QuestAction
	#action_class.performed.connect(_on_action_performed.bind(action_connections))
	#print('Выполняем задачу ', action_class_name)
	#action_class.perform()
#
#
#func _on_action_performed(connections: Array) -> void:
	## Тут выбираем следующую ноду и активируем её
	#for connection in connections:
		#if not active_quest_actions.has(connection['to_node']):
			#active_quest_actions.append(connection['to_node'])
	#prints('задача выполнена')
	#pass
#
#
#func set_active(value: bool) -> void:
	#if not quest_data:
		#active = false
#
	#active_quest_actions.append(quest_data.start_action)
	#active = value
#
#
#func is_active() -> bool:
	#return active
