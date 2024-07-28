extends Node2D


@export var quest_node: QuestNode

var save_data: Dictionary


func _on_save_pressed() -> void:
	save_data = quest_node.get_save_data()
	print('Save Data: \n', save_data)


func _on_load_pressed() -> void:
	quest_node.set_save_data(save_data)
	print('Loaded Data: \n', quest_node.get_save_data())
