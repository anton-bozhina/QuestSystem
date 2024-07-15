class_name QuestVariables
extends RefCounted


signal variable_updated(variable: StringName)


var _variables: Dictionary


func _init(variables: Dictionary = {}) -> void:
	set_variables(variables)


func set_variables(variables: Dictionary) -> void:
	clear()
	for variable in variables:
		var value: Variant = variables.get(variable, {'value': null, 'type': TYPE_NIL})['value']
		var type: Variant.Type = variables.get(variable, {'value': null, 'type': TYPE_NIL})['type']
		set_variable(variable, value, type)


func set_variable(name: StringName, value: Variant, type: Variant.Type = TYPE_NIL) -> void:
	if name.is_empty():
		return

	_variables[name] = {
		'value': value,
		'type': typeof(value) if type == TYPE_NIL else type
	}
	variable_updated.emit(name)


func get_variables() -> Dictionary:
	return _variables


func get_variable(name: StringName) -> Variant:
	return _variables.get(name, {'value': null, 'type': TYPE_NIL})['value']


func get_variable_type(name: String) -> Variant.Type:
	return _variables.get(name, {'value': null, 'type': TYPE_NIL})['type']


func get_variable_list(types: Array[Variant.Type] = []) -> PackedStringArray:
	if types.is_empty():
		return _variables.keys()
	else:
		var result: PackedStringArray = []
		for variable in _variables:
			if _variables[variable]['type'] in types:
				result.append(variable)
		return result


func remove_variable(name: StringName) -> void:
	_variables.erase(name)
	variable_updated.emit(name)


func has_variable(name: StringName) -> bool:
	return _variables.has(name)


func clear() -> void:
	for variable in _variables:
		remove_variable(variable)
