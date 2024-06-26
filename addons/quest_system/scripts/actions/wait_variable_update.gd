@tool
class_name QuestActionWaitVariableUpdate
extends QuestActionWait


static var node_name: StringName = 'WaitVarUpdate'

var variable: String = ''

func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'variable',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(variables.get_variable_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})

	return property_list


func _perform_wait() -> void:
	variables.variable_updated.connect(_on_variable_updated)


func _on_variable_updated(updated_variable: StringName) -> void:
	if updated_variable == variable:
		variables.variable_updated.disconnect(_on_variable_updated)
		waited.emit()
