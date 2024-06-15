@tool
class_name QuestData
extends Resource

@export var quest_name: String
@export_multiline var quest_description: String
@export var quest_variables: Dictionary = {}
@export_group('Actions')
@export var start_action: StringName
@export var actions: Dictionary = {}
@export_group('Quest Editor')
@export var graph_edit_zoom: float = 1
@export var graph_edit_scroll_offset: Vector2 = Vector2.ZERO
@export_subgroup('Danger zone')


func _init() -> void:
	var node_name: StringName = OS.get_unique_id()
	actions[node_name] = {}
	actions[node_name]['class'] = QuestActionLogicStart.new()


func _to_string() -> String:
	return str({
		'quest_name': quest_name,
		'quest_description': quest_description,
		'quest_variables': quest_variables,
		'start_action': start_action,
		'actions': actions
	})
