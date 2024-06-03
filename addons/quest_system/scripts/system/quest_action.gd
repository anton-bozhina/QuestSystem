class_name QuestAction
extends RefCounted

var name: StringName = 'Action'
var node_caption: String = ''
var ignore: bool = false


var tree: SceneTree : set = set_tree, get = get_tree


func get_tree() -> SceneTree:
	return tree


func set_tree(value: SceneTree) -> void:
	tree = value

func _init() -> void:
	ignore = true


class Arguments:
	var _properties: Dictionary = {}

	func _get(property: StringName) -> Variant:
		return _properties.get(property)

	func _set(property: StringName, value: Variant) -> bool:
		_properties[property] = value
		return true


func _get_arguments() -> Arguments:
	return Arguments.new()


func _action_task(_arguments: Arguments) -> void:
	pass


func perform() -> void:
	pass
	#get_tree().process_frame.connect(_action_task.bind(_get_arguments()), CONNECT_ONE_SHOT)


#@export var active: bool = false : set = set_active
#
#
#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_DISABLED
	#
#
#
#
#func set_active(value: bool) -> void:
	#if value:
		#process_mode = Node.PROCESS_MODE_INHERIT
	#else:
		#process_mode = Node.PROCESS_MODE_DISABLED
#
	#active = value


#get_tree().process_frame.connect(callable, CONNECT_ONE_SHOT)
