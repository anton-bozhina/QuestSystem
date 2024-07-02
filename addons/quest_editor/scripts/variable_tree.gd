@tool
class_name QuestEditVariableTree
extends Tree


signal variables_updated(variables: QuestVariables)


enum Columns {
	NAME,
	VALUE
}

@export var add_button: MenuButton
@export var delete_button: Button

var variables: QuestVariables


func _ready() -> void:
	add_button.get_popup().id_pressed.connect(_on_add_button_id_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

	create_item()

	set_column_title(Columns.NAME, 'Name')
	set_column_title(Columns.VALUE, 'Value')


func _on_add_button_id_pressed(id: int) -> void:
	var item_text: String = add_button.get_popup().get_item_text(add_button.get_popup().get_item_index(id)).to_lower()
	_add_variable(id, 'new_%s' % item_text)
	item_edited.emit()


func _add_variable(variable_type: int, variable_name: String, variable_value: Variant = null) -> void:
	var variable_item: TreeItem = _create_and_set_item(variable_name)
	match variable_type:
		TYPE_STRING:
			if variable_value == null:
				variable_value = ''
			variable_item.set_text(Columns.VALUE, variable_value)
		TYPE_BOOL:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_CHECK)
			if variable_value == null:
				variable_value = false
			variable_item.set_checked(Columns.VALUE, variable_value)
		TYPE_INT:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 1)
			if variable_value == null:
				variable_value = 0
			variable_item.set_range(Columns.VALUE, int(variable_value))
		TYPE_FLOAT:
			variable_item.set_cell_mode(Columns.VALUE, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(Columns.VALUE, -99999999, 99999999, 0.001)
			if variable_value == null:
				variable_value = 0
			variable_item.set_range(Columns.VALUE, float(variable_value))


func _create_and_set_item(item_name: String) -> TreeItem:
	var item: TreeItem = get_root().create_child()
	item.set_editable(Columns.VALUE, true)
	item.set_text(Columns.NAME, item_name)

	return item


func _on_delete_button_pressed() -> void:
	if get_selected():
		get_selected().free()
		item_edited.emit()


func _on_item_edited() -> void:
	_update_variables()
	variables_updated.emit(variables)


func _on_item_activated() -> void:
	edit_selected(true)


func _update_variables() -> void:
	variables.clear()
	for item in get_root().get_children():
		var variable_name: String = item.get_text(Columns.NAME).validate_node_name().replace(' ', '_')
		item.set_text(Columns.NAME, variable_name)
		match item.get_cell_mode(Columns.VALUE):
			TreeItem.CELL_MODE_STRING:
				variables.set_variable(variable_name, item.get_text(Columns.VALUE), TYPE_STRING)
			TreeItem.CELL_MODE_CHECK:
				variables.set_variable(variable_name, item.is_checked(Columns.VALUE), TYPE_BOOL)
			TreeItem.CELL_MODE_RANGE:
				if item.get_range_config(Columns.VALUE)['step'] == 1:
					variables.set_variable(variable_name, item.get_range(Columns.VALUE), TYPE_INT)
				else:
					variables.set_variable(variable_name, item.get_range(Columns.VALUE), TYPE_FLOAT)


func get_variables() -> QuestVariables:
	return variables


func set_variables(new_variables: QuestVariables) -> void:
	clear()
	create_item()

	variables = new_variables
	for variable in variables.get_variable_list():
		_add_variable(variables.get_variable_type(variable), variable, variables.get_variable(variable))
	item_edited.emit()
