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


# TODO: Может стоит для сигналов сделать добавление аргументов
# TODO: Для сигналов должен быть аргумент по умолчанию, кто вызвал
# TODO: Нужна проверка на то, является ли сигналом переменная. Нужна функция для получения типа и потом проверять у наследника.
# TODO: Нужны переменные для отключения вложенных контекстов


## Emitted when a variable is changed.
signal variable_changed(name: StringName)


const _VARIABLE_DATA_LIST_NAME: String = 'Variables'
const _VARIABLE_DATA_LIST_PREFIX: String = 'variable_'
const _VARIABLE_DATA_LIST_ADD_TEXT: String = 'Add Variable'
const _VARIABLE_DATA_LIST_PAGE_SIZE: int = 10

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

## Array of available types for variables.
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
	TYPE_NODE_PATH: NodePath('')
}

## Array storing all the variables as dictionaries.
@export_storage var _variable_list: Array[Dictionary]

@export var nested: Array[QuestographContext]

var variables: ContextVariables = ContextVariables.new(self)

var _cached_data: Dictionary = {}:
	get:
		if _cached_data.is_empty():
			_cached_data = {
				names = {},
				data = {},
				types = {}
			}

			for variable in _variable_list:
				var variable_name: StringName = variable.name
				var variable_type: Variant.Type = variable.type
				if variable_name.is_empty():
					continue
				_cached_data.names[variable_name] = self
				_cached_data.data[variable_name] = variable
				_cached_data.types.get_or_add(variable_type, {})[variable_name] = variable

				if variable_type == TYPE_SIGNAL:
					variable.value = _create_signal(variable_name)

			for context in nested:
				_cached_data.names.merge(context.get_variable_list())

		return _cached_data


func _create_signal(name: StringName) -> Signal:
	if variables.has_user_signal(name):
		variables.remove_user_signal(name)
	variables.add_user_signal(name)

	return Signal(variables, name)


func _init() -> void:
	#add_user_signal('test_signal')
	#print(get_signal_list())
	print(typeof(Signal()))
	printt('INIT!', resource_name)


func _validate_property(property: Dictionary) -> void:
	match property.name:
		'resource_local_to_scene':
			property.usage = PROPERTY_USAGE_NONE
		'resource_path':
			property.usage = PROPERTY_USAGE_NONE
		'Resource':
			property.usage = PROPERTY_USAGE_NONE


## Sets the value of a property within the class, adjusting variables as needed.
func _set(property: StringName, value: Variant) -> bool:
	if not Engine.is_editor_hint():
		return false

	match property:
		'item_count':
			_variable_list.resize(value)
			for index in _variable_list.size():
				if _variable_list[index].is_empty():
					_variable_list[index] = {
						type = _available_types.values()[0],
						name = '',
						value = _default_type_values.get(_available_types.values()[0])
					}
			notify_property_list_changed()
			return true
		property when property.begins_with(_VARIABLE_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_VARIABLE_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			match key:
				'type':
					_variable_list[index].type = value
					_variable_list[index].value = _default_type_values.get(value)
				'value':
					_variable_list[index].value = value
				'name':
					_variable_list[index].name = value
			return true
	return false


## Retrieves the value of a property within the class.
func _get(property: StringName) -> Variant:
	if not Engine.is_editor_hint():
		return null

	match property:
		'item_count':
			return _variable_list.size()
		property when property.begins_with(_VARIABLE_DATA_LIST_PREFIX):
			var splited_property: PackedStringArray = property.trim_prefix(_VARIABLE_DATA_LIST_PREFIX).split('/')
			var index: int = int(splited_property[0])
			var key: String = splited_property[1]
			if key == 'type' and _variable_list[index].type not in _available_types.values():
				_variable_list[index].type = _available_types.values()[0]
				_variable_list[index].value = _default_type_values.get(_variable_list[index].type)
				notify_property_list_changed()
			return _variable_list[index][key]
	return null


## Generates the list of properties for the editor, including variable properties
## and settings if _META_SHOW_SETTINGS is enabled.
func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		return []

	var property_list: Array[Dictionary] = []
	property_list.append_array(_create_variable_property())
	if get_meta(_META_SHOW_SETTINGS, false):
		_create_settings_property(property_list)
	return property_list


## Creates the properties for the variables in the editor, allowing for customization of their types and names.
func _create_variable_property() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'item_count',
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
	for index in _variable_list.size():
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

		var variable_type: Variant.Type = _variable_list[index].type

		if variable_type == TYPE_SIGNAL:
			continue

		var variable_name: StringName = _variable_list[index].get('name', '')
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


## Creates properties for the settings in the editor.
func _create_settings_property(property_list: Array[Dictionary]) -> void:
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


#region Variables

## Returns the array of variables.
func store_variable_data() -> Dictionary:
	return _cached_data.data.duplicate(true)


# Sets the array of variables and updates the name-to-index mapping.
func restore_variable_data(variable_data: Dictionary) -> void:
	_variable_list.clear()
	_cached_data.clear()

	for variable in variable_data:
		_variable_list.append({
			name = variable_data[variable].name,
			type = variable_data[variable].type,
			value = type_convert(variable_data[variable].value,  variable_data[variable].type)
		})

	_cached_data.is_empty()


## Retrieves the value of a specific variable by its name.
func get_variable(name: StringName, default: Variant = null) -> Variant:
	if not has_variable(name):
		return default

	if _is_local_variable(name):
		return _cached_data.data[name].value
	else:
		return _cached_data.names[name].get_variable(name, default)


func _is_local_variable(name: StringName) -> bool:
	return _cached_data.data.has(name)


func get_signal(name: StringName) -> Signal:
	return get_variable(name, Signal())


## Returns a list of variable names, optionally filtered by type.
func get_variable_list(type_filter: Array[Variant.Type] = []) -> Dictionary:
	if type_filter.is_empty():
		return _cached_data.names

	var result: Dictionary = {}
	for type in type_filter:
		result.merge(_cached_data.types.get(type, {}))

	return result


## Checks if a variable with the given name exists.
func has_variable(name: StringName) -> bool:
	return _cached_data.names.has(name)


## Sets the value of a specific variable and emits a signal to notify that the variable has changed.
func set_variable(name: StringName, value: Variant) -> void:
	if not has_variable(name):
		return

	## TODO: Нужна проверка на то, является ли сигналом переменная. Нужна функция для получения типа и потом проверять у наследника.
	#elif _is_local_variable(name) and _cached_data.data[name].type == TYPE_SIGNAL:
		#return
	#elif not _is_local_variable(name) and

	if _is_local_variable(name):
		_cached_data.data[name].value = type_convert(value, _cached_data.data[name].type)
	else:
		_cached_data.names[name].set_variable(name, value)

	emit_changed()
	variable_changed.emit(name)

#endregion


class ContextVariables:
	var _context: QuestographContext

	func _init(context: QuestographContext) -> void:
		_context = context

	func _get(property: StringName) -> Variant:
		if not _context.has_variable(property):
			push_warning('The variable named "%s" is missing in the context %s!' % [property, _context.resource_path])
			return false
		return _context.get_variable(property)

	func _set(property: StringName, value: Variant) -> bool:
		if not _context.has_variable(property):
			push_warning('The variable named "%s" is missing in the context %s!' % [property, _context.resource_path])
			return true
		_context.set_variable(property, value)
		return true
