@tool
class_name QuestActionFunctionSetProcessMode
extends QuestActionFunction


static var node_name  = 'NodeProcessModeSet'

enum ProcessMode {
	INHERIT,
	PAUSABLE,
	WHEN_PAUSED,
	ALWAYS,
	DISABLED
}

var reference: String = ''
var mode: int


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
		'name': 'mode',
		'type': TYPE_INT,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(ProcessMode.keys()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	return property_list


func _perform_function() -> void:
	var node_object: Node = node_references.get(reference)
	if not node_object:
		return

	node_object.process_mode = mode
