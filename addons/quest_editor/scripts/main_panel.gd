@tool
class_name QuestEditor
extends MarginContainer

const QUEST_CLASS_PARENT = 'QuestAction'

@export var quest_data: QuestData
@export var node_tree: QuestEditorNodeTree
@export var graph_edit: QuestEditorGraphEdit
@export var variable_tree: QuestEditVariableTree
@export var file_label: Label
@export var new_button: Button
@export var open_button: Button
@export var save_button: Button
@export var quest_data_controller: QuestEditorQuestDataController
@export var open_quest_controller: QuestEditorOpenQuestController
@export var save_quest_controller: QuestEditorSaveQuestController
@export var new_quest_controller: QuestEditorNewQuestController

var quest_changed: bool = false :
	set(value):
		quest_changed = value
		update_quest_data_label()


func _ready() -> void:
	node_tree.tree_item_activated.connect(_on_node_tree_item_activated)
	graph_edit.graph_edit_changed.connect(_on_graph_edit_changed)
	# Фикс положения новой ноды, нода создается раньше, чем изменится размер граф эдита
	graph_edit.resized.connect(_on_new_quest_controller_quest_created.bind(QuestData.new()), CONNECT_ONE_SHOT)
	variable_tree.variables_updated.connect(_on_variable_tree_variables_updated)
	open_quest_controller.quest_selected.connect(_on_open_quest_controller_quest_selected)
	save_quest_controller.quest_saved.connect(_on_save_quest_controller_quest_saved)
	new_quest_controller.quest_created.connect(_on_new_quest_controller_quest_created)

	new_button.pressed.connect(_on_file_menu_id_pressed.bind(0))
	open_button.pressed.connect(_on_file_menu_id_pressed.bind(1))
	save_button.pressed.connect(_on_file_menu_id_pressed.bind(2))

	update_lists()
	update_quest_data_label()


func update_quest_data_label() -> void:
	var quest_data_path: String = quest_data.get_path() if quest_data and not quest_data.get_path().is_empty() else 'Not Saved'
	var saved_text: String = '' if quest_data and not quest_changed else ' (*)'
	file_label.text = 'Quest: %s%s' % [quest_data_path, saved_text]


func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0:
			_new_quest_controller_initiate()
		1:
			_open_quest_controller_initiate()
		2:
			_save_quest_controller_initiate()


func _new_quest_controller_initiate() -> void:
	new_quest_controller.initiate(quest_data, quest_changed)


func _open_quest_controller_initiate() -> void:
	open_quest_controller.initiate(quest_data, quest_changed)


func _save_quest_controller_initiate() -> void:
	quest_data_controller.editor_data_to_quest_data(graph_edit, quest_data)
	variable_tree.save_variables()
	save_quest_controller.initiate(quest_data)


func _on_open_quest_controller_quest_selected(new_quest_data: QuestData) -> void:
	quest_data = new_quest_data
	quest_data_controller.quest_data_to_editor_data(graph_edit, quest_data)
	variable_tree.load_variables(quest_data.quest_variables)
	quest_changed = false


func _on_save_quest_controller_quest_saved() -> void:
	quest_changed = false


func _on_graph_edit_changed() -> void:
	quest_changed = true


func _on_new_quest_controller_quest_created(new_quest_data: QuestData) -> void:
	quest_data = new_quest_data
	quest_data_controller.quest_data_to_editor_data(graph_edit, QuestData.new())
	variable_tree.load_variables(quest_data.quest_variables)
	quest_changed = false


func _on_node_tree_item_activated(action: QuestAction) -> void:
	var new_action: QuestAction = action.get_script().new()
	new_action.set_variables(quest_data.quest_variables)
	graph_edit.add_node(new_action)


func _on_variable_tree_variables_updated(variables: Dictionary) -> void:
	if quest_data.quest_variables.hash() == variables.hash():
		return
	quest_data.quest_variables = variables
	graph_edit.update_variables(variables)


func update_lists() -> void:
	node_tree.create_tree(QUEST_CLASS_PARENT)
