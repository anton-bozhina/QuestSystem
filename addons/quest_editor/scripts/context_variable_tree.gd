@tool
extends Tree


signal variables_updated


enum Columns {
	NAME,
	VALUE
}
enum Buttons {
	ADD,
	REMOVE
}

const LOCAL_NAME: StringName = 'Local'
const GLOBAL_NAME: StringName = 'Global'
const INIT_NAME: StringName = 'Init'
const ADD_BUTTON_TEXTURE: Texture2D = preload('res://addons/quest_editor/icons/ToolAddNode.svg')
const REMOVE_BUTTON_TEXTURE: Texture2D = preload('res://addons/quest_editor/icons/Remove.svg')
const TYPE_TEXTURE: Dictionary = {
	TYPE_STRING: preload('res://addons/quest_editor/icons/String.svg'),
	TYPE_BOOL: preload('res://addons/quest_editor/icons/bool.svg'),
	TYPE_INT: preload('res://addons/quest_editor/icons/int.svg'),
	TYPE_FLOAT: preload('res://addons/quest_editor/icons/float.svg'),
	-1: preload('res://addons/quest_editor/icons/Tools.svg')
}

@export var variable_add_menu: PopupMenu

var _local_folder: TreeItem
var _global_folder: TreeItem


class VariableItemData:
	const NAME_TYPE: Dictionary = {
		TYPE_STRING: 'string',
		TYPE_BOOL: 'bool',
		TYPE_INT: 'integer',
		TYPE_FLOAT: 'float'
	}
	const NAME_TEMPLATE: StringName = 'new_%s'

	var type: Variant.Type
	var name: StringName
	var value: Variant
	var options: Array[VariableItemData] = []

	func _init(variable_type: Variant.Type = TYPE_NIL, variable_name: StringName = '', variable_value: Variant = null, variable_texture: Texture2D = null) -> void:
		type = variable_type
		name = variable_name

		if variable_value == null:
			if type == TYPE_STRING:
				value = ''
			elif type == TYPE_BOOL:
				value = false
			elif type == TYPE_INT or type == TYPE_FLOAT:
				value = 0
		else:
			value = variable_value

		if variable_name.is_empty():
			name = NAME_TEMPLATE % NAME_TYPE[type]

	func add_option(variable: VariableItemData) -> void:
		options.append(variable)


func _ready() -> void:
	_tree_initialize()
	button_clicked.connect(_on_button_clicked)
	item_activated.connect(_on_item_activated)
	item_edited.connect(_on_item_edited)

	set_variables({
			'local': {
				'some_bool': {
					'type': TYPE_BOOL,
					'value': true
				}
			},
			'global': {
				'some_float': {
					'type': TYPE_FLOAT,
					'value': 1.99,
					'options': {
						'init': {
							'type': TYPE_BOOL,
							'value': true
						}
					}
				}
			}
	})

	print(get_variables())


func _tree_initialize() -> void:
	clear()
	create_item()
	_local_folder = _create_folder(LOCAL_NAME)
	_global_folder = _create_folder(GLOBAL_NAME)


func _create_folder(folder_name: String) -> TreeItem:
	var folder_item = get_root().create_child()
	folder_item.set_text(Columns.NAME, folder_name)
	folder_item.set_selectable(Columns.NAME, false)
	folder_item.set_selectable(Columns.VALUE, false)
	folder_item.add_button(Columns.VALUE, ADD_BUTTON_TEXTURE, Buttons.ADD)
	return folder_item


func _on_button_clicked(tree_item: TreeItem, column: int, button_id: int, mouse_button_index: int) -> void:
	match button_id:
		Buttons.ADD:
			_popup_menu(tree_item, column)
		Buttons.REMOVE:
			tree_item.free()
			item_edited.emit()


func _popup_menu(folder: TreeItem, column: int) -> void:
	var folder_icon_rect: Rect2 = get_item_area_rect(folder, column)
	if variable_add_menu.id_pressed.is_connected(_on_variable_add_menu_pressed):
		variable_add_menu.id_pressed.disconnect(_on_variable_add_menu_pressed)
	variable_add_menu.id_pressed.connect(_on_variable_add_menu_pressed.bind(folder))
	folder_icon_rect.position += global_position + folder_icon_rect.size
	variable_add_menu.popup(folder_icon_rect)


func _on_item_activated() -> void:
	if get_selected():
		edit_selected(true)


func _on_item_edited() -> void:
	variables_updated.emit()


