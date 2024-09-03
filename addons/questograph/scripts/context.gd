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

# TODO: В переменных могут быть обьекты, которые не сохранены на диске. То есть встроенные. Их надо сериализировать и сохранять.
# TODO: Либо сохранять только имена и выдавать сообщение, если файл не на диске.
# TODO:

## Emitted when a variable is changed.
signal variable_changed(name: StringName)


## Constants for variable data list properties.
const _VARIABLE_DATA_LIST_NAME: String = 'Variables'
const _VARIABLE_DATA_LIST_PREFIX: String = 'variable_'
const _VARIABLE_DATA_LIST_ADD_TEXT: String = 'Add Variable'
const _VARIABLE_DATA_LIST_PAGE_SIZE: int = 10

## Constants for nested context list properties.
const _NESTED_DATA_LIST_NAME: String = 'Nested Context'
const _NESTED_DATA_LIST_PREFIX: String = 'nested_'
const _NESTED_DATA_LIST_ADD_TEXT: String = 'Add Context'
const _NESTED_DATA_LIST_PAGE_SIZE: int = 10

## Meta key to show or hide settings in the editor.
const _META_SHOW_SETTINGS: String = 'show_settings'


## Dictionary mapping type IDs to their respective settings.
@export_storage var _variable_settings_by_type: Dictionary = {
	0: {
		'class_name' = &'',
		'hint' = PROPERTY_HINT_NONE,
		'hint_string' = ''
	}
}

## Dictionary mapping variable names to their respective settings.
@export_storage var _variable_settings_by_name: Dictionary = {
	'': {
		'class_name' = &'',
		'hint' = PROPERTY_HINT_NONE,
		'hint_string' = ''
	}
}

## Dictionary of available types for variables.
@export_storage var _available_types: Dictionary = {
	'String': TYPE_STRING,
	'Integer': TYPE_INT,
	'Float': TYPE_FLOAT,
	'Bool': TYPE_BOOL,
	'Vector2': TYPE_VECTOR2,
	'Vector3': TYPE_VECTOR3,
	'NodePath': TYPE_NODE_PATH,
	'Resource': TYPE_OBJECT,
	'Signal': TYPE_SIGNAL
}:
	set(value):
		if not value.is_empty():
			_available_types = value

## Default values for different variable types.
@export_storage var _default_type_values: Dictionary = {
	TYPE_STRING: '',
	TYPE_BOOL: false,
	TYPE_INT: 0,
	TYPE_FLOAT: 0,
	TYPE_VECTOR2: Vector2.ZERO,
	TYPE_VECTOR3: Vector3.ZERO,
	TYPE_NODE_PATH: NodePath(''),
	TYPE_SIGNAL: []
}
## Flag to control the visibility of nested contexts in the editor.
@export_storage var _show_nested_context: bool = true

## Flag to control the visibility of variables in the editor.
@export_storage var _show_variables: bool = true

## Dictionary storing all the variables and nested contexts.
@export_storage var _context_data: Dictionary = {
	variables = [],
	nested = [],
}

## Instance of the ContextVariables helper class.
var variables: ContextVariables = ContextVariables.new(self)

## Cached data for quick access to context variables.
var _cached_data: Dictionary = {}:
	get:
		if _cached_data.is_empty():
			_cached_data = _create_cached_data(_context_data)
		return _cached_data


#func _init() -> void:
	#print(get_property_list())
	#printt('INIT!', resource_name)


