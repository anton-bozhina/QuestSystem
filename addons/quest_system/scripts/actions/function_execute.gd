@tool
class_name QuestActionFunctionExecute
extends QuestActionFunction


static var node_name = 'Execute'


var singleton: StringName = '':
	set(value):
		singleton = value
		method = ''
		attributes = ''
var method: StringName = '':
	set(value):
		method = value
		attributes = ''
var attributes: String = ''


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'singleton',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(_get_singleton_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	var singleton_method_list: Array = _get_singleton_method_list(singleton)
	if not singleton_method_list.is_empty():
		property_list.append({
			'name': 'method',
			'type': TYPE_STRING,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(singleton_method_list),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})
	if not method.is_empty():
		property_list.append({
			'name': 'attributes',
			'type': TYPE_STRING,
			'hint_string': 'Use ; to split',
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})

	return property_list


func _get_singleton_list() -> PackedStringArray:
	#print(Engine.get_main_loop().get_root().get_children())
	return ['TestSingleton', 'SecondSingleton']
	#var result: PackedStringArray = []
	#for node in get_tree().get_root().get_children():
		#var script: GDScript = node.get_script()
		#if not script:
			#continue
		#elif not ProjectSettings.get_global_class_list().filter(_filter_path.bind(script.get_path())).is_empty():
			#continue
#
		#result.append(node.name)
#
	#return result


func _filter_path(value: Dictionary, path: StringName) -> bool:
	return value['path'] == path


func _get_singleton_method_list(singleton_name: StringName) -> PackedStringArray:
	match singleton_name:
		'TestSingleton':
			return ['print', 'color']
		'SecondSingleton':
			return ['second_print', 'second_color']
		'':
			pass
	return []
	#_singletone_method_properties = {}
	#var singleton: Object = _singletones[_singletones.keys()[id]]
	#var method_list: Array[Dictionary] = singleton.get_method_list()
	#var script_method_list: Array[Dictionary] = singleton.get_script().get_method_list()
	#var result: Array = []
	#for method in method_list:
		#if method in script_method_list:
			#continue
#
		#result.append(method['name'])
		#_singletone_method_properties[method['name']] = _change_usage(method['args'])
	#return result
