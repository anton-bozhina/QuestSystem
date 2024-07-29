@tool
extends Node

const DOCS_URL: String = 'https://github.com/anton-bozhina/QuestSystem/wiki'

const FILE_MENU_SHORTCUTS: Dictionary = {
	3: preload('../shortcuts/save.tres')
}
const EDIT_MENU_SHORTCUTS: Dictionary = {
	0: preload('../shortcuts/undo.tres'),
	1: preload('../shortcuts/redo.tres'),
	3: preload('../shortcuts/cut.tres'),
	4: preload('../shortcuts/copy.tres'),
	5: preload('../shortcuts/paste.tres'),
	7: preload('../shortcuts/select_all.tres'),
	8: preload('../shortcuts/duplicate.tres')
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
	_set_up_shortcuts(file_menu_button, FILE_MENU_SHORTCUTS)
	_set_up_shortcuts(edit_menu_button, EDIT_MENU_SHORTCUTS)
	_set_up_shortcuts(search_menu_button, SEARCH_MENU_SHORTCUTS)


func _set_up_shortcuts(menu: MenuButton, shortcut_data: Dictionary) -> void:
	for item in shortcut_data:
		menu.get_popup().set_item_shortcut(item, shortcut_data[item])


func _on_docs_button_pressed() -> void:
	OS.shell_open(DOCS_URL)
