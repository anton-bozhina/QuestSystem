@tool
class_name QuestographEditorNodeSettings
extends Resource




#@export var node_data: Array[Dictionary]
##@export var script_data: Dictionary = {}
##@export var name_data: Dictionary = {}
#
#const DEFAULT_DATA: Dictionary = {
	#script = null,
	#id = 'NewNode',
	#editor_node = {
		#group = 'group',
		#title = 'title',
		#caption = 'caption',
		#color = Color.CADET_BLUE,
		#slots = {
			#inputs = [],
			#outputs = []
		#}
	#}
#}
#
#
#func _get_property_list() -> Array[Dictionary]:
	#var property_list: Array[Dictionary] = []
	#property_list.append({
		#'name': 'node_count',
		#'class_name': 'Nodes,node_data_,add_button_text=Add Node,page_size=20',
		#'type': TYPE_INT,
		#'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		#'hint': PROPERTY_HINT_NONE,
		#'hint_string': ''
	#})
	#for index in node_data.size():
		#property_list.append({
			#'name': 'node_data_%d/script' % index,
			#'class_name': &'GDScript',
			#'type': TYPE_OBJECT,
			#'hint': PROPERTY_HINT_RESOURCE_TYPE,
			#'hint_string': 'GDScript'
		#})
		#property_list.append({
			#'name': 'node_data_%d/id' % index,
			#'type': TYPE_STRING
		#})
		#property_list.append({
			#'name': 'node_data_%d/editor_node' % index,
			#'type': TYPE_NIL,
			#'usage': PROPERTY_USAGE_GROUP
		#})
		#property_list.append({
			#'name': 'node_data_%d/editor_node/group' % index,
			#'type': TYPE_INT,
			#'hint': PROPERTY_HINT_ENUM,
			##'hint_string': ','.join(NodeGroupType.keys()),
			#'usage': PROPERTY_USAGE_EDITOR
		#})
		##if _node_group == NodeGroupType.Custom:
			##property_list.append({ 'name': 'node_group_name', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE })
		##else:
			##property_list.append({ 'name': 'node_group_name', 'type': TYPE_STRING, 'usage': PROPERTY_USAGE_STORAGE })
		#property_list.append({ 'name': 'node_data_%d/editor_node/title' % index, 'type': TYPE_STRING })
		#property_list.append({ 'name': 'node_data_%d/editor_node/caption' % index, 'type': TYPE_STRING })
		#property_list.append({ 'name': 'node_data_%d/editor_node/color' % index, 'type': TYPE_COLOR })
		##if _action_class:
			##_action_class.get_property_list().reduce(_reduce_property_names, whitelisted_properties)
			##property_list.append({ 'name': 'whitelisted_properties', 'type': TYPE_DICTIONARY, 'usage': PROPERTY_EXPORT_VARIABLE })
		#property_list.append({'name': 'node_data_%d/editor_node/slots' % index, 'type': TYPE_NIL, 'usage': PROPERTY_USAGE_SUBGROUP})
		#property_list.append({
			#'name': 'node_data_%d/editor_node/slots/inputs' % index,
			#'type': TYPE_ARRAY,
			#'hint': PROPERTY_HINT_TYPE_STRING,
			#'hint_string': '24/17:QuestographNodeSlot'
		#})
		#property_list.append({
			#'name': 'node_data_%d/editor_node/slots/outputs' % index,
			#'type': TYPE_ARRAY,
			#'hint': PROPERTY_HINT_TYPE_STRING,
			#'hint_string': '24/17:QuestographNodeSlot'
		#})
	#return property_list
#
#
#func _get(property: StringName) -> Variant:
	#if property == 'node_count':
		#return node_data.size()
	#elif property.begins_with('node_data_'):
		#var keys := property.trim_prefix('node_data_').split('/') as Array
		#var index: int = int(keys.pop_front())
		#if index > node_data.size():
			#return null
		#return _get_deep_dict_value(node_data[index], keys)
	#return null
