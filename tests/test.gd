class_name TestsTest
extends Node


signal tested(result: bool, message: String)


func _tests() -> void:
	tested.emit(false, 'is test list empty')
