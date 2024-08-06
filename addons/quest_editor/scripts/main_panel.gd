@tool
class_name QuestEditor
extends MarginContainer

const QUEST_CLASS_PARENT = 'QuestAction'

@export var node_tree: QuestEditorNodeTree
@export var graph_edit: QuestEditorGraphEdit
@export var variable_tree: QuestEditVariableTree
@export var file_label: Label
@export var file_menu_button: MenuButton
@export var quest_data_controller: QuestEditorQuestDataController
@export var open_quest_controller: QuestEditorOpenQuestController
@export var save_dialog_controller: QuestEditorSaveDialogController
@export var new_quest_controller: QuestEditorNewQuestController
@export var main_menu: QuestEditorMainMenu

var _edit_history_undo: Array = []
var _edit_history_do: Array = []
var _apply_from_history: bool = false

var quest_changed: bool = false :
	set(value):
		quest_changed = value
		_update_quest_data_label()


func _ready() -> void:
	node_tree.tree_item_activated.connect(_on_node_tree_item_activated)
	node_tree.tree_item_gragged.connect(_on_node_tree_item_dragged)
	graph_edit.graph_edit_changed.connect(_on_graph_edit_changed)
	graph_edit.graph_edit_before_changed.connect(_on_graph_edit_before_changed)
	graph_edit.node_data_dropped.connect(_on_graph_edit_node_data_dropped)
	file_menu_button.get_popup().id_pressed.connect(_on_file_menu_id_pressed)

	new_quest_controller.quest_created.connect(_create_new_quest)
	new_quest_controller.save_file_selected.connect(_on_save_file_selected)

	open_quest_controller.open_file_selected.connect(_on_open_quest_controller_open_file_selected)
	open_quest_controller.save_file_selected.connect(_on_save_file_selected)

	save_dialog_controller.file_selected.connect(_on_save_file_selected)

	variable_tree.variables_updated.connect(_on_variable_tree_variables_updated)

	main_menu.undo.connect(_on_main_menu_undo)
	main_menu.redo.connect(_on_main_menu_redo)

	## Только после того как граф поменяет размер, загружаем дефолтный квест
	#graph_edit.resized.connect(_create_new_quest, CONNECT_ONE_SHOT)

	_create_new_quest()

	if not Engine.is_editor_hint():
		update_window()


func _on_main_menu_undo() -> void:
	if _edit_history_undo.is_empty():
		return

	_apply_from_history = true
	_edit_history_do.append(quest_data_controller.get_quest_data())
	quest_data_controller.apply_quest_data(_edit_history_undo.pop_back())
	main_menu.disable_undo_redo(_edit_history_undo.is_empty(), _edit_history_do.is_empty())
	_apply_from_history = false


func _on_main_menu_redo() -> void:
	if _edit_history_do.is_empty():
		return

	_apply_from_history = true
	_edit_history_undo.append(quest_data_controller.get_quest_data())
	quest_data_controller.apply_quest_data(_edit_history_do.pop_back())
	main_menu.disable_undo_redo(_edit_history_undo.is_empty(), _edit_history_do.is_empty())
	_apply_from_history = false


func _on_node_tree_item_activated(action: GDScript) -> void:
	var new_action: QuestAction = action.new(variable_tree.get_quest_variables(), variable_tree.get_references())
	graph_edit.add_node(new_action, '', graph_edit.get_new_node_position(graph_edit._node_default_position))


func _on_node_tree_item_dragged(action_class: GDScript) -> void:
	var preview_node: QuestEditorGraphNode = graph_edit.graph_node.instantiate()
	preview_node.action = action_class.new(variable_tree.get_quest_variables(), variable_tree.get_references())
	preview_node.set_scale(preview_node.get_scale() * graph_edit.zoom)
	set_drag_preview(preview_node)


func _on_graph_edit_before_changed() -> void:
	if _apply_from_history:
		return

	_edit_history_undo.append(quest_data_controller.get_quest_data())
	_edit_history_do.clear()
	main_menu.disable_undo_redo(_edit_history_undo.is_empty(), _edit_history_do.is_empty())


func _on_graph_edit_changed() -> void:
	quest_changed = true


func _on_graph_edit_node_data_dropped(at_position: Vector2, data: Variant) -> void:
	var new_action: QuestAction = data.new(variable_tree.get_quest_variables(), variable_tree.get_references())
	graph_edit.add_node(new_action, '', graph_edit.get_new_node_position(at_position))


func _on_file_menu_id_pressed(id: int) -> void:
	var quest_file_path: String = quest_data_controller.get_quest_file_path()
	var quest_name: String = quest_data_controller.get_quest_name()

	match id:
		0:
			new_quest_controller.initiate(quest_name, quest_file_path, quest_changed)
		1:
			open_quest_controller.initiate(quest_name, quest_file_path, quest_changed)
		2:
			save_dialog_controller.initiate(quest_name, quest_file_path)
		3:
			update_window()


func _create_new_quest() -> void:
	variable_tree.set_variables({})
	variable_tree.set_references([])
	graph_edit.clear()
	graph_edit.add_node(QuestActionLogicStart.new([], {}))
	quest_data_controller.quest_file_path = ''
	quest_changed = false
	_edit_history_undo.clear()
	_edit_history_do.clear()
	main_menu.disable_undo_redo(_edit_history_undo.is_empty(), _edit_history_do.is_empty())


func _on_open_quest_controller_open_file_selected(quest_file: String) -> void:
	quest_data_controller.load_quest_data(quest_file)
	quest_changed = false
	_edit_history_undo.clear()
	_edit_history_do.clear()
	main_menu.disable_undo_redo(_edit_history_undo.is_empty(), _edit_history_do.is_empty())


func _on_save_file_selected(file_path: String) -> void:
	quest_data_controller.save_quest_data(file_path)
	quest_changed = false


func _on_variable_tree_variables_updated() -> void:
	graph_edit.update_variables(variable_tree.get_quest_variables(), variable_tree.get_references())


func _update_quest_data_label() -> void:
	var quest_file_path: String = quest_data_controller.get_quest_file_path()
	if quest_file_path.is_empty():
		quest_file_path = 'New Quest'
	var saved_text: String = '' if not quest_changed else ' (*)'
	file_label.text = '%s%s' % [quest_file_path, saved_text]


func update_window() -> void:
	QuestSystem.update_action_class_list()
	node_tree.create_tree()
	_update_quest_data_label()
