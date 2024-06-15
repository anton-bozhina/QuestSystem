@tool
class_name QuestActionWait
extends QuestAction

signal wait_is_ower

var folder_name: StringName = 'Waiting'
var folder_position: int = -1

var node_color: Color = Color.CORNFLOWER_BLUE
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true


#@export var next_action: QuestAction


#func _action_task(arguments: Arguments) -> void:
	#_action_wait(arguments)
##
	##if next_action:
		##wait_is_ower.connect(next_action.perform)
#
#
#func _action_wait(_arguments: Arguments) -> void:
	#wait_is_ower.emit()
