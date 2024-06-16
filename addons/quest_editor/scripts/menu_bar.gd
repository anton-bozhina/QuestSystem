@tool
class_name QuestEditMenuBar
extends MenuBar

signal new_quest_pressed
signal save_quest_pressed
signal save_all_quest_pressed
signal close_quest_pressed


var ids_signals: Dictionary = {
	0: new_quest_pressed,
	1: save_quest_pressed,
	2: save_all_quest_pressed,
	3: close_quest_pressed
}


func _on_file_id_pressed(id: int) -> void:
	if ids_signals.has(id):
		ids_signals[id].emit()