## Sets the value of a property within the class, adjusting variables as needed.
func _set(property: StringName, value: Variant) -> bool:
	if not Engine.is_editor_hint():
		return false

	match property:
		'%scount' % _VARIABLE_DATA_LIST_PREFIX:
			_context_data.variables.resize(value)
			for index in _context_data.variables.size():
				if not _context_data.variables[index] or typeof(_context_data.variables[index]) != TYPE_DICTIONARY:
					_context_data.variables[index] = {
						type = _available_types.values()[0],
						name = '',
						value = _default_type_values.get(_available_types.values()[0])
					}
			notify_property_list_changed()
			return true
		'%scount' % _NESTED_DATA_LIST_PREFIX:
			_context_data.nested.resize(value)
			notify_property_list_changed()
			return true
		property when property.begins_with(_VARIABLE_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_VARIABLE_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			match key:
				'type':
					_context_data.variables[index].type = value
					_context_data.variables[index].value = _default_type_values.get(value)
				'value':
					_context_data.variables[index].value = value
				'name':
					_context_data.variables[index].name = value
				'arguments':
					for value_index in value.size():
						if value[value_index].is_empty():
							value[value_index] = {
								'name': 'argument',
								'type': TYPE_NIL
							}
					_context_data.variables[index].value = value
			return true
		property when property.begins_with(_NESTED_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_NESTED_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			_context_data.nested[index] = value
			return true
	return false


## Retrieves the value of a property within the class.
func _get(property: StringName) -> Variant:
	if not Engine.is_editor_hint():
		return null

	match property:
		'%scount' % _VARIABLE_DATA_LIST_PREFIX:
			return _context_data.variables.size()
		'%scount' % _NESTED_DATA_LIST_PREFIX:
			return _context_data.nested.size()
		property when property.begins_with(_VARIABLE_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_VARIABLE_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			if key == 'type' and not _context_data.variables[index].type in _available_types.values():
				_context_data.variables[index].type = _available_types.values()[0]
				_context_data.variables[index].value = _default_type_values.get(_context_data.variables[index].type)
				notify_property_list_changed()
			if key == 'arguments':
				key = 'value'
			return _context_data.variables[index][key]
		property when property.begins_with(_NESTED_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_NESTED_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			if _context_data.nested.size() > index:
				return _context_data.nested[index]
	return null


## Validates and adjusts properties within the class for proper usage.
func _validate_property(property: Dictionary) -> void:
	match property.name:
		'resource_local_to_scene':
			property.usage = PROPERTY_USAGE_NONE
		'resource_path':
			property.usage = PROPERTY_USAGE_NONE
		'Resource':
			property.usage = PROPERTY_USAGE_NONE


## Generates the list of properties for the editor, including variable properties
## and settings if _META_SHOW_SETTINGS is enabled.
func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		return []

	var property_list: Array[Dictionary] = []
	if _show_variables:
		property_list.append_array(_create_variable_property())
	if _show_nested_context:
		property_list.append_array(_create_nested_property())
	if get_meta(_META_SHOW_SETTINGS, false):
		property_list.append_array(_create_settings_property())
	return property_list


## Creates the properties for the variables in the editor, allowing for customization of their types and names.
func _create_variable_property() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': '%scount' % _VARIABLE_DATA_LIST_PREFIX,
		'class_name': '%s,%s,add_button_text=%s,page_size=%d' % [
			_VARIABLE_DATA_LIST_NAME,
			_VARIABLE_DATA_LIST_PREFIX,
			_VARIABLE_DATA_LIST_ADD_TEXT,
			_VARIABLE_DATA_LIST_PAGE_SIZE
		],
		'type': TYPE_INT,
		'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_ARRAY,
		'hint': PROPERTY_HINT_NONE,
		'hint_string': ''
	})
	for index in _context_data.variables.size():
		property_list.append({
			'name': '%s%d/type' % [_VARIABLE_DATA_LIST_PREFIX, index],
			'type': TYPE_INT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': str(_available_types).replace('{', '').replace('}', '').replace('"', ''),
			'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED if _available_types.size() > 1 else PROPERTY_USAGE_NONE
		})

		property_list.append({
			'name': '%s%d/name' % [_VARIABLE_DATA_LIST_PREFIX, index],
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_EDITOR
		})

		var variable_type: Variant.Type = _context_data.variables[index].type

		if variable_type == TYPE_SIGNAL:
			property_list.append({
				'name': '%s%d/arguments' % [_VARIABLE_DATA_LIST_PREFIX, index],
				'type': TYPE_ARRAY,
				'hint': PROPERTY_HINT_TYPE_STRING,
				'hint_string': '%d:' % [TYPE_DICTIONARY],
				'usage': PROPERTY_USAGE_EDITOR,
			})
			continue

		var variable_name: StringName = _context_data.variables[index].get('name', '')
		var value_type_customize: Dictionary = {}

		if _variable_settings_by_name.has(variable_name):
			value_type_customize = _variable_settings_by_name.get(variable_name, {}).duplicate()
		else:
			value_type_customize = _variable_settings_by_type.get(variable_type, {}).duplicate()
			value_type_customize.merge({
				'name': '%s%d/value' % [_VARIABLE_DATA_LIST_PREFIX, index],
				'type': variable_type,
				'usage': PROPERTY_USAGE_EDITOR
			})
			property_list.append(value_type_customize)

	return property_list

## Creates the properties for the nested contexts in the editor, allowing for context nesting.
func _create_nested_property() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': '%scount' % _NESTED_DATA_LIST_PREFIX,
		'class_name': '%s,%s,add_button_text=%s,page_size=%d' % [
			_NESTED_DATA_LIST_NAME,
			_NESTED_DATA_LIST_PREFIX,
			_NESTED_DATA_LIST_ADD_TEXT,
			_NESTED_DATA_LIST_PAGE_SIZE
		],
		'type': TYPE_INT,
		'usage': PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_ARRAY,
		'hint': PROPERTY_HINT_NONE,
		'hint_string': ''
	})
	for index in _context_data.nested.size():
		property_list.append({
			'name': '%s%d/context' % [_NESTED_DATA_LIST_PREFIX, index],
			'class_name': &'QuestographContext',
			'type': TYPE_OBJECT,
			'hint': PROPERTY_HINT_RESOURCE_TYPE,
			'hint_string': 'QuestographContext',
			'usage': PROPERTY_USAGE_EDITOR
		})
	return property_list


