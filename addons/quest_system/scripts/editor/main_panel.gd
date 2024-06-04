@tool
class_name QuestEditor
extends MarginContainer

const QUEST_CLASS_PARENT = 'QuestAction'

@export var node_tree: QuestEditorNodeTree
@export var graph_edit: QuestEditorGraphEdit
@export var variable_tree: QuestEditVariableTree
@export var open_quest_action: QuestEditorOpenQuestAction
@export var save_quest_action: QuestEditorSaveQuestAction
@export var new_quest_action: QuestEditorNewQuestAction


var quest_changed: bool = false


func _ready() -> void:
	node_tree.tree_item_activated.connect(_on_node_tree_item_activated)
	graph_edit.open_button_pressed.connect(_on_graph_edit_open_button_pressed)
	graph_edit.save_button_pressed.connect(_on_graph_edit_save_button_pressed)
	graph_edit.new_button_pressed.connect(_on_graph_edit_new_button_pressed)
	graph_edit.graph_edit_changed.connect(_on_graph_edit_changed)
	# Фикс положения новой ноды, нода создается раньше, чем изменится размер граф эдита
	graph_edit.resized.connect(_on_new_quest_action_quest_created.bind(QuestData.new()), CONNECT_ONE_SHOT)
	variable_tree.variables_updated.connect(_on_variable_tree_variables_updated)
	open_quest_action.quest_selected.connect(_on_open_quest_action_quest_selected)
	save_quest_action.quest_saved.connect(_on_save_quest_action_quest_saved)
	new_quest_action.quest_created.connect(_on_new_quest_action_quest_created)

	update_lists()


func _on_graph_edit_new_button_pressed() -> void:
	new_quest_action.initiate(graph_edit.active_quest_data)


func _on_graph_edit_open_button_pressed() -> void:
	open_quest_action.initiate(graph_edit.active_quest_data)


func _on_graph_edit_save_button_pressed() -> void:
	graph_edit.save_to_active_quest_data()
	variable_tree.save_variables()
	save_quest_action.initiate(graph_edit.active_quest_data)


func _on_open_quest_action_quest_selected(quest_data: QuestData) -> void:
	graph_edit.active_quest_data = quest_data
	graph_edit.load_from_active_quest_data()
	variable_tree.load_variables(quest_data.quest_variables)


func _on_save_quest_action_quest_saved() -> void:
	graph_edit.active_quest_data.changes_not_saved = false
	graph_edit.update_quest_data_label()


func _on_graph_edit_changed() -> void:
	graph_edit.active_quest_data.changes_not_saved = true
	graph_edit.update_quest_data_label()


func _on_new_quest_action_quest_created(quest_data: QuestData) -> void:
	graph_edit.active_quest_data = quest_data
	graph_edit.load_from_active_quest_data()
	variable_tree.load_variables(quest_data.quest_variables)


func _on_node_tree_item_activated(action: QuestAction) -> void:
	graph_edit.add_node(action.get_script().new())


func _on_variable_tree_variables_updated(variables: Dictionary) -> void:
	if graph_edit.active_quest_data.quest_variables.hash() != variables.hash():
		graph_edit.active_quest_data.quest_variables = variables
		graph_edit.graph_edit_changed.emit()


func update_lists() -> void:
	node_tree.create_tree(QUEST_CLASS_PARENT)
