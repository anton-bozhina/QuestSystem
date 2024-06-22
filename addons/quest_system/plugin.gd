@tool
extends EditorPlugin

const AUTOLOAD_NAME: StringName = 'QuestSystem'
const QUEST_SYSTEM_AUTOLOAD: String = 'scripts/quest_system.gd'
const IMPORT_PLUGIN: GDScript = preload('scripts/quest_import.gd')

var import_plugin: EditorImportPlugin

func _enter_tree():
	add_autoload_singleton(AUTOLOAD_NAME, QUEST_SYSTEM_AUTOLOAD)
	import_plugin = IMPORT_PLUGIN.new()
	add_import_plugin(import_plugin)


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_import_plugin(import_plugin)
	import_plugin = null


#func _enter_tree() -> void:
	#main_panel_instance = MainPanel.instantiate()
	#EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	#_make_visible(false)
#
	#EditorInterface.get_current_feature_profile()
#
#
#func _exit_tree() -> void:
	#if main_panel_instance:
		#main_panel_instance.queue_free()
#
#
#func _has_main_screen() -> bool:
	#return true
#
#
#func _make_visible(visible: bool) -> void:
	#if main_panel_instance:
		#main_panel_instance.update_lists()
		#main_panel_instance.visible = visible
#
#
#func _get_plugin_name() -> String:
	#return 'QuestSystem'
#
#
#func _get_plugin_icon() -> Texture2D:
	#return EditorInterface.get_editor_theme().get_icon('Node', 'EditorIcons')
