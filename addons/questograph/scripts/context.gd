@tool
class_name QuestographContext
extends Resource


const REVERT_VALUES: Dictionary = {
	'available_types' = [
		'Bool:%d' % TYPE_BOOL,
		'Integer:%d' % TYPE_INT,
		'Float:%d' % TYPE_FLOAT,
		'String:%d' % TYPE_STRING,
		'Vector2:%d' % TYPE_VECTOR2,
		'Vector3:%d' % TYPE_VECTOR3,
		'NodePath:%d' % TYPE_NODE_PATH,
		'Resource:%d' % TYPE_OBJECT
	],
	'type_by_id' = {
				0: {
					'class_name' = &'',
					'hint' = PROPERTY_HINT_NONE,
					'hint_string' = ''
				}
	},
	'type_by_name' = {
		'': {
			'class_name' = &'',
			'hint' = PROPERTY_HINT_NONE,
			'hint_string' = ''
		}
	}
}
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
var type_by_id: Dictionary
var type_by_name: Dictionary
var available_types: Array = REVERT_VALUES['available_types']

var _variables_data: Array[Dictionary]


class Variables:
	signal changed(variable: StringName)

	var context_name: String = ''
	var context_path: String = ''

	var _variables: Dictionary

	func _set(property: StringName, value: Variant) -> bool:
		if _is_variable_correct(_variables.get(property)):
			_variables[property].value = type_convert(value, _variables.get(property, {type = TYPE_NIL}).type)
		else:
			_variables[property] = {
				value = value,
				type = typeof(value)
			}

		changed.emit(property)
		return true

	func _get(property: StringName) -> Variant:
		if not _variables.has(property):
			push_warning('Variable %s does not exist in context %s, return false!' % [property, context_path])
		elif not _is_variable_correct(_variables.get(property)):
			_variables[property] = {
				value = _variables.get(property),
				type = typeof(_variables.get(property))
			}
		return _variables.get(property, {value = false}).value

	func _is_variable_correct(variable: Variant) -> bool:
		if typeof(variable) == TYPE_DICTIONARY:
			var type: Variant.Type = variable.get('type')
			return type != TYPE_NIL and typeof(variable.get('value')) == int(type)
		return false

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


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	_create_array_property(property_list, 'variable', _variables_data)
	if get_meta('show_settings', false):
		_create_settings_property(property_list)
	return property_list


func _create_settings_property(property_list: Array[Dictionary]) -> void:
	property_list.append({
		'name': 'Settings',
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_CATEGORY
	})
	property_list.append({
		'name': 'Settings',
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_GROUP
	})
	property_list.append({
		'name': 'type_by_id',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	property_list.append({
		'name': 'type_by_name',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	property_list.append({
		'name': 'available_types',
		'type': TYPE_ARRAY,
		'hint': PROPERTY_HINT_TYPE_STRING,
		'hint_string': '4:',
		'usage': PROPERTY_USAGE_DEFAULT
	})


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
			if available_types.size() > 1:
				property_list.append({
					'name': '%s_%d/type' % [prefix, index],
					'type': TYPE_INT,
					'hint': PROPERTY_HINT_ENUM,
					'hint_string': 'Null,%s' % ','.join(available_types),
					'usage': PROPERTY_USAGE_DEFAULT
				})
			elif available_types.size() == 1:
				data[index].type = int(available_types[0].get_slice(':', 1))
			else:
				property_list.append({
					'name': '%s_%d/type' % [prefix, index],
					'type': TYPE_INT,
					'hint': PROPERTY_HINT_ENUM,
					'hint_string': 'No Types Available',
					'usage': PROPERTY_USAGE_DEFAULT
				})

		if data[index].type != TYPE_NIL:
			property_list.append({
				'name': '%s_%d/type' % [prefix, index],
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': 'Null,%s' % ','.join(available_types),
				'usage': PROPERTY_USAGE_STORAGE
			})
			var property_name_name: String = '%s_%d/name' % [prefix, index]
			property_list.append({
				'name': property_name_name,
				'type': TYPE_STRING
			})
			var property_name_value: String = get(property_name_name)
			var value_type_customize: Dictionary = {}
			if type_by_name.has(property_name_value):
				value_type_customize = type_by_name.get(property_name_value, {}).duplicate()
			else:
				value_type_customize = type_by_id.get(data[index].type, {}).duplicate()
			value_type_customize.merge({
				'name': '%s_%d/value' % [prefix, index],
				'type': data[index].type
			})
			property_list.append(value_type_customize)
			#{ "name": "power_percent", "class_name": &"", "type": 2, "hint": 1, "hint_string": "0,100,10,or_greater", "usage": 4102 }
			#{ "name": "test", "class_name": &"QuestographNodeSettings", "type": 24, "hint": 17, "hint_string": "QuestographNodeSettings", "usage": 4102 }
			#{ "name": "available_types", "class_name": &"", "type": 28, "hint": 23, "hint_string": "4:", "usage": 4102 }

func _set(property: StringName, value: Variant) -> bool:
	match property:
		'variable_count':
			_variables_data.resize(value)
			for index in _variables_data.size():
				if not _variables_data[index]:
					_variables_data[index] = {
						type = TYPE_NIL,
						name = 'new_variable_%d' % (index + 1),
						value = ''
					}
			notify_property_list_changed()
			return true
		property when property.begins_with('variable_'):
			var splited_property: PackedStringArray = property.trim_prefix('variable_').split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			if key == 'type':
				notify_property_list_changed()
			_variables_data[index][key] = value
			_update_variables()
			return true
	return false


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


func _property_can_revert(property: StringName) -> bool:
	return REVERT_VALUES.has(property) and REVERT_VALUES.get(property) != get(property)


func _property_get_revert(property: StringName) -> Variant:
	return REVERT_VALUES.get(property)


func _update_variables() -> void:
	variables.clear()
	for variable in _variables_data:
		if not variable.type:
			continue
		variables[variable.name] = {
			value = variable.value,
			type = variable.type
		}


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
