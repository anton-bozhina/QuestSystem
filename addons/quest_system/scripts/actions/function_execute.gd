@tool
class_name QuestActionFunctionExecute
extends QuestActionFunction

const IGNORE_PRIVATE_METHODS: bool = true
const IGNORE_RETURN_METHODS: bool = true

static var node_name = 'Execute'


var singleton: StringName = '':
	set(value):
		singleton = value
		method = ''
		arguments = ''
var method: StringName = '':
	set(value):
		method = value
		arguments = ''
var arguments: String = ''


func _perform_function() -> void:
	var singleton: Node = _get_root().get_node_or_null(str(singleton))
	if not singleton:
		return
	var arguments_array: Array = arguments.split(';')
	singleton.callv(method, arguments_array)


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'singleton',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(_get_singleton_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	var singleton_methods: Dictionary = _get_singleton_methods(singleton)
	if not singleton_methods.is_empty():
		property_list.append({
			'name': 'method',
			'type': TYPE_STRING,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(singleton_methods.keys()),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	if not method.is_empty() and not singleton_methods[method].is_empty():
		property_list.append({
			'name': 'arguments',
			'type': TYPE_STRING,
			'hint_string': 'Use ; to split',
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})

	return property_list


func _get_singleton_list() -> PackedStringArray:
	var result: PackedStringArray = []
	for node in _get_root().get_children() as Array[Node]:
		var script: GDScript = node.get_script()
		if not script:
			continue
		elif not ProjectSettings.get_global_class_list().filter(_filter_path.bind(script.get_path())).is_empty():
			continue
		result.append(node.name)
	return result


func _filter_path(value: Dictionary, path: StringName) -> bool:
	return value['path'] == path


func _get_singleton_methods(singleton_name: StringName) -> Dictionary:
	if singleton_name.is_empty():
		return {}
	var singleton: Node = _get_root().get_node_or_null(str(singleton_name))
	if not singleton:
		return {}
	var method_list: Array[Dictionary] = singleton.get_script().get_script_method_list()
	var result: Dictionary = {}

	for method in method_list:
		if method['name'].begins_with('_') and IGNORE_PRIVATE_METHODS:
			continue
		elif not method['return']['type'] == TYPE_NIL and IGNORE_RETURN_METHODS:
			continue
		result[method['name']] = method['args']
	return result


func _get_root() -> Window:
	return Engine.get_main_loop().get_root()
