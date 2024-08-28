@tool
@icon('../icons/context.svg')
class_name QuestographContext
extends Resource
## A class of context variable resource.
##
## This class is designed to create and manage a set of variables for use within a Godot project.
## It allows for the dynamic creation, modification, and retrieval of variables of different types
## (e.g., String, Integer, Float, etc.) at runtime or in the editor. The class also provides
## custom properties for these variables, making them editable within the Godot editor.
## It includes functionality for managing the type and value of each variable, and it emits
## signals when variables are changed. The meta boolean variable [b]show_settings[/b] can be
## used to toggle the visibility of additional settings for this resource in the editor.


## Emitted when a variable is changed.
signal variable_changed(name: StringName)


## Configuration settings for variable properties.
const VARIABLE_SETTINGS: Dictionary = {
	name = 'variable',
	category = 'Variables',
	prefix = 'variable_',
	add_button_text = 'Add Variable',
	page_size = 10,
	null_type = 'Null'
}

## Default values used for reverting properties.
const REVERT_VALUES: Dictionary = {
	'available_types' = [
		'String:%d' % TYPE_STRING,
		'Integer:%d' % TYPE_INT,
		'Float:%d' % TYPE_FLOAT,
		'Bool:%d' % TYPE_BOOL,
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

## Default key values for the variables.
const DEFAULT_KEYS: Dictionary = {
	type = TYPE_NIL,
	name = &'',
	value = DEFAULT_VALUES[TYPE_NIL]
}

## Default values for different variable types.
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

## Meta key to show or hide settings in the editor.
const META_SHOW_SETTINGS: String = 'show_settings'

## Array storing all the variables as dictionaries.
@export_storage var _variables: Array[Dictionary]

## Dictionary mapping variable names to their indices in the _variables array.
@export_storage var _names: Dictionary

## Dictionary mapping type IDs to their respective settings.
@export_storage var _type_by_id: Dictionary = REVERT_VALUES['type_by_id']

## Dictionary mapping variable names to their respective settings.
@export_storage var _type_by_name: Dictionary = REVERT_VALUES['type_by_name']

## Array of available types for variables.
@export_storage var _available_types: Array = REVERT_VALUES['available_types']


#func _init() -> void:
	#printt('INIT!', resource_name)


## Generates the list of properties for the editor, including variable properties
## and settings if META_SHOW_SETTINGS is enabled.
func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		return []
	var property_list: Array[Dictionary] = []
	property_list.append_array(_create_variable_property())
	if get_meta(META_SHOW_SETTINGS, false):
		_create_settings_property(property_list)
	return property_list


## Creates properties for the settings in the editor.
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
		'name': '_type_by_id',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_type_by_name',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_available_types',
		'type': TYPE_ARRAY,
		'hint': PROPERTY_HINT_TYPE_STRING,
		'hint_string': '4:',
		'usage': PROPERTY_USAGE_EDITOR
	})


