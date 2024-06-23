@tool
class_name QuestAction
extends Resource

signal performed

var node_caption: String = ''

var variables: QuestVariables


func _init(quest_variables: QuestVariables, properties: Array = []) -> void:
	variables = quest_variables
	for property in properties:
		set(property['name'], property['value'])

	_node_init()
	_action_init()


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _action_task() -> void:
	pass


func perform() -> void:
	_action_task()
	performed.emit()

#get_tree().process_frame.connect(callable, CONNECT_ONE_SHOT)
