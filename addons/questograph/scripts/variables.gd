@tool
class_name QuestographVariables
extends Resource

var variables: Array[Variable]


class Variable:
	const AVAILABLE_TYPES: PackedStringArray = [
		'Variable Type',
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

	var type: Variant.Type = TYPE_NIL
	var name: String = 'new_variable'
	var value: Variant = null:
		get:
			return value if value else DEFAULT_VALUES[type]

	func _to_string() -> String:
		return str({
			type = type,
			name = name,
			value = value
		})


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	_create_array_property(property_list, 'variable', variables)
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
		if variables[index].type == TYPE_NIL:
			property_list.append({
				'name': '%s_%d/type' % [prefix, index],
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(Variable.AVAILABLE_TYPES),
				'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE
			})
		else:
			property_list.append({
				'name': '%s_%d/type' % [prefix, index],
				'type': TYPE_INT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(Variable.AVAILABLE_TYPES),
				'usage': PROPERTY_USAGE_STORAGE
			})
		if variables[index].type != TYPE_NIL:
			property_list.append({
				'name': '%s_%d/name' % [prefix, index],
				'type': TYPE_STRING
			})
			property_list.append({
				'name': '%s_%d/value' % [prefix, index],
				'type': variables[index].type
			})


func _set(property: StringName, value: Variant) -> bool:
	match property:
		'variable_count':
			variables.resize(value)
			for index in variables.size():
				if not variables[index]:
					variables[index] = Variable.new()
			notify_property_list_changed()
		property when property.begins_with('variable_'):
			var splited_property: PackedStringArray = property.trim_prefix('variable_').split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			if key == 'type':
				notify_property_list_changed()
			variables[index].set(key, value)
	return true


func _get(property: StringName) -> Variant:
	match property:
		'variable_count':
			return variables.size()
		property when property.begins_with('variable_'):
			var splited_property: PackedStringArray = property.trim_prefix('variable_').split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			return variables[index].get(key)
	return null