## Creates the properties for the variables in the editor, allowing for customization of their types and names.
func _create_variable_property() -> Array[Dictionary]:
	_names.clear()
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': '%s_count' % VARIABLE_SETTINGS.name,
		'class_name': '%s,%s,add_button_text=%s,page_size=%d' % [
			VARIABLE_SETTINGS.category,
			VARIABLE_SETTINGS.prefix,
			VARIABLE_SETTINGS.add_button_text,
			VARIABLE_SETTINGS.page_size
		],
		'type': TYPE_INT,
		'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_ARRAY,
		'hint': PROPERTY_HINT_NONE,
		'hint_string': ''
	})
	for index in _variables.size():
		var variable_type: Variant.Type = _variables[index].get('type', DEFAULT_KEYS.type)

		var type_list: Array = _available_types.duplicate() if _available_types.size() >= 1 else REVERT_VALUES.available_types.duplicate()
		if variable_type == TYPE_NIL:
			if type_list.size() == 1:
				variable_type = int(type_list[0].split(':')[1])
				_variables[index].type = variable_type
			else:
				type_list.insert(0, VARIABLE_SETTINGS.null_type)

		property_list.append({
			'name': '%s%d/type' % [VARIABLE_SETTINGS.prefix, index],
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': '%s' % [','.join(type_list)],
			'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED if type_list.size() > 1 else PROPERTY_USAGE_NONE
		})

		property_list.append({
			'name': '%s%d/name' % [VARIABLE_SETTINGS.prefix, index],
			'type': TYPE_STRING_NAME,
			'usage': PROPERTY_USAGE_EDITOR if variable_type != TYPE_NIL else PROPERTY_USAGE_NONE
		})

		var variable_name: StringName = _variables[index].get('name', DEFAULT_KEYS.name)
		var value_type_customize: Dictionary = {}

		if _type_by_name.has(variable_name):
			value_type_customize = _type_by_name.get(variable_name, {}).duplicate()
		else:
			value_type_customize = _type_by_id.get(variable_type, {}).duplicate()

		value_type_customize.merge({
			'name': '%s%d/value' % [VARIABLE_SETTINGS.prefix, index],
			'type': variable_type,
			'usage': PROPERTY_USAGE_EDITOR if variable_type != TYPE_NIL else PROPERTY_USAGE_NONE
		})
		property_list.append(value_type_customize)

		if _variables[index].has('name'):
			_names[_variables[index].name] = index

	return property_list


## Sets the value of a property within the class, adjusting variables as needed.
func _set(property: StringName, value: Variant) -> bool:
	if not Engine.is_editor_hint():
		return false

	match property:
		'%s_count' % VARIABLE_SETTINGS.name:
			_variables.resize(value)
			notify_property_list_changed()
			return true
		property when property.begins_with(VARIABLE_SETTINGS.prefix):
			var splited_property: PackedStringArray = property.trim_prefix(VARIABLE_SETTINGS.prefix).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			_variables[index][key] = value
			return true
	return false


## Retrieves the value of a property within the class.
func _get(property: StringName) -> Variant:
	if not Engine.is_editor_hint():
		return null

	match property:
		'%s_count' % VARIABLE_SETTINGS.name:
			return _variables.size()
		property when property.begins_with(VARIABLE_SETTINGS.prefix):
			var splited_property: PackedStringArray = property.trim_prefix(VARIABLE_SETTINGS.prefix).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			var default_value: Variant = DEFAULT_KEYS.get(key) if key != 'value' else DEFAULT_VALUES.get(_variables[index].type)
			return _variables[index].get_or_add(key, default_value)
	return null


## Checks if a property can be reverted to its default value.
func _property_can_revert(property: StringName) -> bool:
	return REVERT_VALUES.has(property) and REVERT_VALUES.get(property) != get(property)


## Retrieves the default value for a property if it can be reverted.
func _property_get_revert(property: StringName) -> Variant:
	return REVERT_VALUES.get(property)


## Returns the array of variables.
func get_variables() -> Array[Dictionary]:
	return _variables


## Sets the array of variables and updates the name-to-index mapping.
func set_variables(variables: Array[Dictionary]) -> void:
	_variables.clear()
	_names.clear()
	for index in variables.size():
		_variables.append({
			type = variables[index].type,
			name = variables[index].name,
			value = type_convert(variables[index].value, variables[index].type)
		})
		_names[variables[index].name] = index


## Retrieves the value of a specific variable by its name.
func get_variable(name: StringName, default: Variant = null) -> Variant:
	if not _names.has(name):
		return default
	return _variables[_names[name]].value


## Returns a list of variable names, optionally filtered by type.
func get_variable_list(type_filter: Array[int] = []) -> PackedStringArray:
	if type_filter.is_empty():
		return _names.keys()

	var result: PackedStringArray = []
	for variable in _variables:
		if variable.type in type_filter:
			result.append(variable.name)
	return result


## Checks if a variable with the given name exists.
func has_variable(name: StringName) -> bool:
	return _names.has(name)


## Sets the value of a specific variable and emits a signal to notify that the variable has changed.
func set_variable(name: StringName, value: Variant) -> void:
	if not _names.has(name):
		return
	var index: int =  _names[name]
	_variables[index].value = type_convert(value, _variables[index].type)
	emit_changed()
	variable_changed.emit(name)
