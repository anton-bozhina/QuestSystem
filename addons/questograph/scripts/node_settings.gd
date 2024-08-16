@tool
@icon('../icons/node_settings.svg')
class_name QuestographNodeSettings
extends Resource
## Class contains the node settings for the Editor and the System.


## List of groups to which a node can be placed in the editor
enum GroupType {
	## Allows you to specify a group name for a Node
	Custom,
	## Group for functional Nodes
	Functions,
	## Group for logical Nodes
	Logic,
	## Group for waiting Nodes
	Waits,
	## Group for checking Nodes
	Checks
}

const PROPERTY_EXPORT_VARIABLE: int = PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
const GROUP_NAMES: Dictionary = {
	GroupType.Custom: '',
	GroupType.Functions: 'Functions',
	GroupType.Logic: 'Logic',
	GroupType.Waits: 'Waits',
	GroupType.Checks: 'Checks'
}
const GROUP_COLORS: Dictionary = {
	GroupType.Custom: Color.CORNFLOWER_BLUE,
	GroupType.Functions: Color.CORAL,
	GroupType.Logic: Color.DARK_GREEN,
	GroupType.Waits: Color.DARK_ORANGE,
	GroupType.Checks: Color.DEEP_PINK
}
const SLOT_PRESETS: Dictionary = {
	default = {
		inputs = [
			{
				color = Color.ORANGE,
				type = TYPE_NIL,
				icon = null
			}
		],
		outputs = [
			{
				color = Color.ORANGE,
				type = TYPE_NIL,
				icon = null
			}
		]
	},
	checks = {
		inputs = [
			{
				color = Color.ORANGE,
				type = TYPE_NIL,
				icon = null
			}
		],
		outputs = [
			{
				color = Color.LIME_GREEN,
				type = TYPE_NIL,
				icon = null
			},
			{
				color = Color.ORANGE_RED,
				type = TYPE_NIL,
				icon = null
			}
		]
	}
}
const DEFAULT_SLOTS: Dictionary = {
	GroupType.Custom: SLOT_PRESETS.default,
	GroupType.Functions: SLOT_PRESETS.default,
	GroupType.Logic: SLOT_PRESETS.default,
	GroupType.Waits: SLOT_PRESETS.default,
	GroupType.Checks: SLOT_PRESETS.checks
}
const DEFAULT_DATA: Dictionary = {
	file = null,
	id = '',
	group_name = '',
	title = '',
	caption = ''
}

## GDScript resource with Node logic
var file: GDScript = null:
	set(value):
		file = value
		if not file:
			return
		var id_name: String = file.get_path().get_file().get_basename().to_pascal_case()
		id = id_name if id.is_empty() else id
		title = id_name if title.is_empty() else title
## Node ID, used for saving in the Editor and link to the script
var id: String = '':
	set(value):
		id = value
		resource_name = 'NewAction' if id.is_empty() else id

## List of groups to which a node can be placed in the Editor.
var group: GroupType = GroupType.Functions:
	set(value):
		group = value
		group_name = GROUP_NAMES[value]
		color = GROUP_COLORS[value]
		input_slots = []
		for slot in DEFAULT_SLOTS[value].inputs as Array[Dictionary]:
			input_slots.append(slot)
		output_slots = []
		for slot in DEFAULT_SLOTS[value].outputs as Array[Dictionary]:
			output_slots.append(slot)
		notify_property_list_changed()

## Name of the group in which the Node will be placed in the Editor
var group_name: String = ''

## The text to be specified in the Node title
var title: String = ''

## The text to be specified in the Node caption
var caption: String = ''

## Node color in the Editor
var color: Color = GROUP_COLORS[group]
var input_slots: Array[Dictionary] = []
var output_slots: Array[Dictionary] = []


