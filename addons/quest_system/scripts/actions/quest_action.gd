@tool
class_name QuestAction
extends Resource


signal performed(from_port: int)

enum Variable {
	LOCAL,
	GLOBAL
}

var node_caption: String = ''
var variables: Array[QuestVariables]
var node_references: Dictionary


func _init(quest_variables: Array[QuestVariables], references: Dictionary, properties: Array = []) -> void:
	variables = quest_variables
	node_references = references
	for property in properties:
		set(property['name'], property['value'])

	_node_init()
	_action_init()


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_task() -> void:
	performed.emit(0)


func _get_action_data() -> Dictionary:
	return {}


func _set_action_data(data: Dictionary) -> void:
	pass


func get_action_data() -> Dictionary:
	return _get_action_data()


func set_action_data(data: Dictionary) -> void:
	_set_action_data(data)


func perform() -> void:
	_perform_task()


func get_mainLoop() -> MainLoop:
	return Engine.get_main_loop()
