@tool
extends EditorPlugin

const MainPanel = preload('scenes/main_panel.tscn')

var main_panel_instance: QuestEditor


func _enter_tree() -> void:
	main_panel_instance = MainPanel.instantiate()
	main_panel_instance.set_meta('version', get_plugin_version())
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible

		if visible:
			main_panel_instance.update_window()


func _get_plugin_name() -> String:
	return 'QuestEditor'


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon('Node', 'EditorIcons')
