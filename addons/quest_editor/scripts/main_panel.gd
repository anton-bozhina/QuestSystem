@tool
class_name QuestEditor
extends MarginContainer

const QUEST_CLASS_PARENT = 'QuestAction'

@export var node_tree: QuestEditorNodeTree
@export var graph_edit: QuestEditorGraphEdit
@export var variable_tree: QuestEditVariableTree
@export var file_label: Label
#@export var new_button: Button
#@export var open_button: Button
#@export var save_button: Button
@export var file_menu_button: MenuButton
@export var quest_data_controller: QuestEditorQuestDataController
@export var open_quest_controller: QuestEditorOpenQuestController
@export var save_dialog_controller: QuestEditorSaveDialogController
@export var new_quest_controller: QuestEditorNewQuestController


var quest_changed: bool = false :
	set(value):
		quest_changed = value
		update_quest_data_label()


func _ready() -> void:
	node_tree.tree_item_activated.connect(_on_node_tree_item_activated)
	graph_edit.graph_edit_changed.connect(_on_graph_edit_changed)
	file_menu_button.get_popup().id_pressed.connect(_on_file_menu_id_pressed)

	new_quest_controller.quest_created.connect(_create_new_quest)
	new_quest_controller.save_file_selected.connect(_on_save_file_selected)

	open_quest_controller.open_file_selected.connect(_on_open_quest_controller_open_file_selected)
	open_quest_controller.save_file_selected.connect(_on_save_file_selected)

	save_dialog_controller.file_selected.connect(_on_save_file_selected)

	variable_tree.variables_updated.connect(_on_variable_tree_variables_updated)

	node_tree.create_tree()
	update_quest_data_label()

	# Только после того как граф поменяет размер, загружаем дефолтный квест
	graph_edit.resized.connect(_create_new_quest, CONNECT_ONE_SHOT)


func _on_node_tree_item_activated(action: GDScript) -> void:
	var new_action: QuestAction = action.new(variable_tree.get_variables())
	graph_edit.add_node(new_action)


func _on_graph_edit_changed() -> void:
	quest_changed = true


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
			node_tree.create_tree()


func _create_new_quest() -> void:
	var varibles: QuestVariables = QuestVariables.new()
	variable_tree.set_variables(varibles)
	graph_edit.clear()
	graph_edit.add_node(QuestActionLogicStart.new(varibles))
	quest_data_controller.quest_file_path = ''
	quest_changed = false


func _on_open_quest_controller_open_file_selected(quest_file: String) -> void:
	quest_data_controller.load_quest_data(quest_file)
	quest_changed = false


func _on_save_file_selected(file_path: String) -> void:
	quest_data_controller.save_quest_data(file_path)
	quest_changed = false


func _on_variable_tree_variables_updated(variables: QuestVariables) -> void:
	graph_edit.update_variables(variables)


func update_quest_data_label() -> void:
	var quest_file_path: String = quest_data_controller.get_quest_file_path()
	if quest_file_path.is_empty():
		quest_file_path = 'New Quest'
	var saved_text: String = '' if not quest_changed else ' (*)'
	file_label.text = '%s%s' % [quest_file_path, saved_text]