## Creates the settings properties for additional customization in the editor.
func _create_settings_property() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []

	property_list.append({
		'name': 'Settings',
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_CATEGORY
	})
	property_list.append({
		'name': '_available_types',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_default_type_values',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_variable_settings_by_type',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_variable_settings_by_name',
		'type': TYPE_DICTIONARY,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_show_nested_context',
		'type': TYPE_BOOL,
		'usage': PROPERTY_USAGE_EDITOR
	})
	property_list.append({
		'name': '_show_variables',
		'type': TYPE_BOOL,
		'usage': PROPERTY_USAGE_EDITOR
	})

	return property_list


## Creates a dictionary for quick access to variable data.
## This is used for caching and efficient data retrieval.
func _create_cached_data(context_data: Dictionary) -> Dictionary:
	var cached_data: Dictionary = {
		names = {},
		data = {},
		types = {},
	}

	for variable in context_data.get('variables', []):
		var variable_name: StringName = variable.name
		var variable_type: Variant.Type = variable.type
		if variable_name.is_empty():
			continue
		cached_data.names[variable_name] = self
		cached_data.data[variable_name] = variable
		cached_data.types.get_or_add(variable_type, {})[variable_name] = variable

		if variable_type == TYPE_SIGNAL:
			variable.value = _create_signal(variable_name, variable.value)

	for context in context_data.get('nested', []):
		if typeof(context) == TYPE_STRING:
			context = load(context)
		cached_data.names.merge(context.get_variable_list())

	return cached_data


## Creates a dictionary for quick access to variable data.
## This is used for caching and efficient data retrieval.
func _create_signal(name: StringName, arguments: Array = []) -> Signal:
	if variables.has_user_signal(name):
		variables.remove_user_signal(name)
	variables.add_user_signal(name, arguments)
	return Signal(variables, name)


#region Variables

