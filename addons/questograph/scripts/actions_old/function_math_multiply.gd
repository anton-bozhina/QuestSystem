@tool
class_name QuestActionFunctionMathMultiply
extends QuestActionFunction


static var node_name  = 'MathMultiply'

enum FirstOperandSource {
	LOCAL,
	GLOBAL
}

enum SecondOperandSource {
	LOCAL,
	GLOBAL,
	DIRECT
}

@export var first_source: FirstOperandSource
@export var second_source: SecondOperandSource

var first_operand: Variant
var second_operand: Variant


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []

	property_list.append({
		'name': 'first_operand',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(variables[first_source].get_variable_list([TYPE_INT, TYPE_FLOAT])),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})

	match second_source:
		SecondOperandSource.DIRECT:
			property_list.append({
				'name': 'second_operand',
				'type': TYPE_FLOAT,
				'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
			})
		_:
			property_list.append({
				'name': 'second_operand',
				'type': TYPE_STRING,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(variables[second_source].get_variable_list([TYPE_INT, TYPE_FLOAT])),
				'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
			})


	return property_list


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_function() -> void:
	var first_value: Variant = variables[first_source].get_variable(first_operand)
	var first_value_type: Variant.Type = variables[first_source].get_variable_type(first_operand)
	var second_value: Variant
	if second_source == SecondOperandSource.DIRECT:
		second_value = second_operand
	else:
		second_value = variables[second_source].get_variable(second_operand)

	if first_value == null or second_value == null:
		return

	first_value *= second_value

	variables[first_source].set_variable(first_operand, convert(first_value, first_value_type))
