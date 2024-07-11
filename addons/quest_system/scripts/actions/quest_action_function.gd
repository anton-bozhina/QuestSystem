@tool
class_name QuestActionFunction
extends QuestAction


static var folder_name: StringName = 'Functions'
static var folder_position: int = -1

var node_color: Color = Color.DARK_GOLDENROD
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true


func _perform_task() -> void:
	_perform_function()
	performed.emit(0)


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_function() -> void:
	pass