func _init() -> void:
	resource_name = 'NewAction'


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({
		'name': 'file',
		'class_name': &'GDScript',
		'type': TYPE_OBJECT,
		'hint': PROPERTY_HINT_RESOURCE_TYPE,
		'hint_string': 'GDScript',
		'usage': PROPERTY_EXPORT_VARIABLE
	})
	property_list.append({'name': 'id', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE})
	property_list.append({'name': 'Editor Settings', 'type': TYPE_NIL, 'usage': PROPERTY_USAGE_GROUP})
	property_list.append({
		'name': 'group',
		'type': TYPE_INT,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(GroupType.keys()),
		'usage': PROPERTY_USAGE_EDITOR
	})
	if group == GroupType.Custom:
		property_list.append({'name': 'group_name', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE})
	else:
		property_list.append({'name': 'group_name', 'type': TYPE_STRING, 'usage': PROPERTY_USAGE_STORAGE})
	property_list.append({'name': 'title', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE})
	property_list.append({'name': 'caption', 'type': TYPE_STRING, 'usage': PROPERTY_EXPORT_VARIABLE})
	property_list.append({'name': 'color', 'type': TYPE_COLOR, 'usage': PROPERTY_EXPORT_VARIABLE})
	_create_array_property(property_list, 'input_slot', input_slots)
	_create_array_property(property_list, 'output_slot', output_slots)
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
		property_list.append({
			'name': '%s_%d/color' % [prefix, index],
			'type': TYPE_COLOR
		})
		property_list.append({
			'name': '%s_%d/type' % [prefix, index],
			'type': TYPE_INT
		})
		property_list.append({
			'name': '%s_%d/icon' % [prefix, index],
			'type': TYPE_OBJECT
		})


func _set(property: StringName, value: Variant) -> bool:
	match property:
		'input_slot_count':
			input_slots.resize(value)
			for index in input_slots.size():
				if input_slots[index].is_empty():
					input_slots[index] = SLOT_PRESETS.default.inputs[0]
		'output_slot_count':
			output_slots.resize(value)
			for index in output_slots.size():
				if output_slots[index].is_empty():
					output_slots[index] = SLOT_PRESETS.default.outputs[0]
		property when property.begins_with('input_slot_'):
			_set_array_property(property.trim_prefix('input_slot_'), input_slots, value)
		property when property.begins_with('output_slot_'):
			_set_array_property(property.trim_prefix('output_slot_'), output_slots, value)
	notify_property_list_changed()
	return true


func _get(property: StringName) -> Variant:
	match property:
		'input_slot_count':
			return input_slots.size()
		'output_slot_count':
			return output_slots.size()
		property when property.begins_with('input_slot_'):
			return _get_array_property(property.trim_prefix('input_slot_'), input_slots)
		property when property.begins_with('output_slot_'):
			return _get_array_property(property.trim_prefix('output_slot_'), output_slots)
	return null


func _property_get_revert(property: StringName) -> Variant:
	match property:
		'color':
			return GROUP_COLORS[group]
	return DEFAULT_DATA.get(property)


func _property_can_revert(property: StringName) -> bool:
	match property:
		'color':
			return color != GROUP_COLORS[group]
	return DEFAULT_DATA.has(property) and DEFAULT_DATA.get(property) != get(property)


func _set_array_property(property: StringName, array: Array, value: Variant) -> void:
	var keys := property.split('/') as Array
	var index: int = int(keys.pop_front())
	if index >= array.size():
		return
	array[index] = _set_dict_value(array[index], keys, value)


func _get_array_property(property: StringName, array: Array) -> Variant:
	var keys := property.split('/') as Array
	var index: int = int(keys.pop_front())
	if index >= array.size():
		return null
	return _get_dict_value(array[index], keys)


func _set_dict_value(dict: Dictionary, keys: Array, value: Variant) -> Dictionary:
	var result_dict: Dictionary = dict.duplicate(true)
	var current: Dictionary = result_dict
	for key in keys.slice(0, keys.size() - 1):
		if not current.has(key):
			current[key] = {}
		current = current[key]
	current[keys[-1]] = value
	return result_dict


func _get_dict_value(dict: Dictionary, keys: Array) -> Variant:
	if keys.size() > 1:
		return _get_dict_value(dict.get(keys[0], {}), keys.slice(1, keys.size()))
	else:
		return dict.get(keys[0])
