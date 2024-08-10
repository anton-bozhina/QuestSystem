@tool
class_name QuestActionFunctionPrint
extends QuestActionFunction


static var node_name  = 'Print'

@export_multiline var message: String


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_function() -> void:
	print(message)
