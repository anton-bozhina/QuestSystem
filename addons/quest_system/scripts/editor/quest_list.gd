@tool
class_name QuestEditorQuestList
extends ItemList

var _items: Dictionary = {}


func _get_quest_data_list(start_dir: String) -> Array[QuestData]:
	var dir: DirAccess = DirAccess.open(start_dir)
	var file_list: Array[QuestData] = []
	if not dir:
		return file_list

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			file_list.append_array(_get_quest_data_list(start_dir.path_join(file_name)))
		elif file_name.get_extension() == 'tres':
			var resource: Resource = load(start_dir.path_join(file_name))
			if resource is QuestData:
				file_list.append(resource)
		file_name = dir.get_next()

	return file_list


func get_item_resource(index: int) -> QuestData:
	return _items.get(index)


func create_list() -> void:
	_items.clear()
	clear()
	var quest_data_list: Array[QuestData] = _get_quest_data_list('res://')
	for quest_data in quest_data_list:
		if Engine.is_editor_hint():
			_items[add_item(quest_data.get_path().get_basename().get_file(), EditorInterface.get_editor_theme().get_icon('Node', 'EditorIcons'))] = quest_data
		else:
			_items[add_item(quest_data.get_path().get_basename().get_file())] = quest_data
