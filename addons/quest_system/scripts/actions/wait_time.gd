@tool
class_name QuestActionWaitTime
extends QuestActionWait


static var node_name = 'WaitTime'

@export var wait_time: float


func _perform_wait() -> void:
	Engine.get_main_loop().create_timer(wait_time, false).timeout.connect(_on_time_waited)


func _on_time_waited() -> void:
	waited.emit()
