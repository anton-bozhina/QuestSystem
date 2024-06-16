@tool
class_name QuestAction
extends RefCounted

var name: StringName = 'Action'
var node_caption: String = ''
var ignore: bool = false

var variables: Dictionary : set = set_variables, get = get_variables


func get_variables() -> Dictionary:
	return variables


func set_variables(new_variables: Dictionary) -> void:
	variables = new_variables


func get_variable_value(variable_name: String) -> Variant:
	return variables.get(variable_name, {'type': TYPE_NIL, 'value': null}).get('value')


func set_variable_value(variable_name: String, variable_value: Variant) -> void:
	variables[variable_name]['value'] = variable_value


func get_variable_type(variable_name: String) -> int:
	return variables.get(variable_name, {'type': TYPE_NIL, 'value': null}).get('type')


func _init() -> void:
	ignore = true


class Variables:
	var _properties: Dictionary = {}

	func _get(property: StringName) -> Variant:
		return _properties.get(property)

	func _set(property: StringName, value: Variant) -> bool:
		_properties[property] = value
		return true


func _get_variables() -> Variables:
	return Variables.new()


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
