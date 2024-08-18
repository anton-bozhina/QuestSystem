@tool
class_name QuestographContext
extends Resource

signal variables_changed(variable: StringName)


class Variable:
	var value: Variant = false
	var type: Variant.Type = TYPE_NIL

	func _init(variable_value: Variant = false, variable_type: Variant.Type = TYPE_NIL) -> void:
		value = variable_value
		type = variable_type


class Variables:
	signal changed(variable: StringName)

	var context_name: String = ''
	var context_path: String = ''

	var _variables: Dictionary

	func _set(property: StringName, value: Variant) -> bool:
		if _variables.get(property) is Variable:
			_variables.get(property).value = type_convert(value, _variables.get(property).type)
		else:
			_variables[property] = Variable.new(value, typeof(value))

		changed.emit(property)
		return true

	func _get(property: StringName) -> Variant:
		var variable_value: Variant = _variables.get(property)
		if variable_value and variable_value is not Variable:
			_variables[property] = Variable.new(variable_value, typeof(variable_value))
		elif not variable_value:
			push_warning('Variable %s does not exist in context %s, return false!' % [property, context_path])
			return false
		return _variables.get(property).value

	func _to_string() -> String:
		return str(_variables)

	func keys() -> PackedStringArray:
		return _variables.keys() as PackedStringArray

	func get_variables() -> Dictionary:
		return _variables

	func set_variables(variables: Dictionary) -> void:
		_variables = variables
		changed.emit('')

	func get_variable(variable: StringName) -> Variant:
		return get(variable)

	func set_variable(variable: StringName, value: Variant) -> void:
		set(variable, value)

	func erase(variable: StringName) -> void:
		_variables.erase(variable)
		changed.emit(variable)

	func has(variable: StringName) -> bool:
		return _variables.has(variable)

	func clear() -> void:
		_variables.clear()
		changed.emit('')


@export var test: QuestographNodeSettings


const AVAILABLE_TYPES: PackedStringArray = [
	'Null',
	'Bool:%d' % TYPE_BOOL,
	'Integer:%d' % TYPE_INT,
	'Float:%d' % TYPE_FLOAT,
	'String:%d' % TYPE_STRING,
	'Vector2:%d' % TYPE_VECTOR2,
	'Vector3:%d' % TYPE_VECTOR3,
	'NodePath:%d' % TYPE_NODE_PATH,
	'Resource:%d' % TYPE_OBJECT
]
const DEFAULT_VALUES: Dictionary = {
		TYPE_NIL: null,
		TYPE_BOOL: false,
		TYPE_INT: 0,
		TYPE_FLOAT: 0,
		TYPE_STRING: '',
		TYPE_VECTOR2: Vector2.ZERO,
		TYPE_VECTOR3: Vector3.ZERO,
		TYPE_NODE_PATH: NodePath('')
	}

var variables: Variables = Variables.new()
var _variables_data: Array[Dictionary]


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	_create_array_property(property_list, 'variable', _variables_data)
	return property_list


func _create_array_property(property_list: Array[Dictionary], prefix: StringName, data: Array) -> void:
	property_list.append({
		'name': '%s_count' % prefix,
		'class_name': '%ss,%s_,add_button_text=Add %s,page_size=10' % [prefix.capitalize(), prefix, prefix.capitalize()],
		'type': TYPE_INT,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		'hint': PROPERTY_HINT_NONE,
		'hint_string': ''
	})
	for index in data.size():
		if data[index].type == TYPE_NIL:
			property_list.append({
				'name': '%s_%d/type' % [prefix, index],
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(AVAILABLE_TYPES),
				'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			})
		else:
			property_list.append({
				'name': '%s_%d/type' % [prefix, index],
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(AVAILABLE_TYPES),
				'usage': PROPERTY_USAGE_STORAGE
			})
		if data[index].type != TYPE_NIL:
			property_list.append({
				'name': '%s_%d/name' % [prefix, index],
				'type': TYPE_STRING
			})
			var all_value_properties: Dictionary = get_meta('value_properties', {})
			var value_properties: Dictionary = all_value_properties.get(data[index].type, {
				'class_name': &'',
				'hint': PROPERTY_HINT_NONE,
				'hint_string': '',
			})
			value_properties.merge({
				'name': '%s_%d/value' % [prefix, index],
				'type': data[index].type
			})
			property_list.append(value_properties)
			#{ "name": "test", "class_name": &"QuestographNodeSettings", "type": 24, "hint": 17, "hint_string": "QuestographNodeSettings", "usage": 4102 }


func _set(property: StringName, value: Variant) -> bool:
	match property:
		'variable_count':
			_variables_data.resize(value)
			for index in _variables_data.size():
				if not _variables_data[index]:
					_variables_data[index] = {
						type = TYPE_NIL,
						name = 'new_variable_%d' % (index + 1),
						value = null
					}
			notify_property_list_changed()
		property when property.begins_with('variable_'):
			var splited_property: PackedStringArray = property.trim_prefix('variable_').split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			if key == 'type':
				notify_property_list_changed()
			_variables_data[index][key] = value
			_update_variables()
	return true


func _get(property: StringName) -> Variant:
	match property:
		'variable_count':
			return _variables_data.size()
		property when property.begins_with('variable_'):
			var splited_property: PackedStringArray = property.trim_prefix('variable_').split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			return _variables_data[index].get(key)
	return null


func _update_variables() -> void:
	variables.clear()
	if variables.changed.is_connected(_on_variables_changed):
		variables.changed.disconnect(_on_variables_changed)

	for variable in _variables_data:
		if not variable.type:
			continue
		variables[variable.name] = type_convert(variable.value, variable.type)

	variables.changed.connect(_on_variables_changed)


func _on_variables_changed(variable: StringName) -> void:
	variables_changed.emit(variable)
	emit_changed()


func get_variables() -> Dictionary:
	return variables.get_variables()


func set_variables(variable_dict: Dictionary) -> void:
	variables.set_variables(variable_dict)


func get_variable(variable: StringName) -> Variant:
	return variables.get_variable(variable)


func set_variable(variable: StringName, value: Variant) -> void:
	variables.set_variable(variable, value)


func get_variable_list(type_filter: Array[int] = []) -> PackedStringArray:
	if type_filter.is_empty():
		return variables.keys()

	var result: PackedStringArray = []
	for variable in variables.get_variables():
		if typeof(variables.get_variable(variable)) in type_filter:
			result.append(variable)

	return result


func erase_variable(name: StringName) -> void:
	variables.erase(name)


func has_variable(name: StringName) -> bool:
	return variables.has(name)


func clear_variables() -> void:
	variables.clear()
