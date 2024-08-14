@tool
class_name QuestEditorMainMenu
extends Node

signal undo
signal redo

enum EditMenuIds {
	UNDO,
	REDO,
	CUT,
	COPY,
	PASTE,
	DUPLICATE
}

const DOCS_URL: String = 'https://github.com/anton-bozhina/QuestSystem/wiki'

const FILE_MENU_SHORTCUTS: Dictionary = {
	2: preload('../resources/shortcuts/save.tres')
}
const EDIT_MENU_SHORTCUTS: Dictionary = {
	EditMenuIds.UNDO: preload('../resources/shortcuts/undo.tres'),
	EditMenuIds.REDO: preload('../resources/shortcuts/redo.tres'),
	EditMenuIds.CUT: preload('../resources/shortcuts/cut.tres'),
	EditMenuIds.COPY: preload('../resources/shortcuts/copy.tres'),
	EditMenuIds.PASTE: preload('../resources/shortcuts/paste.tres'),
	EditMenuIds.DUPLICATE: preload('../resources/shortcuts/duplicate.tres')
}

@export var graph_edit: QuestEditorGraphEdit
@export var docs_button: Button
@export var file_menu_button: MenuButton
@export var edit_menu_button: MenuButton


func _ready() -> void:
	docs_button.pressed.connect(_on_docs_button_pressed)
	edit_menu_button.get_popup().id_pressed.connect(_on_edit_menu_pressed.bind(EditMenuIds))
	_set_up_shortcuts(file_menu_button, FILE_MENU_SHORTCUTS)
	_set_up_shortcuts(edit_menu_button, EDIT_MENU_SHORTCUTS)


func _set_up_shortcuts(menu: MenuButton, shortcut_data: Dictionary) -> void:
	for item in shortcut_data:
		menu.get_popup().set_item_shortcut(menu.get_popup().get_item_index(item), shortcut_data[item])


func _on_edit_menu_pressed(id: int, menu: Dictionary) -> void:
	match id:
		EditMenuIds.UNDO when menu == EditMenuIds:
			undo.emit()
		EditMenuIds.REDO when menu == EditMenuIds:
			redo.emit()
		EditMenuIds.CUT when menu == EditMenuIds:
			graph_edit.cut_node_request.emit()
		EditMenuIds.COPY when menu == EditMenuIds:
			graph_edit.copy_nodes_request.emit()
		EditMenuIds.PASTE when menu == EditMenuIds:
			graph_edit.paste_nodes_request.emit()
		EditMenuIds.DUPLICATE when menu == EditMenuIds:
			graph_edit.duplicate_nodes_request.emit()


func _on_docs_button_pressed() -> void:
	OS.shell_open(DOCS_URL)


func disable_undo_redo(disable_undo: bool, disable_redo: bool) -> void:
	edit_menu_button.get_popup().set_item_disabled(EditMenuIds.UNDO, disable_undo)
	edit_menu_button.get_popup().set_item_disabled(EditMenuIds.REDO, disable_redo)
