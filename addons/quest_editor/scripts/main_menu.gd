@tool
extends Node

enum EditMenuIds {
	UNDO,
	REDO,
	CUT,
	COPY,
	PASTE,
	SELECT_ALL,
	DUPLICATE
}

const DOCS_URL: String = 'https://github.com/anton-bozhina/QuestSystem/wiki'

const FILE_MENU_SHORTCUTS: Dictionary = {
	3: preload('../shortcuts/save.tres')
}
const EDIT_MENU_SHORTCUTS: Dictionary = {
	EditMenuIds.UNDO: preload('../shortcuts/undo.tres'),
	EditMenuIds.REDO: preload('../shortcuts/redo.tres'),
	EditMenuIds.CUT: preload('../shortcuts/cut.tres'),
	EditMenuIds.COPY: preload('../shortcuts/copy.tres'),
	EditMenuIds.PASTE: preload('../shortcuts/paste.tres'),
	EditMenuIds.SELECT_ALL: preload('../shortcuts/select_all.tres'),
	EditMenuIds.DUPLICATE: preload('../shortcuts/duplicate.tres')
}
const SEARCH_MENU_SHORTCUTS: Dictionary = {
	0: preload('../shortcuts/find.tres')
}


@export var docs_button: Button
@export var file_menu_button: MenuButton
@export var edit_menu_button: MenuButton
@export var search_menu_button: MenuButton


func _ready() -> void:
	docs_button.pressed.connect(_on_docs_button_pressed)
	edit_menu_button.get_popup().id_pressed.connect(_on_edit_menu_pressed.bind(EditMenuIds))
	_set_up_shortcuts(file_menu_button, FILE_MENU_SHORTCUTS)
	_set_up_shortcuts(edit_menu_button, EDIT_MENU_SHORTCUTS)
	_set_up_shortcuts(search_menu_button, SEARCH_MENU_SHORTCUTS)


func _set_up_shortcuts(menu: MenuButton, shortcut_data: Dictionary) -> void:
	for item in shortcut_data:
		menu.get_popup().set_item_shortcut(menu.get_popup().get_item_index(item), shortcut_data[item])


func _on_edit_menu_pressed(id: int, menu: Dictionary) -> void:
	match id:
		EditMenuIds.UNDO when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.REDO when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.CUT when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.COPY when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.PASTE when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.SELECT_ALL when menu == EditMenuIds:
			printt(menu, id)
		EditMenuIds.DUPLICATE when menu == EditMenuIds:
			printt(menu, id)


func _on_docs_button_pressed() -> void:
	OS.shell_open(DOCS_URL)
