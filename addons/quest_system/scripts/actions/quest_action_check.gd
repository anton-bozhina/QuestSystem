@tool
class_name QuestActionCheck
extends QuestAction

static var folder_name: StringName = 'Checks'
static var folder_position: int = -1

var node_color: Color = Color.DARK_OLIVE_GREEN
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_check() -> bool:
	return false


func _perform_task() -> void:
	if _perform_check():
		performed.emit(0)
	else:
		performed.emit(1)
