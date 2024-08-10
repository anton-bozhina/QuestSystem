@tool
class_name QuestActionCheckNodeProcessMode
extends QuestActionCheck


static var node_name = 'NodeProcessModeCheck'


enum ProcessMode {
	INHERIT,
	PAUSABLE,
	WHEN_PAUSED,
	ALWAYS,
	DISABLED
}

var reference: String = ''
var operator: Variant.Operator = Variant.Operator.OP_EQUAL
var mode: int

var operators = [
	'==',		# OP_EQUAL = 0
	'!='		# OP_NOT_EQUAL = 1
]


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'reference',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(node_references.keys()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': 'operator',
		'type': TYPE_INT,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(operators),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': 'mode',
		'type': TYPE_INT,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(ProcessMode.keys()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	return property_list


func _perform_check() -> bool:
	var node_object: Node = node_references.get(reference)
	if not node_object:
		return false

	match operator:
		Variant.Operator.OP_EQUAL:
			return node_object.process_mode == mode
		Variant.Operator.OP_NOT_EQUAL:
			return node_object.process_mode != mode

	return false
