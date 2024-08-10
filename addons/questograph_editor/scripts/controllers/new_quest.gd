@tool
class_name QuestEditorNewQuestController
extends Node

signal quest_created
signal save_file_selected(path: String)

@onready var save_file_dialog: FileDialog = $SaveFileDialog
@onready var save_confirm_dialog: ConfirmationDialog = $SaveConfirmationDialog

var _quest_name: String
var _quest_file: String


func _ready() -> void:
	save_confirm_dialog.add_button('Don\'t save', true, 'dont_save')

	save_file_dialog.file_selected.connect(_on_save_file_dialog_file_selected)
	save_confirm_dialog.custom_action.connect(_on_save_confirm_dialog_action)
	save_confirm_dialog.confirmed.connect(_on_save_confirm_dialog_action)


func _on_save_confirm_dialog_action(action: StringName = 'confirmed') -> void:
	match action:
		'confirmed':
			_save_dialog_initiate()
		'dont_save':
			save_confirm_dialog.hide()
			quest_created.emit()


func _save_dialog_initiate() -> void:
	if _quest_file.is_empty():
		save_file_dialog.set_current_file(_quest_name.to_snake_case())
		save_file_dialog.popup_centered_ratio()
	else:
		_on_save_file_dialog_file_selected(_quest_file)


func _on_save_file_dialog_file_selected(path: String) -> void:
	save_file_selected.emit(path)
	quest_created.emit()



func initiate(quest_name: String = 'new_quest', quest_file: String = '', show_confirm_dialog: bool = true) -> void:
	_quest_name = quest_name
	_quest_file = quest_file

	if show_confirm_dialog:
		save_confirm_dialog.popup_centered()
	else:
		quest_created.emit()
