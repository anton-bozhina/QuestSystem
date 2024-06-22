class_name QuestVariables
extends RefCounted


var _variables: Dictionary


func _init(variables: Dictionary = {}) -> void:
	for variable in variables:
		var value: Variant = variables.get(variable, {'value': null, 'type': TYPE_NIL})['value']
		var type: int = variables.get(variable, {'value': null, 'type': TYPE_NIL})['type']
		set_variable(variable, value, type)


func set_variable(name: StringName, value: Variant, type: int = TYPE_NIL) -> void:
	if name.is_empty():
		return

	_variables[name] = {
		'value': value,
		'type': typeof(value) if type == TYPE_NIL else type
	}


func get_variables() -> Dictionary:
	return _variables


func get_variable(name: StringName) -> Variant:
	return _variables.get(name, {'value': null, 'type': TYPE_NIL})['value']


func get_variable_type(name: String) -> int:
	return _variables.get(name, {'value': null, 'type': TYPE_NIL})['type']


func get_variable_list() -> PackedStringArray:
	return _variables.keys()


func remove_variable(name: StringName) -> void:
	_variables.erase(name)


func has_variable(name: StringName) -> bool:
	return _variables.has(name)


func clear() -> void:
	_variables.clear()