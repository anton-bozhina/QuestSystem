class_name QuestActionWaitSignal
extends QuestActionWait


var singleton: StringName = '':
	set(value):
		singleton = value
		signal_name = ''
var signal_name: StringName = ''


func _init() -> void:
	name = 'WaitSignal'


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'singleton',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(_get_singleton_list()),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	})
	var singleton_signal_list: Array = _get_singleton_signal_list(singleton)
	if not singleton_signal_list.is_empty():
		property_list.append({
			'name': 'signal_name',
			'type': TYPE_STRING,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(singleton_signal_list),
			'usage': PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
		})

	return property_list


func _get_singleton_list() -> PackedStringArray:
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


func _get_singleton_signal_list(singleton_name: StringName) -> PackedStringArray:
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
