@tool
class_name QuestEditGraphNodePropertyControl
extends HBoxContainer

signal property_changed
signal update_requested


@export var _property_control: Control
@export var _property_value: StringName = ''
@export var _property_hint: StringName = ''
@export var _property_change_signal: StringName = ''
@export var _can_update_node: bool = false
@export var _label: Label


func _on_property_change_signal(value: Variant = null) -> void:
	property_changed.emit()
	if _can_update_node:
		update_requested.emit()


func set_property_name(property_name: StringName) -> void:
	_label.set_text(property_name)


func set_connection_to_property_signal() -> void:
	if not _property_change_signal.is_empty() and _property_control.has_signal(_property_change_signal):
		_property_control.connect(_property_change_signal, _on_property_change_signal)


func set_property_hint_string(hint_string: String) -> void:
	if not _property_hint.is_empty() and hint_string != 'String':
		_property_control.set(_property_hint, hint_string)


func set_property_value(value: Variant) -> void:
	_property_control.set(_property_value, value)


func get_property_value() -> Variant:
	return _property_control.get(_property_value)
