@tool
class_name QuestEditorGraphNode
extends GraphNode

signal property_changed

const CONTROLS: Dictionary = {
	TYPE_INT: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_int.tscn'),
		PROPERTY_HINT_ENUM: preload('../../scenes/property_controls/type_enum_int.tscn')
	},
	TYPE_FLOAT: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_float.tscn')
	},
	TYPE_BOOL: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_bool.tscn')
	},
	TYPE_STRING: {
		PROPERTY_HINT_NONE: preload('../../scenes/property_controls/type_string.tscn'),
		PROPERTY_HINT_PLACEHOLDER_TEXT: preload('../../scenes/property_controls/type_string.tscn'),
		PROPERTY_HINT_MULTILINE_TEXT: preload('../../scenes/property_controls/type_multiline.tscn'),
		PROPERTY_HINT_ENUM: preload('../../scenes/property_controls/type_enum_string.tscn')
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

	for property in action.get_property_list().filter(_property_filter):
		var property_type: int = property['type']
		var property_hint: int = property['hint']
		var property_hint_string: String = property['hint_string']
		var property_name: StringName = property['name']

		if not CONTROLS.has(property_type):
			return
		elif not CONTROLS[property_type].has(property_hint):
			property_hint = PROPERTY_HINT_NONE

		var new_control: QuestEditGraphNodePropertyControl = CONTROLS[property_type][property_hint].instantiate()
		control_container.add_child(new_control)
		control_list[new_control] = property_name
		new_control.set_property_hint_string(property_hint_string)
		new_control.set_property_name(property_name.capitalize())
		new_control.set_property_value(action.get(property_name))
		new_control.property_changed.connect(_on_control_property_changed.bind(new_control))
		new_control.update_requested.connect(_create_controls)
		new_control.set_connection_to_property_signal()

	caption.text = action.node_caption
	caption.visible = not caption.text.is_empty()
	control_container.get_parent().visible = not control_list.is_empty()


func _on_control_property_changed(control: QuestEditGraphNodePropertyControl) -> void:
	action.set(control_list[control], control.get_property_value())
	property_changed.emit()


func _property_filter(property: Dictionary) -> bool:
	var available_usage: PackedInt32Array = [
		PROPERTY_USAGE_EDITOR,
		PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR,
		PROPERTY_USAGE_SCRIPT_VARIABLE + PROPERTY_USAGE_STORAGE + PROPERTY_USAGE_EDITOR + PROPERTY_USAGE_CLASS_IS_ENUM,
	]
	return property['usage'] in available_usage


func set_action(value: QuestAction) -> void:
	action = value
	title = action.name
	var stylebox_titlebar: StyleBoxFlat = self['theme_override_styles/titlebar']
	var stylebox_titlebar_selected: StyleBoxFlat = self['theme_override_styles/titlebar_selected']
	stylebox_titlebar.bg_color = action.node_color.darkened(0.25)
	stylebox_titlebar_selected.bg_color = action.node_color.darkened(0.1)
	set_slot_enabled_left(0, action.node_show_left_slot)
	set_slot_enabled_right(0, action.node_show_right_slot)

	if action is QuestActionCheck:
		set_slot_enabled_right(1, action.node_show_right_slot)
		set_slot_color_right(1, Color.RED)

	_create_controls()


func get_action() -> QuestAction:
	return action
