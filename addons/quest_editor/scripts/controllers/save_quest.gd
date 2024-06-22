@tool
class_name QuestEditorSaveDialogController
extends Node

signal file_selected(quest_file: String)

@onready var save_file_dialog: FileDialog = $SaveFileDialog


func _ready() -> void:
	save_file_dialog.file_selected.connect(_on_save_file_dialog_files_selected)


func _on_save_file_dialog_files_selected(quest_file: String) -> void:
	file_selected.emit(quest_file)


func initiate(quest_name: String, quest_file: String = '') -> void:
	if quest_name.is_empty():
		quest_name = 'new_quest'

	if quest_file.is_empty():
		save_file_dialog.set_current_file(quest_name.to_snake_case())
		save_file_dialog.popup_centered_ratio()
	else:
		file_selected.emit(quest_file)