#
#
#func _set(property: StringName, value: Variant) -> bool:
	#match property:
		#'node_count':
			#node_data.resize(value)
			#for index in node_data.size():
				#if node_data[index].is_empty():
					#node_data[index] = DEFAULT_DATA
			#notify_property_list_changed()
		#property when property.begins_with('node_data_'):
			#var keys := property.trim_prefix('node_data_').split('/') as Array
			#var index: int = int(keys.pop_front())
			#if index > node_data.size():
				#return false
			#node_data[index] = _set_deep_dict_value(node_data[index], keys, value)
			##print(_set_deep_dict_value(node_data[index], keys, value))
			##node_data[index][key] = value
	#return true
#
#
#func _get_deep_dict_value(dict: Dictionary, keys: Array) -> Variant:
	#if keys.size() > 1:
		#return _get_deep_dict_value(dict.get(keys[0], {}), keys.slice(1, keys.size()))
	#else:
		#return dict.get(keys[0])
#
#
### НАДО СЕТТЕР СДЕЛАТь
#
##def nested_set(dic, keys, value):
	##for key in keys[:-1]:
		##dic = dic.setdefault(key, {})
	##dic[keys[-1]] = value
#
#
#func _set_deep_dict_value(dict: Dictionary, keys: Array, value: Variant) -> Dictionary:
	#var result_dict: Dictionary = dict.duplicate(true)
	#var current: Dictionary = result_dict
#
	#for key in keys.slice(0, keys.size() - 1):
		#if not current.has(key):
			#current[key] = {}
		#current = current[key]
#
	#current[keys[-1]] = value
#
	#return result_dict



enum NodeGroupType {
	Custom,
	Functions,
	Logic,
	Waits,
	Checks
}

const NODE_GROUP_NAME: Dictionary = {
	NodeGroupType.Custom: 'Group',
	NodeGroupType.Functions: 'Functions',
	NodeGroupType.Logic: 'Logic',
	NodeGroupType.Waits: 'Waits',
	NodeGroupType.Checks: 'Checks'
}
const NODE_GROUP_COLOR: Dictionary = {
	NodeGroupType.Custom: Color.CORNFLOWER_BLUE,
	NodeGroupType.Functions: Color.CORAL,
	NodeGroupType.Logic: Color.DARK_GREEN,
	NodeGroupType.Waits: Color.DARK_ORANGE,
	NodeGroupType.Checks: Color.DEEP_PINK
}
const SLOT_PRESETS: Dictionary = {
	default = {
		inputs = [
			preload('../resources/slots/input_flow.tres')
		],
		outputs = [
			preload('../resources/slots/output_flow.tres')
		]
	},
	checks = {
		inputs = [
			preload('../resources/slots/input_flow.tres')
		],
		outputs = [
			preload('../resources/slots/output_true.tres'),
			preload('../resources/slots/output_false.tres')
		]
	}
}
const NODE_DEFAULT_SLOTS: Dictionary = {
	NodeGroupType.Custom: SLOT_PRESETS.default,
	NodeGroupType.Functions: SLOT_PRESETS.default,
	NodeGroupType.Logic: SLOT_PRESETS.default,
	NodeGroupType.Waits: SLOT_PRESETS.default,
	NodeGroupType.Checks: SLOT_PRESETS.checks
}
const PROPERTY_EXPORT_VARIABLE: int = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR


@export var action_script: GDScript:
	set(value):
		action_script = value
		if action_script:
			#_action_class = action_script.new()
			action_name = action_script.get_path().get_file().get_basename().to_pascal_case()
		else:
			#_action_class = null
			action_name = ''
		#whitelisted_properties = {}
		notify_property_list_changed()

@export var action_name: String:
	set(value):
		action_name = value
		resource_name = 'NewAction' if value.is_empty() else value

var node_group_name: String = ''
var node_title: String = ''
var node_caption: String = ''
var node_color: Color = Color.CADET_BLUE
var node_inputs: Array[QuestographEditorNodeSlot] = []
var node_outputs: Array[QuestographEditorNodeSlot] = []
var show_right_slot: bool = true
#var whitelisted_properties: Dictionary = {}

