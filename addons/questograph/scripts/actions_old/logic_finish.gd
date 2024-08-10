@tool
class_name QuestActionLogicFinish
extends QuestActionLogic


static var node_name = 'QuestFinish'


func _node_init() -> void:
	node_caption = 'Stops quest execution'
	node_color = Color.DARK_RED
	node_show_left_slot = true