func _on_variable_add_menu_pressed(menu_id: int, folder: TreeItem) -> void:
	var variable_item_data: VariableItemData = VariableItemData.new(menu_id)
	if folder == _global_folder:
		variable_item_data.add_option(VariableItemData.new(TYPE_BOOL, INIT_NAME, false))
	_add_variable_item_to_tree(folder, variable_item_data)
	item_edited.emit()


func _add_variable_item_to_tree(folder: TreeItem, variable_item_data: VariableItemData, removable: bool = true) -> TreeItem:
	var variable_item: TreeItem = folder.create_child()
	variable_item.set_icon(Columns.NAME, TYPE_TEXTURE[variable_item_data.type])
	variable_item.set_text(Columns.NAME, variable_item_data.name)
	variable_item.set_editable(Columns.VALUE, true)
	if removable:
		variable_item.add_button(Columns.VALUE, REMOVE_BUTTON_TEXTURE, Buttons.REMOVE)

	_set_variable_item_value(variable_item, variable_item_data)

	for option in variable_item_data.options:
		var option_item: TreeItem = _add_variable_item_to_tree(variable_item, option, false)
		option_item.set_icon(Columns.NAME, TYPE_TEXTURE[-1])
		option_item.set_selectable(Columns.NAME, false)
		option_item.set_editable(Columns.VALUE, true)

	return variable_item


func _set_variable_item_value(variable_item: TreeItem, variable_item_data: VariableItemData) -> void:
	match variable_item_data.type:
		TYPE_STRING:
			variable_item.set_text(Columns.VALUE, variable_item_data.value)
		TYPE_BOOL:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_CHECK)
			variable_item.set_checked(Columns.VALUE, variable_item_data.value)
		TYPE_INT:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 1)
			variable_item.set_range(Columns.VALUE, variable_item_data.value)
		TYPE_FLOAT:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 0.001)
			variable_item.set_range(Columns.VALUE, variable_item_data.value)


func _dict_to_folder(folder: TreeItem, variables_dict: Dictionary) -> void:
	for variable_name in variables_dict:
		_add_variable_item_to_tree(folder, _dict_to_variable_item_data(variable_name, variables_dict[variable_name]))


func _dict_to_variable_item_data(variable_name: StringName, variable_data: Dictionary) -> VariableItemData:
	var variable_type: Variant.Type = variable_data.get('type', TYPE_NIL)
	var variable_value: Variant = variable_data.get('value')
	var options: Dictionary = variable_data.get('options', {})
	var variable: VariableItemData = VariableItemData.new(variable_type, variable_name, variable_value)
	for option_name in options:
		variable.add_option(_dict_to_variable_item_data(option_name.capitalize(), options[option_name]))
	return variable


func _folder_to_dict(folder_item: TreeItem, options: bool = false) -> Dictionary:
	var result: Dictionary = {}
	for variable_tree_item in folder_item.get_children():
		var variable_name: StringName = variable_tree_item.get_text(Columns.NAME).to_snake_case()
		var variable_value: Variant = null
		var variable_type: Variant.Type = TYPE_NIL
		match variable_tree_item.get_cell_mode(Columns.VALUE):
			TreeItem.CELL_MODE_STRING:
				variable_value = variable_tree_item.get_text(Columns.VALUE)
				variable_type = TYPE_STRING
			TreeItem.CELL_MODE_CHECK:
				variable_value = variable_tree_item.is_checked(Columns.VALUE)
				variable_type = TYPE_BOOL
			TreeItem.CELL_MODE_RANGE:
				if variable_tree_item.get_range_config(Columns.VALUE)['step'] == 1:
					variable_value = variable_tree_item.get_range(Columns.VALUE)
					variable_type = TYPE_INT
				else:
					variable_value = variable_tree_item.get_range(Columns.VALUE)
					variable_type = TYPE_FLOAT

		result[variable_name] = {
			'type': variable_type,
			'value': variable_value
		}

		if variable_tree_item.get_child_count() > 0:
			result[variable_name]['options'] = _folder_to_dict(variable_tree_item, true)

	return result


func set_variables(variables: Dictionary) -> void:
	_tree_initialize()
	var local: Dictionary = variables.get('local', {})
	var global: Dictionary = variables.get('global', {})
	_dict_to_folder(_local_folder, local)
	_dict_to_folder(_global_folder, global)
	item_edited.emit()


func get_variables() -> Dictionary:
	return {
		'local': _folder_to_dict(_local_folder),
		'global': _folder_to_dict(_global_folder)
	}



