@tool
class_name QuestographContext
extends Resource

signal variables_changed


class Variables:
	signal changed

	var _variables: Dictionary
	var _owner: Resource

	func _init(owner: Resource) -> void:
		_owner = owner

	func _set(property: StringName, value: Variant) -> bool:
		_variables[property] = value
		changed.emit()
		return true

	func _get(property: StringName) -> Variant:
		if not _variables.has(property):
			push_warning('Variable %s does not exist in the context %s, return false!' % [property, _owner.resource_path])
			return false
		return _variables.get(property)

	func keys() -> PackedStringArray:
		return _variables.keys() as PackedStringArray

	func get_variables() -> Dictionary:
		return _variables

	func set_variables(variables: Dictionary) -> void:
		_variables = variables
		changed.emit()

	func erase(name: StringName) -> void:
		_variables.erase(name)
		changed.emit()

	func has(name: StringName) -> bool:
		return _variables.has(name)

	func clear() -> void:
		_variables.clear()
		changed.emit()




const AVAILABLE_TYPES: PackedStringArray = [
	'Null',
	'Bool:%d' % TYPE_BOOL,
	'Integer:%d' % TYPE_INT,
	'Float:%d' % TYPE_FLOAT,
	'String:%d' % TYPE_STRING,
	'Vector2:%d' % TYPE_VECTOR2,
	'Vector3:%d' % TYPE_VECTOR3,
	'NodePath:%d' % TYPE_NODE_PATH
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

var variables: Variables = Variables.new(self)
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
			property_list.append({
				'name': '%s_%d/value' % [prefix, index],
				'type': data[index].type
			})


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


func _on_variables_changed() -> void:
	variables_changed.emit()
	emit_changed()


func get_variables() -> Dictionary:
	return variables.get_variables()


func set_variables(variable_dict: Dictionary) -> void:
	variables.set_variables(variable_dict)


func get_variable(name: StringName) -> Variant:
	return variables[name]


func set_variable(name: StringName, value: Variant) -> void:
	variables[name] = value


func get_variable_list(type_filter: Array[int] = []) -> PackedStringArray:
	if type_filter.is_empty():
		return variables.keys()

	var result: PackedStringArray = []
	for variable in variables.get_variables():
		if typeof(variables[variable]) in type_filter:
			result.append(variable)
	return result


func erase_variable(name: StringName) -> void:
	variables.erase(name)


func has_variable(name: StringName) -> bool:
	return variables.has(name)


func clear_variables() -> void:
	variables.clear()


func __tests() -> void:
	var test_dict: Dictionary = {
		test_bool = true,
		test_int = 99,
		test_float = 9.99,
		test_string = 'string'
	}

	set_variables(test_dict)
	assert(get_variables() == test_dict)
	print_debug('Test set_variables() and get_variables() passed!')

	set_variable('test_int', 999)
	assert(get_variable('test_int') == 999)
	print_debug('Test set_variable() and get_variable() passed!')

	assert(get_variable_list() as Array == test_dict.keys())
	print_debug('Test get_variable_list() passed!')

	assert(get_variable_list([TYPE_FLOAT, TYPE_INT]) == PackedStringArray(['test_int', 'test_float']))
	print_debug('Test filtered get_variable_list() passed!')

	erase_variable('test_string')
	erase_variable('some_test_string')
	assert(has_variable('test_string') == false)
	print_debug('Test remove_variable() and has_variable() passed!')

	clear_variables()
	assert(get_variables().is_empty())
	print_debug('Test clear_variables() passed!')

	variables.test_vector2 = Vector2.DOWN
	assert(variables.test_vector2 == Vector2.DOWN)
	print_debug('Test adding and reading new variable directly passed!')

	assert(variables.test_not_created_variable == false)
	print_debug('Test reading not created variable directly passed!')

	var signal_result: Array[bool] = []
	var on_signal_func: Callable = func(result):
		result.append(true)
	variables_changed.connect(on_signal_func.bind(signal_result), CONNECT_ONE_SHOT)
	variables.test_bool = false
	assert(not signal_result.is_empty())
	print_debug('Test variables_changed signal passed!')
