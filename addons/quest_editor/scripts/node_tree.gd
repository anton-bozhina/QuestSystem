@tool
class_name QuestEditorNodeTree
extends Tree


signal tree_item_activated(action_class: GDScript)
signal tree_item_gragged(action_class: GDScript)


func _get_drag_data(at_position: Vector2) -> Variant:
	if get_selected() and get_selected().has_meta('action_class'):
		var data: GDScript = get_selected().get_meta('action_class')
		tree_item_gragged.emit(data)
		return data
	else:
		return null


func _on_item_activated() -> void:
	if get_selected() and get_selected().has_meta('action_class'):
		tree_item_activated.emit(get_selected().get_meta('action_class'))


func _get_folder_by_name(folder_name: StringName, index: int = 0) -> TreeItem:
	var folders: Array[TreeItem] = get_root().get_children()
	for folder in folders:
		if folder.get_text(0) == folder_name:
			return folder

	var new_folder: TreeItem = get_root().create_child(index)
	new_folder.set_text(0, folder_name)
	return new_folder


func _create_tree_items() -> void:
	for action in QuestSystem.get_action_script_list() as Array[GDScript]:
		var folder: TreeItem = _get_folder_by_name(action.folder_name, action.folder_position)
		var new_node: TreeItem = folder.create_child()
		new_node.set_text(0, action.node_name)
		new_node.set_meta('action_class', action)


func create_tree() -> void:
	clear()
	create_item()
	_create_tree_items()
