@tool
class_name QuestActionCheckVariable
extends QuestActionCheck


var variable: String = ''
var condition: String = '=='
var value: Variant


func _init() -> void:
	name = 'VariableCheck'


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'variable',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(get_variables().keys()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': 'condition',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(CONDITIONS),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	if not get_variable_type(variable) == TYPE_NIL:
		property_list.append({
			'name': 'value',
			'type': get_variable_type(variable),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	return property_list
