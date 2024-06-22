@tool
class_name QuestEditVariableTree
extends Tree


signal variables_updated(variables: QuestVariables)


@export var add_button: MenuButton
@export var delete_button: Button

var variables: QuestVariables


func _ready() -> void:
	add_button.get_popup().id_pressed.connect(_on_add_button_id_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

	create_item()
	set_column_title(0, 'Name')
	set_column_title(1, 'Value')
	#set_column_custom_minimum_width(0, 100)
	set_column_expand(1, true)
	set_column_expand(0, true)


func _on_add_button_id_pressed(id: int) -> void:
	_add_variable(id, 'new_%s' % add_button.get_popup().get_item_text(add_button.get_popup().get_item_index(id)).to_lower())
	item_edited.emit()


func _add_variable(variable_type: int, variable_name: String, variable_value: Variant = null) -> void:
	match variable_type:
		TYPE_STRING:
			var variable_item: TreeItem = _create_and_set_item(variable_name)
			if variable_value == null:
				variable_value = ''
			variable_item.set_text(1, variable_value)
		TYPE_BOOL:
			var variable_item: TreeItem = _create_and_set_item(variable_name)
			variable_item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			if variable_value == null:
				variable_value = false
			variable_item.set_checked(1, variable_value)
		TYPE_INT:
			var variable_item: TreeItem = _create_and_set_item(variable_name)
			variable_item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(1, -99999999, 99999999, 1)
			if variable_value == null:
				variable_value = 0
			variable_item.set_range(1, int(variable_value))
		TYPE_FLOAT:
			var variable_item: TreeItem = _create_and_set_item(variable_name)
			variable_item.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
			variable_item.set_range_config(1, -99999999, 99999999, 0.001)
			if variable_value == null:
				variable_value = 0
			variable_item.set_range(1, float(variable_value))


func _create_and_set_item(item_name: String) -> TreeItem:
	var item: TreeItem = create_item(get_root())
	item.set_editable(1, true)
	item.set_text(0, item_name)

	return item


func _on_delete_button_pressed() -> void:
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
		var variable_name: String = item.get_text(0).validate_node_name().replace(' ', '_')
		item.set_text(0, variable_name)
		match item.get_cell_mode(1):
			TreeItem.CELL_MODE_STRING:
				variables.set_variable(variable_name, item.get_text(1), TYPE_STRING)
			TreeItem.CELL_MODE_CHECK:
				variables.set_variable(variable_name, item.is_checked(1), TYPE_BOOL)
			TreeItem.CELL_MODE_RANGE:
				if item.get_range_config(1)['step'] == 1:
					variables.set_variable(variable_name, item.get_range(1), TYPE_INT)
				else:
					variables.set_variable(variable_name, item.get_range(1), TYPE_FLOAT)


func get_variables() -> QuestVariables:
	return variables


func set_variables(new_variables: QuestVariables) -> void:
	clear()
	create_item()

	variables = new_variables
	for variable in variables.get_variable_list():
		_add_variable(variables.get_variable_type(variable), variable, variables.get_variable(variable))
	item_edited.emit()
