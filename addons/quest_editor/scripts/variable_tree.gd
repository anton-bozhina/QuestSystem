@tool
class_name QuestEditVariableTree
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

const ADD_BUTTON_TEXTURE: Texture2D = preload('../icons/ToolAddNode.svg')
const REMOVE_BUTTON_TEXTURE: Texture2D = preload('../icons/Remove.svg')
const TYPE_TEXTURE: Dictionary = {
	TYPE_STRING: preload('../icons/String.svg'),
	TYPE_BOOL: preload('../icons/bool.svg'),
	TYPE_INT: preload('../icons/int.svg'),
	TYPE_FLOAT: preload('../icons/float.svg'),
	-1: preload('../icons/Tools.svg')
}

@export var variable_add_menu: PopupMenu
@export var variable_group: Array[StringName] = []
@export var variable_group_options: Array[Dictionary] = []

@export var variable_groups: Dictionary = {}

var _group_folders: Array[TreeItem] = []


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

	func _init(variable_type: Variant.Type = TYPE_NIL, variable_name: StringName = '', variable_value: Variant = null) -> void:
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
	pass
	#_tree_initialize()
	#item_activated.connect(_on_item_activated)
	#item_edited.connect(_on_item_edited)
	button_clicked.connect(_on_button_clicked)

	create_item()
	for group_name in variable_groups:
		var folder: TreeItem = _create_folder(group_name)
		var group_add_menu: PopupMenu = PopupMenu.new()
		for type_name in variable_groups[group_name]['types']:
			var type: Variant.Type = variable_groups[group_name]['types'][type_name]['type']
			group_add_menu.add_icon_item(TYPE_TEXTURE[type], type_name.capitalize(), type)
		group_add_menu.id_pressed.connect(_on_variable_add_menu_pressed.bind(folder))
		folder.set_meta('menu', group_add_menu)
		add_child(group_add_menu)


func _tree_initialize() -> void:
	clear()
	#create_item()
	#_group_folders.clear()
	#for group_name in variable_group:
		#_group_folders.append(_create_folder(group_name))


func _create_folder(folder_name: StringName) -> TreeItem:
	var folder_item = get_root().create_child()
	folder_item.set_text(Columns.NAME, folder_name.to_pascal_case())
	folder_item.set_selectable(Columns.NAME, false)
	folder_item.set_selectable(Columns.VALUE, false)
	folder_item.add_button(Columns.VALUE, ADD_BUTTON_TEXTURE, Buttons.ADD)
	return folder_item


func _on_item_activated() -> void:
	if get_selected():
		edit_selected(true)


func _on_item_edited() -> void:
	variables_updated.emit()


func _on_button_clicked(tree_item: TreeItem, column: int, button_id: int, mouse_button_index: int) -> void:
	match button_id:
		Buttons.REMOVE:
			tree_item.free()
			item_edited.emit()
		Buttons.ADD:
			_popup_menu(tree_item, column)


func _popup_menu(folder: TreeItem, column: int) -> void:
	var folder_icon_rect: Rect2 = get_item_area_rect(folder, column)
	folder_icon_rect.position += global_position + folder_icon_rect.size
	folder.get_meta('menu').popup(folder_icon_rect)


func _on_variable_add_menu_pressed(menu_id: int, folder: TreeItem) -> void:
	var variable_item_data: VariableItemData = VariableItemData.new(menu_id, '', null)
	var folder_id: int = _group_folders.find(folder)
	if variable_group_options.size() - 1 >= folder_id and typeof(variable_group_options[folder_id]) == TYPE_DICTIONARY:
		var variable_options: Dictionary = variable_group_options[folder_id]
		if not variable_options.is_empty():
			for option_name in variable_options:
				var option_type: int = variable_options[option_name].get('type', 0)
				var option_value: Variant = variable_options[option_name].get('value', null)
				variable_item_data.add_option(VariableItemData.new(option_type, option_name, option_value))
	_add_variable_item_to_tree(variable_item_data, folder)
	item_edited.emit()


func _add_variable_item_to_tree(variable_item_data: VariableItemData, folder: TreeItem, removable: bool = true) -> TreeItem:
	var variable_item: TreeItem = folder.create_child()
	variable_item.set_icon(Columns.NAME, TYPE_TEXTURE[variable_item_data.type])
	variable_item.set_text(Columns.NAME, variable_item_data.name)
	variable_item.set_editable(Columns.VALUE, true)
	if removable:
		variable_item.add_button(Columns.VALUE, REMOVE_BUTTON_TEXTURE, 0)

	_set_variable_item_value(variable_item, variable_item_data)

	for option in variable_item_data.options:
		var option_item: TreeItem = _add_variable_item_to_tree(option, variable_item, false)
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


func _set_variables(variables_dict: Dictionary) -> void:
	for group_name in variables_dict:
		var group_id: int = variable_group.find(group_name)
		if group_id == -1:
			continue
		for variable_name in variables_dict[group_name]:
			var variable_item_data: VariableItemData = _dict_to_variable_item_data(variable_name, variables_dict[group_name][variable_name])
			_add_variable_item_to_tree(variable_item_data, _group_folders[group_id])


func _dict_to_variable_item_data(variable_name: StringName, variable_data: Dictionary) -> VariableItemData:
	var variable_type: Variant.Type = variable_data.get('type', TYPE_NIL)
	var variable_value: Variant = variable_data.get('value')
	var options: Dictionary = variable_data.get('options', {})
	var variable: VariableItemData = VariableItemData.new(variable_type, variable_name, variable_value)
	for option_name in options:
		variable.add_option(_dict_to_variable_item_data(option_name.capitalize(), options[option_name]))
	return variable


func _get_variables(folder_item: TreeItem, options: bool = false) -> Dictionary:
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
			result[variable_name]['options'] = _get_variables(variable_tree_item, true)
#
	return result


func set_variables(variables: Dictionary) -> void:
	#_tree_initialize()
	#_set_variables(variables)
	item_edited.emit()


func get_variables() -> Dictionary:
	var variables: Dictionary = {}
	for folder_index in range(_group_folders.size()):
		variables[variable_group[folder_index]] = _get_variables(_group_folders[folder_index])
	return variables


func get_quest_variables() -> Array[QuestVariables]:
	var result: Array[QuestVariables] = []
	var variables_dict: Dictionary = get_variables()
	for group_name in variables_dict:
		result.append(QuestVariables.new(variables_dict[group_name]))

	return result
