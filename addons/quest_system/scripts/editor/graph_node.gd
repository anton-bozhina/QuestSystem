@tool
class_name QuestEditorGraphNode
extends GraphNode

signal property_changed

const CONTROLS: Dictionary = {
	TYPE_INT: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_int.tscn')
	},
	TYPE_FLOAT: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_float.tscn')
	},
	TYPE_BOOL: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_bool.tscn')
	},
	TYPE_STRING: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_string.tscn'),
		PROPERTY_HINT_MULTILINE_TEXT: preload('../../scenes/property_controls/type_multiline.tscn')
	},
	TYPE_STRING_NAME: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_string.tscn')
	}
}

@export var control_container: Container
@export var caption: Label

var action: QuestAction : set = set_action, get = get_action
var control_list: Dictionary = {}


func _create_controls() -> void:
	for control in control_list.keys() as Array[QuestEditGraphNodePropertyControl]:
		control.queue_free()
	control_list.clear()

	caption.text = action.node_caption
	caption.visible = not caption.text.is_empty()

	for property in action.get_property_list().filter(_property_filter):
		var property_type: int = property['type']
		var property_hint: int = property['hint']
		var property_name: StringName = property['name']

		if not CONTROLS.has(property_type):
			return
		elif not CONTROLS[property_type].has(property_hint):
			property_hint = PROPERTY_HINT_NONE

		var new_control: QuestEditGraphNodePropertyControl = CONTROLS[property_type][property_hint].instantiate()
		new_control.set_property_name(property_name.capitalize())
		new_control.set_property_value(action.get(property_name))
		new_control.property_changed.connect(_on_control_property_changed.bind(new_control))
		control_list[new_control] = property_name
		control_container.add_child(new_control)


func _on_control_property_changed(control: QuestEditGraphNodePropertyControl) -> void:
	action.set(control_list[control], control.get_property_value())
	property_changed.emit()
	if typeof(control.get_property_value()) == TYPE_BOOL:
		_create_controls()


func _property_filter(property: Dictionary) -> bool:
	var available_usage: int = PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR
	return property['usage'] == available_usage


func set_action(value: QuestAction) -> void:
	action = value
	title = action.action_name
	self_modulate = action.node_color
	set_slot_enabled_left(0, action.node_show_left_slot)
	set_slot_enabled_right(0, action.node_show_right_slot)
	_create_controls()


func get_action() -> QuestAction:
	return action