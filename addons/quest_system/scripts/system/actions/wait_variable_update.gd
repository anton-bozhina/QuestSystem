@tool
class_name QuestActionWaitVariableUpdate
extends QuestActionWait


var variable: String = ''


func _init() -> void:
	name = 'WaitVarUpdate'


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'variable',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(get_variables().keys()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})

	return property_list
