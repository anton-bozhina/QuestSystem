@tool
extends Tree


enum Columns {
	TITLE,
	VALUE
}
enum Buttons {
	ADD_LOCAL,
	ADD_GLOBAL,
	REMOVE
}
enum ItemType {
	FOLDER,
	ITEM,
	ITEM_VALUE,
	ITEM_NAME,
	ITEM_INIT
}
enum FolderType {
	LOCAL,
	GLOBAL
}

const ADD_BUTTON_TEXTURE: Texture2D = preload('res://addons/quest_editor/icons/ToolAddNode.svg')
const REMOVE_BUTTON_TEXTURE: Texture2D = preload('res://addons/quest_editor/icons/Remove.svg')
const TYPE_TEXTURE: Dictionary = {
	TYPE_STRING: preload('res://addons/quest_editor/icons/String.svg'),
	TYPE_BOOL: preload('res://addons/quest_editor/icons/bool.svg'),
	TYPE_INT: preload('res://addons/quest_editor/icons/int.svg'),
	TYPE_FLOAT: preload('res://addons/quest_editor/icons/float.svg')
}
const TYPE_TITLE: Dictionary = {
	TYPE_STRING: 'String',
	TYPE_BOOL: 'Bool',
	TYPE_INT: 'Integer',
	TYPE_FLOAT: 'Float'
}
const ITEM_TYPE_TITLE: Dictionary = {
	ItemType.ITEM_VALUE: 'Value',
	ItemType.ITEM_NAME: 'Name',
	ItemType.ITEM_INIT: 'Init'
}
const FOLDER_TITLE: Dictionary = {
	FolderType.LOCAL: 'Local Variables',
	FolderType.GLOBAL: 'Global Variables',
}

@export var variable_add_menu: PopupMenu

var _local_folder: TreeItem
var _global_folder: TreeItem


func _ready() -> void:
	_create_tree()
	set_column_expand(Columns.TITLE, false)
	button_clicked.connect(_on_button_clicked)
	item_edited.connect(_on_item_edited)


func _create_tree() -> void:
	create_item()
	_local_folder = _create_folder(FolderType.LOCAL)
	_global_folder = _create_folder(FolderType.GLOBAL)


func _create_folder(folder_type: FolderType) -> TreeItem:
	var folder_item = get_root().create_child()
	folder_item.set_text(Columns.TITLE, FOLDER_TITLE[folder_type])
	folder_item.set_selectable(Columns.TITLE, false)
	folder_item.set_selectable(Columns.VALUE, false)
	folder_item.add_button(Columns.VALUE, ADD_BUTTON_TEXTURE, folder_type)
	folder_item.set_meta('type', ItemType.FOLDER)
	return folder_item


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		Buttons.ADD_LOCAL, Buttons.ADD_GLOBAL:
			_popup_menu(item, column, id)
		Buttons.REMOVE:
			item.free()


func _popup_menu(item: TreeItem, column: int, id: int) -> void:
	var item_area_rect: Rect2 = get_item_area_rect(item, column)
	if variable_add_menu.id_pressed.is_connected(_on_variable_add_menu_pressed):
		variable_add_menu.id_pressed.disconnect(_on_variable_add_menu_pressed)
	variable_add_menu.id_pressed.connect(_on_variable_add_menu_pressed.bind(item, id))
	item_area_rect.position += global_position + item_area_rect.size
	variable_add_menu.popup(item_area_rect)


func _on_variable_add_menu_pressed(menu_id: int, item: TreeItem, button_id: Buttons) -> void:
	_create_variable_item(item, menu_id, button_id)


func _create_variable_item(folder_item: TreeItem, id: int, button_id: Buttons) -> void:
	var item: TreeItem = folder_item.create_child()
	item.set_icon(Columns.TITLE, TYPE_TEXTURE[id])
	item.set_text(Columns.TITLE, '')
	item.set_selectable(Columns.TITLE, false)
	item.set_selectable(Columns.VALUE, false)
	item.add_button(Columns.VALUE, REMOVE_BUTTON_TEXTURE, Buttons.REMOVE)
	item.set_meta('type', ItemType.ITEM)

	_add_variable_item_elements(item, TYPE_STRING, ItemType.ITEM_NAME)
	_add_variable_item_elements(item, id, ItemType.ITEM_VALUE)
	if button_id == Buttons.ADD_GLOBAL:
		_add_variable_item_elements(item, TYPE_BOOL, ItemType.ITEM_INIT)


func _add_variable_item_elements(item: TreeItem, id: int, item_element: ItemType) -> void:
	var element: TreeItem = item.create_child()
	element.set_text(Columns.TITLE, ITEM_TYPE_TITLE[item_element])
	element.set_selectable(Columns.TITLE, false)
	element.set_editable(Columns.VALUE, true)
	element.set_custom_bg_color(Columns.VALUE, Color.DARK_GRAY, true)
	element.set_meta('type', item_element)
	match id:
		TYPE_STRING:
			element.set_text(Columns.VALUE, '')
		TYPE_BOOL:
			element.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_CHECK)
			element.set_checked(Columns.VALUE, false)
		TYPE_INT:
			element.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			element.set_range_config(Columns.VALUE, -99999999, 99999999, 1)
			element.set_range(Columns.VALUE, 0)
		TYPE_FLOAT:
			element.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			element.set_range_config(Columns.VALUE, -99999999, 99999999, 0.001)
			element.set_range(Columns.VALUE, 0)


func _on_item_edited() -> void:
	var edited_element: TreeItem = get_edited()
	var edited_item: TreeItem = edited_element.get_parent()
	if edited_element.get_meta('type') == ItemType.ITEM_NAME:
		edited_item.set_text(Columns.TITLE, edited_element.get_text(Columns.VALUE))