#var _action_class: QuestAction
var _node_group: NodeGroupType:
	set(value):
		_node_group = value
		node_group_name = NODE_GROUP_NAME[value]
		node_color = NODE_GROUP_COLOR[value]
		node_inputs = []
		node_outputs = []
		for slot in NODE_DEFAULT_SLOTS[value]['inputs'] as Array[QuestographEditorNodeSlot]:
			node_inputs.append(slot.duplicate())
		for slot in NODE_DEFAULT_SLOTS[value]['outputs'] as Array[QuestographEditorNodeSlot]:
			node_outputs.append(slot.duplicate())
		notify_property_list_changed()


func _init() -> void:
	resource_name = 'NewAction'
	_node_group = NodeGroupType.Functions


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({'name': 'Editor Settings', 'type': TYPE_NIL, 'usage': PROPERTY_USAGE_GROUP})
	property_list.append({
		'name': '_node_group',
		'type': TYPE_INT,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(NodeGroupType.keys()),
		'usage': PROPERTY_USAGE_EDITOR
	})
	if _node_group == NodeGroupType.Custom:
		property_list.append({ 'name': 'node_group_name', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE })
	else:
		property_list.append({ 'name': 'node_group_name', 'type': TYPE_STRING, 'usage': PROPERTY_USAGE_STORAGE })
	property_list.append({ 'name': 'node_title', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE })
	property_list.append({ 'name': 'node_caption', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE })
	property_list.append({ 'name': 'node_color', 'type': TYPE_COLOR, 'usage': PROPERTY_EXPORT_VARIABLE })
	#if _action_class:
		#_action_class.get_property_list().reduce(_reduce_property_names, whitelisted_properties)
		#property_list.append({ 'name': 'whitelisted_properties', 'type': TYPE_DICTIONARY, 'usage': PROPERTY_EXPORT_VARIABLE })
	property_list.append({'name': 'Slots', 'type': TYPE_NIL, 'usage': PROPERTY_USAGE_SUBGROUP})
	property_list.append({
		'name': 'node_inputs',
		'type': TYPE_ARRAY,
		'hint': PROPERTY_HINT_TYPE_STRING,
		'hint_string': '24/17:QuestographNodeSlot',
		'usage': PROPERTY_EXPORT_VARIABLE
	})
	property_list.append({
		'name': 'node_outputs',
		'type': TYPE_ARRAY,
		'hint': PROPERTY_HINT_TYPE_STRING,
		'hint_string': '24/17:QuestographNodeSlot',
		'usage': PROPERTY_EXPORT_VARIABLE
	})


	return property_list


func _reduce_property_names(list, property) -> Dictionary:
	if property['usage'] == PROPERTY_EXPORT_VARIABLE and not list.has(property['name']):
		list[property['name']] = true
	return list



#func _set(property: StringName, value: Variant) -> bool:
	#print(property)
	#match property:
		#'node_group':
			#print(value)
			#node_group = value
#
	#return true


#func _get(property: StringName) -> Variant:
	#match property:
		#'editor_settings/node_group':
			#return node_group
#
	#return null


#{ "name": "action_class", "class_name": &"QuestAction", "type": 24, "hint": 17, "hint_string": "QuestAction", "usage": 4102 },
#{ "name": "action_name", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 },
#{ "name": "Editor Settings", "class_name": &"", "type": 0, "hint": 0, "hint_string": "", "usage": 64 },
#{ "name": "node_group", "class_name": &"", "type": 4, "hint": 0, "hint_string": "", "usage": 4096 },
#{ "name": "node_caption", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 },
#{ "name": "node_color", "class_name": &"", "type": 20, "hint": 0, "hint_string": "Color", "usage": 4102 },
#{ "name": "whitelisted_properties", "class_name": &"", "type": 28, "hint": 23, "hint_string": "21:StringName", "usage": 4102 },
#{ "name": "Slots", "class_name": &"", "type": 0, "hint": 0, "hint_string": "", "usage": 256 },
#{ "name": "show_left_slot", "class_name": &"", "type": 1, "hint": 0, "hint_string": "bool", "usage": 4102 },
#{ "name": "show_right_slot", "class_name": &"", "type": 1, "hint": 0, "hint_string": "bool", "usage": 4102 },
 #{ "name": "editor_settings/node_group", "class_name": &"", "type": 4, "hint": 2, "hint_string": "Functions,Logic,Waits,Checks,Custom", "usage": 4102 }
