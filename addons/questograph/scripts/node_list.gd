@tool
@icon('../icons/node_list.svg')
class_name QuestographNodeList
extends Resource
## Class responsible for storing and providing access to registered nodes.
##
## Nodes from the list will be displayed in the Editor and used in the system of scripts launching.


## List of Nodes used in the Editor
@export var nodes: Array[QuestographNodeSettings]:
	set(value):
		nodes = value
		for index in nodes.size():
			if not nodes[index] is QuestographNodeSettings:
				nodes[index] = QuestographNodeSettings.new()


func get_nodes() -> Array[QuestographNodeSettings]:
	return nodes


func get_ids() -> Dictionary:
	var result: Dictionary = {}
	for node in nodes as Array[QuestographNodeSettings]:
		result[node.id] = node
	return result


func get_scripts() -> Dictionary:
	var result: Dictionary = {}
	for node in nodes as Array[QuestographNodeSettings]:
		result[node.file] = node
	return result
