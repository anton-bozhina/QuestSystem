@tool
class_name QuestActionLogicRandom
extends QuestActionLogic

static var node_name = 'RandomSlot'

@export var slot_ratio: float = 0.5


func _node_init() -> void:
	folder_name = 'LOL KEK'
	node_show_right_slot = true
	node_show_left_slot = true
	node_show_second_right_slot = true


func _perform_task() -> void:
	var random_number: float = randf()
	if random_number <= slot_ratio:
		performed.emit(0)
	else:
		performed.emit(1)
