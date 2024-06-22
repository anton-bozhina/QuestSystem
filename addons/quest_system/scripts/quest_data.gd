class_name QuestData
extends Resource

@export var name: String
@export_multiline var description: String
@export var variables: Dictionary = {}
@export_group('Actions')
@export var start_action: StringName
@export var actions: Dictionary = {}
