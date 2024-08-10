@tool
extends EditorPlugin

const AUTOLOAD_NAME: StringName = 'QuestSystem'
const QUEST_SYSTEM_AUTOLOAD: String = 'scripts/questograph.gd'
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
