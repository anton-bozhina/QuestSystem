@tool
class_name QuestAction
extends Resource


signal performed(from_port: int)

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


func _perform_task() -> void:
	performed.emit(0)


func perform() -> void:
	_perform_task()


func get_mainLoop() -> MainLoop:
	return Engine.get_main_loop()


func get_singltones() -> void:
	print(Engine.get_main_loop().get_root().get_children())
