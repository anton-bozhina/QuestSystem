@tool
extends Node

const QUEST_CLASS_PARENT = 'QuestAction'

var _global_variables: QuestVariables = QuestVariables.new()
var _action_class_name_dict: Dictionary = {}
var _action_class_script_dict: Dictionary = {}


func _ready() -> void:
	update_action_class_list()


func _create_action_class_list(parent_class: StringName, class_list: Array[Dictionary]) -> void:
	var global_class_list: Array[Dictionary] = class_list.filter(_class_filter.bind(parent_class))
	for global_class in global_class_list.duplicate() as Array[Dictionary]:
		var action_class_name: StringName = global_class['class']
		var action_script: GDScript = load(global_class['path'])
		if action_script.get('node_name'):
			_action_class_name_dict[action_class_name] = action_script
			_action_class_script_dict[action_script] = action_class_name
		_create_action_class_list(action_class_name, class_list)


func _class_filter(class_dict: Dictionary, parent_class: StringName) -> bool:
	return class_dict['base'] == parent_class


func update_action_class_list() -> void:
	_action_class_name_dict = {}
	_action_class_script_dict = {}
	_create_action_class_list(QUEST_CLASS_PARENT, ProjectSettings.get_global_class_list())


func get_action_script_list() -> Array:
	return _action_class_script_dict.keys()


func get_action_script(quest_action_class_name: StringName) -> GDScript:
	return _action_class_name_dict.get(quest_action_class_name)


func get_action_class_name(quest_action_script: GDScript) -> StringName:
	return _action_class_script_dict.get(quest_action_script, '')


func get_global_variables() -> QuestVariables:
	return _global_variables
