@tool
extends EditorPlugin

const MainPanel = preload('scenes/main_panel.tscn')

var main_panel_instance: QuestEditor


func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)

	EditorInterface.get_current_feature_profile()


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()


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
