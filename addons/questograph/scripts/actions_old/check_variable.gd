@tool
class_name QuestActionCheckVariable
extends QuestActionCheck


static var node_name = 'VariableCheck'


var variable: String = ''
var operator: Variant.Operator = Variant.Operator.OP_EQUAL
var value: Variant

var operators = [
	'==',		# OP_EQUAL = 0
	'!=',		# OP_NOT_EQUAL = 1
	'<',		# OP_LESS = 2
	'<=',		# OP_LESS_EQUAL = 3
	'>',		# OP_GREATER = 4
	'>='		# OP_GREATER_EQUAL = 5
]
var operators_equal = [
	'==',		# OP_EQUAL = 0
	'!='		# OP_NOT_EQUAL = 1
]


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'variable',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(variables[Variable.LOCAL].get_variable_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	if variable_is_number():
		property_list.append({
			'name': 'operator',
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(operators),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	else:
		property_list.append({
			'name': 'operator',
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(operators_equal),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	if not variables[Variable.LOCAL].get_variable_type(variable) == TYPE_NIL:
		property_list.append({
			'name': 'value',
			'type': variables[Variable.LOCAL].get_variable_type(variable),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	return property_list


func variable_is_number() -> bool:
	return variables[Variable.LOCAL].get_variable_type(variable) == TYPE_INT or variables[Variable.LOCAL].get_variable_type(variable) == TYPE_FLOAT


func _perform_check() -> bool:
	match operator:
		Variant.Operator.OP_EQUAL:
			return variables[Variable.LOCAL].get_variable(variable) == value
		Variant.Operator.OP_NOT_EQUAL:
			return variables[Variable.LOCAL].get_variable(variable) != value
		Variant.Operator.OP_LESS when variable_is_number():
			return variables[Variable.LOCAL].get_variable(variable) < value
		Variant.Operator.OP_LESS_EQUAL when variable_is_number():
			return variables[Variable.LOCAL].get_variable(variable) <= value
		Variant.Operator.OP_GREATER when variable_is_number():
			return variables[Variable.LOCAL].get_variable(variable) > value
		Variant.Operator.OP_GREATER_EQUAL when variable_is_number():
			return variables[Variable.LOCAL].get_variable(variable) >= value
	return false
