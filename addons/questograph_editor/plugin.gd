@tool
extends EditorPlugin

const EditorWindow = preload('scenes/editor_window.tscn')

var editor_window_instance: QuestEditor


func _enter_tree() -> void:
	editor_window_instance = EditorWindow.instantiate()
	editor_window_instance.set_meta('version', get_plugin_version())
	EditorInterface.get_editor_main_screen().add_child(editor_window_instance)
	_make_visible(false)


func _exit_tree() -> void:
	if editor_window_instance:
		editor_window_instance.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if editor_window_instance:
		editor_window_instance.visible = visible

		if visible:
			editor_window_instance.update_window()


func _get_plugin_name() -> String:
	return 'Questograph'


func _get_plugin_icon() -> Texture2D:
	return QuestographEditorIcons.icons.main
