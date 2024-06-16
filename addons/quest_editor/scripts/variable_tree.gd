@tool
class_name QuestEditVariableTree
extends Tree


signal variables_updated(variables: Dictionary)


@export var add_button: Button
@export var type_selector: OptionButton
@export var delete_button: Button


func _ready() -> void:
	add_button.pressed.connect(_on_add_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

	create_item()
	set_column_title(0, 'Name')
	set_column_title(1, 'Value')
	set_column_custom_minimum_width(0, 100)
	set_column_expand(1, true)
	set_column_expand(0, false)


func _on_add_button_pressed() -> void:
	_add_variable(type_selector.get_selected_id())


func _add_variable(variable_type: int, variable_name: String = 'new_variable', variable_value: Variant = null) -> void:
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
			variable_item.set_range_config(1, -99999999, 99999999, 0.1)
			if variable_value == null:
				variable_value = 0
			variable_item.set_range(1, float(variable_value))


func _create_and_set_item(item_name: String) -> TreeItem:
	var item: TreeItem = create_item(get_root())
	item.set_editable(0, true)
	item.set_editable(1, true)
	item.set_text(0, item_name)

	return item


func _on_delete_button_pressed() -> void:
	get_selected().free()
	_on_item_edited()


func _on_item_edited() -> void:
	var variables: Dictionary = {}
	for item in get_root().get_children():
		var variable_name: String = item.get_text(0).validate_node_name().replace(' ', '_')
		item.set_text(0, variable_name)
		match item.get_cell_mode(1):
			TreeItem.CELL_MODE_STRING:
				variables[variable_name] = {
					'type': TYPE_STRING,
					'value': item.get_text(1)
				}
			TreeItem.CELL_MODE_CHECK:
				variables[variable_name] = {
					'type': TYPE_BOOL,
					'value': item.is_checked(1)
				}
			TreeItem.CELL_MODE_RANGE:
				if item.get_range_config(1)['step'] == 1:
					variables[variable_name] = {
						'type': TYPE_INT,
						'value': item.get_range(1)
					}
				else:
					variables[variable_name] = {
						'type': TYPE_FLOAT,
						'value': item.get_range(1)
					}
	variables_updated.emit(variables)


func save_variables() -> void:
	_on_item_edited()


func load_variables(variables: Dictionary) -> void:
	clear()
	create_item()

	for variable in variables:
		if variable.is_empty():
			continue
		_add_variable(variables[variable]['type'], variable, variables[variable]['value'])
	_on_item_edited()

