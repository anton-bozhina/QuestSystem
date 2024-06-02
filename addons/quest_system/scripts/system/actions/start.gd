@tool
class_name QuestActionLogicStart
extends QuestActionLogic


@export var quest_name: String
@export_multiline var quest_description: String


func _init() -> void:
	action_name = 'QuestStart'
	node_show_right_slot = true
