@tool
class_name QuestEditorNewQuestAction
extends Node

signal quest_created(quest_data: QuestData)

@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var save_confirm_dialog: ConfirmationDialog = $SaveConfirmationDialog

var _quest_data: QuestData


func _ready() -> void:
	save_confirm_dialog.add_button('Don\'t save', true, 'dont_save')

	save_file_dialog.file_selected.connect(_on_save_file_dialog_files_selected)
	save_confirm_dialog.custom_action.connect(_on_save_confirm_dialog_action)
	save_confirm_dialog.confirmed.connect(_on_save_confirm_dialog_action)


func _on_save_confirm_dialog_action(action: StringName = 'confirmed') -> void:
	match action:
		'confirmed':
			_save_dialog_initiate()
		'dont_save':
			save_confirm_dialog.hide()
			quest_created.emit(QuestData.new())


func _save_dialog_initiate() -> void:
	var quest_data_path: String = _quest_data.get_path()
	if quest_data_path.is_empty():
		var quest_name: String = _quest_data.quest_name.to_snake_case()
		if quest_name.is_empty():
			quest_name = 'new_quest'
		save_file_dialog.set_current_file(quest_name)
		save_file_dialog.popup_centered_ratio()
	else:
		_on_save_file_dialog_files_selected(quest_data_path)


func _on_save_file_dialog_files_selected(path: String) -> void:
	ResourceSaver.save(_quest_data, path)
	quest_created.emit(QuestData.new())


func initiate(quest_data: QuestData) -> void:
	_quest_data = quest_data
	if quest_data.changes_not_saved:
		save_confirm_dialog.popup_centered()
	else:
		quest_created.emit(QuestData.new())
