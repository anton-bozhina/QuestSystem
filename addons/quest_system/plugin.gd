@tool
extends EditorPlugin

const MainPanel = preload('scenes/main_panel.tscn')

var main_panel_instance: QuestEditor


func _enter_tree() -> void:
	_connect_to_filesystem_tree(EditorInterface.get_file_system_dock())
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

	EditorInterface.get_current_feature_profile()


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()


func _on_item_activated(variable: Variant = null) -> void:
	if EditorInterface.get_inspector().get_edited_object() is QuestData:
		main_panel_instance.open_quest_from_inspector(EditorInterface.get_inspector().get_edited_object())


func _connect_to_filesystem_tree(parent_node: Node) -> void:
	for node in parent_node.get_children():
		_connect_to_filesystem_tree(node)
		if node is Tree or node is ItemList:
			node.item_activated.connect(_on_item_activated)


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.update_lists()
		main_panel_instance.visible = visible


func _get_plugin_name() -> String:
	return 'QuestSystem'


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon('Node', 'EditorIcons')
