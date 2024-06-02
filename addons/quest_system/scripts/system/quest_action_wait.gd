class_name QuestActionWait
extends QuestAction

signal wait_is_ower

#@export var next_action: QuestAction


func _action_task(arguments: Arguments) -> void:
	_action_wait(arguments)
#
	#if next_action:
		#wait_is_ower.connect(next_action.perform)


func _action_wait(_arguments: Arguments) -> void:
	wait_is_ower.emit()
