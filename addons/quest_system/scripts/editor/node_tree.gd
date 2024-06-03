@tool
class_name QuestEditorNodeTree
extends Tree


signal tree_item_activated(quest_action: QuestAction)


func _create_quest_action_class_list(parent_class: StringName, class_list: Array = []) -> Array[QuestAction]:
	var result: Array[QuestAction] = []
	var global_class_list: Array[Dictionary] = []

	if class_list.is_empty():
		global_class_list = ProjectSettings.get_global_class_list()
	else:
		global_class_list = class_list

	for global_class in global_class_list:
		if global_class['base'] != parent_class:
			continue
		result.append_array(_create_quest_action_class_list(global_class['class'], global_class_list))

		var quest_action: QuestAction = load(global_class['path']).new()
		if not quest_action.ignore:
			result.append(quest_action)
	return result


func _on_item_activated() -> void:
	if get_selected().has_meta('action'):
		tree_item_activated.emit(get_selected().get_meta('action'))


func _get_folder_by_name(folder_name: StringName, index: int = 0) -> TreeItem:
	var folders: Array[TreeItem] = get_root().get_children()
	for folder in folders:
		if folder.get_text(0) == folder_name:
			return folder

	var new_folder: TreeItem = get_root().create_child(index)
	new_folder.set_text(0, folder_name)
	return new_folder


func _create_tree_items(action_list: Array[QuestAction]) -> void:
	for action in action_list:
		var folder: TreeItem = _get_folder_by_name(action.folder_name, action.folder_position)
		var new_node: TreeItem = folder.create_child()
		new_node.set_text(0, action.name)
		new_node.set_meta('action', action)


func create_tree(parent_class: StringName) -> void:
	clear()
	create_item()

	var action_list: Array[QuestAction] = _create_quest_action_class_list(parent_class)
	_create_tree_items(action_list)
