@tool
class_name QuestEditGraphNodePropertyControl
extends HBoxContainer

signal property_changed


@export var _property_control: Control
@export var _property_value: StringName
@export var _property_change_signal: StringName
@export var _label: Label


func _ready() -> void:
	if not _property_change_signal.is_empty() and _property_control.has_signal(_property_change_signal):
		_property_control.connect(_property_change_signal, _on_property_change_signal)


func _on_property_change_signal(value: Variant = null) -> void:
	property_changed.emit()


func set_property_name(property_name: StringName) -> void:
	_label.set_text(property_name)


func set_property_value(value: Variant) -> void:
	_property_control.set(_property_value, value)


func get_property_value() -> Variant:
	return _property_control.get(_property_value)
