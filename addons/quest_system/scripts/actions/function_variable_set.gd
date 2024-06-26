@tool
class_name QuestActionFunctionVariableSet
extends QuestActionFunction


static var node_name = 'VariableSet'

var variable: String = ''
var value: Variant


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'variable',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(variables.get_variable_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	if not variables.get_variable_type(variable) == TYPE_NIL:
		property_list.append({
			'name': 'value',
			'type': variables.get_variable_type(variable),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	return property_list


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_function() -> void:
	variables.set_variable(variable, value)
