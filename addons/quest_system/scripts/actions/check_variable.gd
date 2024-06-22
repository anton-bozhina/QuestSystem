@tool
class_name QuestActionCheckVariable
extends QuestActionCheck


static var node_name = 'VariableCheck'


var variable: String = ''
var condition: String = '=='
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
	property_list.append({
		'name': 'condition',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(CONDITIONS),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	if not variables.get_variable_type(variable) == TYPE_NIL:
		property_list.append({
			'name': 'value',
			'type': variables.get_variable_type(variable),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	return property_list
