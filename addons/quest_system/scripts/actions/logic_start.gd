@tool
class_name QuestActionLogicStart
extends QuestActionLogic


static var node_name = 'QuestStart'


@export var quest_name: String
@export_multiline var quest_description: String


func _node_init() -> void:
	node_show_right_slot = true