## Returns the array of variables.
## This function stores the current context data into a Dictionary and returns it.
## The data includes all variables and nested contexts. Nested contexts are stored as paths.
## If a nested context is a sub-resource (not saved to disk), a warning is issued.
func store_context_data() -> Dictionary:
	var context_data: Dictionary = {
		variables = _cached_data.data.values(),
		nested = []
	}
	for context in _context_data.get('nested', []) as Array[QuestographContext]:
		var context_path: String = context.resource_path
		if context_path.get_basename() == resource_path.get_basename():
			print(context)
			context_data.nested.append(var_to_bytes_with_objects(context))
			#print(bytes_to_var_with_objects(var_to_bytes_with_objects(context)).get_variable('LOL'))
			#push_warning('%s is a sub-resource! To store context data a sub-resource must be saved to disk manually!' % [context_path])
		else:
			context_data.nested.append(context_path)
	return context_data


## Sets the array of variables and updates the name-to-index mapping.
## This function restores the context data from a provided Dictionary and updates the cached data.
func restore_context_data(variable_data: Dictionary) -> void:
	_context_data = variable_data
	_cached_data = _create_cached_data(_context_data)


## Returns a list of variable names, optionally filtered by type.
## If a type filter is provided, only variables of the specified types are returned.
## Otherwise, all variable names are returned.
func get_variable_list(type_filter: Array[Variant.Type] = []) -> Dictionary:
	if type_filter.is_empty():
		return _cached_data.names

	var variable_list: Dictionary = {}
	for type in type_filter:
		variable_list.merge(_cached_data.types.get(type, {}))

	return variable_list


## Returns the signal with the specified name.
## If the signal does not exist, it returns an empty Signal.
func get_signal(name: StringName) -> Signal:
	return get_variable(name, Signal())


## Retrieves the value of a specific variable by its name.
## If the variable does not exist, returns the provided default value.
func get_variable(name: StringName, default: Variant = null) -> Variant:
	if has_variable(name, true):
		return _cached_data.data[name].value
	elif has_variable(name, false):
		return _cached_data.names[name].get_variable(name, default)
	else:
		return default


## Sets the value of a specific variable and emits a signal to notify that the variable has changed.
## This function first checks the type of the variable before setting it.
## If the variable is of an invalid type (NIL or Signal), it does nothing.
## Otherwise, it updates the variable's value and emits a change signal.
func set_variable(name: StringName, value: Variant) -> void:
	if get_variable_type(name) == TYPE_NIL or get_variable_type(name) == TYPE_SIGNAL:
		return

	if has_variable(name, true):
		_cached_data.data[name].value = type_convert(value, _cached_data.data[name].type)
	elif has_variable(name, false):
		_cached_data.names[name].set_variable(name, value)
	else:
		return

	emit_changed()
	variable_changed.emit(name)


## Retrieves the type of a specific variable by its name.
## If the variable does not exist, returns TYPE_NIL.
func get_variable_type(name: StringName) -> Variant.Type:
	if has_variable(name, true):
		return _cached_data.data[name].type
	elif has_variable(name, false):
		return _cached_data.names[name].get_variable_type(name)
	else:
		return TYPE_NIL


## Checks if a variable with the given name exists.
## If the 'local' flag is true, it only checks the local context.
## Otherwise, it checks both the local context and any nested contexts.
func has_variable(name: StringName, local: bool = false) -> bool:
	if local:
		return _cached_data.data.has(name)
	else:
		return _cached_data.names.has(name)

#endregion


## Class for managing context-specific variables.
class ContextVariables:
	var _context: QuestographContext

	## Constructor for the ContextVariables class.
	## Takes a QuestographContext as an argument to initialize the context.
	func _init(context: QuestographContext) -> void:
		_context = context

	## Retrieves the value of a variable by its name.
	## If the variable does not exist, a warning is issued, and false is returned.
	func _get(property: StringName) -> Variant:
		if not _context.has_variable(property):
			push_warning('The variable named "%s" is missing in the context %s!' % [property, _context.resource_path])
			return false
		return _context.get_variable(property)

	## Sets the value of a variable by its name.
	## If the variable does not exist, a warning is issued, and true is returned.
	func _set(property: StringName, value: Variant) -> bool:
		if not _context.has_variable(property):
			push_warning('The variable named "%s" is missing in the context %s!' % [property, _context.resource_path])
			return true
		_context.set_variable(property, value)
		return true
