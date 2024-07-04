@tool
extends Tree


enum Columns {
	NAME,
	VALUE
}
enum Buttons {
	ADD_LOCAL,
	ADD_GLOBAL,
	REMOVE
}
enum ItemType {
	FOLDER_LOCAL,
	FOLDER_GLOBAL,
	VARIABLE_LOCAL,
	VARIABLE_GLOBAL,
	OPTION_INIT
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
const ITEM_TITLE: Dictionary = {
	ItemType.FOLDER_LOCAL: 'Local',
	ItemType.FOLDER_GLOBAL: 'Global',
	ItemType.VARIABLE_LOCAL: 'new_%s',
	ItemType.VARIABLE_GLOBAL: 'new_%s',
	ItemType.OPTION_INIT: 'Init',
}

@export var variable_add_menu: PopupMenu

var _local_folder: TreeItem
var _global_folder: TreeItem


func _ready() -> void:
	_create_tree()
	button_clicked.connect(_on_button_clicked)
	item_activated.connect(_on_item_activated)
	item_edited.connect(_on_item_edited)

	set_variables({
		'variables': {
			'local': {
				'name': {
					'type': 0,
					'value': 1,
					'init': true
				}
			},
			'global': {
				'name': {
					'type': 0,
					'value': 1,
					'init': true
				}
			}
		}
	})


func _create_tree() -> void:
	create_item()
	_local_folder = _create_folder(ItemType.FOLDER_LOCAL)
	_global_folder = _create_folder(ItemType.FOLDER_GLOBAL)


func _create_folder(item_type: ItemType) -> TreeItem:
	var folder_item = get_root().create_child()
	folder_item.set_text(Columns.NAME, ITEM_TITLE[item_type])
	folder_item.set_selectable(Columns.NAME, false)
	folder_item.set_selectable(Columns.VALUE, false)
	folder_item.add_button(Columns.VALUE, ADD_BUTTON_TEXTURE, item_type)
	_set_item_type(folder_item, item_type)
	return folder_item


func _set_item_type(item: TreeItem, item_type: ItemType) -> void:
	item.set_meta('type', item_type)


func _get_item_type(item: TreeItem) -> ItemType:
	return item.get_meta('type', -1)


func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	match id:
		Buttons.ADD_LOCAL, Buttons.ADD_GLOBAL:
			_popup_menu(item, column)
		Buttons.REMOVE:
			item.free()


func _popup_menu(item: TreeItem, column: int) -> void:
	var item_area_rect: Rect2 = get_item_area_rect(item, column)
	if variable_add_menu.id_pressed.is_connected(_on_variable_add_menu_pressed):
		variable_add_menu.id_pressed.disconnect(_on_variable_add_menu_pressed)
	variable_add_menu.id_pressed.connect(_on_variable_add_menu_pressed.bind(item))
	item_area_rect.position += global_position + item_area_rect.size
	variable_add_menu.popup(item_area_rect)


func _on_variable_add_menu_pressed(menu_id: int, item: TreeItem) -> void:
	_create_variable(item, menu_id)


func _create_variable(item_folder: TreeItem, variable_type: int, variable_name: String = '', variable_value: Variant = null) -> void:
	var variable_item: TreeItem = _create_variable_item(item_folder, variable_type, variable_name)
	match variable_type:
		TYPE_STRING:
			if variable_value == null:
				variable_value = ''
			variable_item.set_text(Columns.VALUE, variable_value)
		TYPE_BOOL:
			if variable_value == null:
				variable_value = false
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_CHECK)
			variable_item.set_checked(Columns.VALUE, variable_value)
		TYPE_INT:
			if variable_value == null:
				variable_value = 0
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 1)
			variable_item.set_range(Columns.VALUE, variable_value)
		TYPE_FLOAT:
			if variable_value == null:
				variable_value = 0
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 0.001)
			variable_item.set_range(Columns.VALUE, variable_value)


func _create_variable_item(item_folder: TreeItem, variable_type: int, variable_name: String = '') -> TreeItem:
	if variable_name.is_empty():
		variable_name = ('new_%s' % TYPE_TITLE[variable_type]).to_lower()
	var item_type: ItemType = ItemType.VARIABLE_LOCAL if _get_item_type(item_folder) == ItemType.FOLDER_LOCAL else ItemType.VARIABLE_GLOBAL
	var item: TreeItem = item_folder.create_child()
	item.set_icon(Columns.NAME, TYPE_TEXTURE[variable_type])
	item.set_text(Columns.NAME, variable_name)
	item.set_editable(Columns.VALUE, true)
	item.add_button(Columns.VALUE, REMOVE_BUTTON_TEXTURE, Buttons.REMOVE)
	_set_item_type(item, item_type)

	if item_type == ItemType.VARIABLE_GLOBAL:
		_create_option(item, ItemType.OPTION_INIT)

	return item


func _create_option(item: TreeItem, option_type: ItemType) -> void:
	var option: TreeItem = item.create_child()
	option.set_text(Columns.NAME, ITEM_TITLE[option_type])
	option.set_selectable(Columns.NAME, false)
	option.set_editable(Columns.VALUE, true)
	option.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_CHECK)
	_set_item_type(option, option_type)


func _on_item_activated() -> void:
	if get_selected():
		edit_selected(true)


func _on_item_edited() -> void:
	pass


func set_variables(variables: Dictionary) -> void:
	pass


func get_variables() -> Dictionary:
	return {}
