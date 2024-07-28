@tool
extends EditorImportPlugin


func _get_importer_name() -> String:
	return 'quest.system.import.plugin'


func _get_visible_name() -> String:
	return 'Quest JSON File'


func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(['quest'])


func _get_save_extension() -> String:
	return 'tres'


func _get_resource_type() -> String:
	return 'Resource'

func _get_preset_count() -> int:
	return 0

func _get_preset_name(preset_index: int) -> String:
	return 'Default'

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return false

func _get_import_options(path: String, preset_index: int) -> Array:
	return []

func _get_priority() -> float:
	return 1.0

func _get_import_order() -> int:
	return 0

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> int:
	var file: FileAccess = FileAccess.open(source_file, FileAccess.READ)
	if not file:
		return FAILED

	var resource_filepath: String = '%s.%s' % [save_path, _get_save_extension()]
	var resource: QuestData = QuestData.new()

	var json_data: Dictionary = JSON.parse_string(file.get_as_text()) as Dictionary
	if not typeof(json_data) == TYPE_DICTIONARY:
		return FAILED

	resource.name = json_data.get('name', '')
	resource.description = json_data.get('description', '')
	resource.start_action = json_data.get('start_action', '')
	resource.variables = json_data.get('variables', {})
	resource.node_references = json_data.get('node_references', {})
	resource.actions = json_data.get('actions', {})

	return ResourceSaver.save(resource, resource_filepath)
