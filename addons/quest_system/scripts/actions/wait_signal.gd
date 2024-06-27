@tool
class_name QuestActionWaitSignal
extends QuestActionWait


static var node_name = 'WaitSignal'


var singleton: StringName = '':
	set(value):
		singleton = value
		signal_name = ''
var signal_name: StringName = ''


func _perform_wait() -> void:
	var singleton: Node = _get_root().get_node_or_null(str(singleton))
	if not singleton:
		waited.emit()
		return
	singleton.connect(signal_name, _on_signaled, CONNECT_ONE_SHOT)


# Sorry for this, but GDScript...
func _on_signaled(arg1: Variant = null, arg2: Variant = null, arg3: Variant = null, arg4: Variant = null, arg5: Variant = null, arg6: Variant = null) -> void:
	waited.emit()


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


func _get_singleton_signal_list(singleton_name: StringName) -> PackedStringArray:
	var result: PackedStringArray = []
	if singleton_name.is_empty():
		return result
	var singleton: Node = _get_root().get_node_or_null(str(singleton_name))
	if not singleton:
		return result
	var signal_list: Array[Dictionary] = singleton.get_script().get_script_signal_list()
	for signal_dict in signal_list:
		result.append(signal_dict['name'])
	return result


func _get_root() -> Window:
	return Engine.get_main_loop().get_root()
