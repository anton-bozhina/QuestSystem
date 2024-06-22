@tool
class_name QuestAction
extends RefCounted

var node_caption: String = ''

var variables: QuestVariables


func _init(quest_variables: QuestVariables, properties: Array = []) -> void:
	variables = quest_variables
	for property in properties:
		set(property['name'], property['value'])

	#if Engine.is_editor_hint():
		#_node_init()
	_node_init()
	_action_init()


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass




#func _action_task(_arguments: Arguments) -> void:
	#pass


func perform() -> void:
	pass
	#get_tree().process_frame.connect(_action_task.bind(_get_arguments()), CONNECT_ONE_SHOT)


#@export var active: bool = false : set = set_active
#
#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_DISABLED
	#
#
#
#
#func set_active(value: bool) -> void:
	#if value:
		#process_mode = Node.PROCESS_MODE_INHERIT
	#else:
		#process_mode = Node.PROCESS_MODE_DISABLED
#
	#active = value


#get_tree().process_frame.connect(callable, CONNECT_ONE_SHOT)
