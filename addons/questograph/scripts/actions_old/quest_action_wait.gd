@tool
class_name QuestActionWait
extends QuestAction

signal waited

static var folder_name: StringName = 'Waiting'
static var folder_position: int = -1

var node_color: Color = Color.CORNFLOWER_BLUE
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true


func _node_init() -> void:
	pass


func _action_init() -> void:
	pass


func _perform_wait() -> void:
	pass


func _perform_task() -> void:
	waited.connect(_on_waited, CONNECT_ONE_SHOT)
	_perform_wait()


func _on_waited() -> void:
	performed.emit(0)
