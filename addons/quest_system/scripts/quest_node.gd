class_name QuestNode
extends Node


@export var quest_data: QuestData
@export var active: bool = false

var active_quest_actions: Array[StringName] = []


func _ready() -> void:
	set_active(active)


func _process(delta: float) -> void:
	if not active:
		return

	_process_action()


func _process_action() -> void:
	var first_action_name: StringName = active_quest_actions.pop_front()
	var action = quest_data.actions.get(first_action_name)
	if action['class'].has_signal('wait_is_ower'):
		return
	var connections = action['connections']
	for connection in connections:
		if not active_quest_actions.has(connection['to_node']):
			active_quest_actions.append(connection['to_node'])
	print(first_action_name)


func set_active(value: bool) -> void:
	if not quest_data:
		active = false

	active_quest_actions.append(quest_data.start_action)
	active = value


func is_active() -> bool:
	return active
