@tool
class_name QuestographEditorNodeSettings
extends Resource

const NODE_GROUPS: Array = [
	'Functions',
	'Logic',
	'Waits',
	'Checks',
	'Custom'
]

@export var action_class: QuestAction:
	set(value):
		if value != action_class:
			properties_to_show = {}
		action_class = value
		notify_property_list_changed()
@export var action_name: String:
	set(value):
		action_name = value
		resource_name = 'New Action' if value.is_empty() else value

var node_group: String = 'Functions':
	set(value):
		node_group = value
		notify_property_list_changed()
var node_group_custom: String = ''
var node_title: String = ''
var node_caption: String = ''
var node_color: Color = Color.CADET_BLUE
var show_left_slot: bool = true
var show_right_slot: bool = true
var properties_to_show: Dictionary = {}


func _get_property_list() -> Array[Dictionary]:
	var property_list: Array[Dictionary] = []
	property_list.append({"name": "Editor Settings", "class_name": &"", "type": 0, "hint": 0, "hint_string": "", "usage": 64})
	property_list.append({
		'name': 'node_group',
		'type': TYPE_STRING,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(NODE_GROUPS),
		'usage': PROPERTY_USAGE_SCRIPT_VARIABLE | PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR
	})
	if node_group == 'Custom':
		property_list.append({ "name": "node_group_custom", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 })
	property_list.append({ "name": "node_title", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 })
	property_list.append({ "name": "node_caption", "class_name": &"", "type": 4, "hint": 0, "hint_string": "String", "usage": 4102 })
	property_list.append({ "name": "node_color", "class_name": &"", "type": 20, "hint": 0, "hint_string": "Color", "usage": 4102 })
	if action_class:
		action_class.get_property_list().reduce(_reduce_property_names, properties_to_show)
		property_list.append({ "name": "properties_to_show", "class_name": &"", "type": TYPE_DICTIONARY, "hint": 0, "usage": 4102 })
	property_list.append({ "name": "Slots", "class_name": &"", "type": 0, "hint": 0, "hint_string": "", "usage": 256 })
	property_list.append({ "name": "show_left_slot", "class_name": &"", "type": 1, "hint": 0, "hint_string": "bool", "usage": 4102 })
	property_list.append({ "name": "show_right_slot", "class_name": &"", "type": 1, "hint": 0, "hint_string": "bool", "usage": 4102 })

	return property_list


func _reduce_property_names(list, property) -> Dictionary:
	if property["usage"] == 4102 and not list.has(property['name']):
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
