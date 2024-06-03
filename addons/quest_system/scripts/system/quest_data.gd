class_name QuestData
extends Resource

@export var quest_name: String
@export_multiline var quest_description: String
@export_group('Actions')
@export var start_action: StringName
@export var actions: Dictionary = {}
#@export var actions: Dictionary = {
	#'QuestStart_0': {
		#'class': QuestActionLogicStart.new()
	#}
#}
@export_group('Quest Editor')
@export var graph_edit_zoom: float = 1
@export var graph_edit_scroll_offset: Vector2 = Vector2.ZERO
@export_subgroup('Danger zone')
@export var _last_used_id: int = -1

var changes_not_saved: bool = false


func _init() -> void:
	var node_name: StringName = 'QuestStart_%d' % get_node_id()
	actions[node_name] = {}
	actions[node_name]['class'] = QuestActionLogicStart.new()


func _to_string() -> String:
	return str({
		'quest_name': quest_name,
		'quest_description': quest_description,
		'start_action': start_action,
		'actions': actions,
		'last_used_id': _last_used_id
	})


func get_node_id() -> int:
	_last_used_id += 1
	return _last_used_id
