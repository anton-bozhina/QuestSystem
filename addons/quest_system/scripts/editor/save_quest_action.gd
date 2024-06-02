@tool
class_name QuestEditorSaveQuestAction
extends Node

signal quest_saved

@onready var save_file_dialog: FileDialog = $SaveFileDialog

var _quest_data: QuestData


func _ready() -> void:
	save_file_dialog.file_selected.connect(_on_save_file_dialog_files_selected)


func _on_save_file_dialog_files_selected(path: String) -> void:
	ResourceSaver.save(_quest_data, path)
	quest_saved.emit()


func initiate(quest_data: QuestData) -> void:
	_quest_data = quest_data
	var quest_data_path: String = _quest_data.get_path()
	if quest_data_path.is_empty():
		var quest_name: String = _quest_data.quest_name.to_snake_case()
		if quest_name.is_empty():
			quest_name = 'new_quest'
		save_file_dialog.set_current_file(quest_name)
		save_file_dialog.popup_centered_ratio()
	else:
		ResourceSaver.save(_quest_data, quest_data_path)
		quest_saved.emit()
