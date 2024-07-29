@tool
class_name QuestActionWaitTime
extends QuestActionWait


static var node_name = 'WaitTime'

# Тут есть проблема, надо сохранять подобные переменные при сохранении квеста из сцены. Но надо по другому реализовывать таймеры.
@export var wait_time: float

var timer: SceneTreeTimer


func _perform_wait() -> void:
	timer = Engine.get_main_loop().create_timer(wait_time, false)
	timer.timeout.connect(_on_time_waited)


func _on_time_waited() -> void:
	waited.emit()


func _get_action_data() -> Dictionary:
	return {
		'time_left': timer.time_left if timer else wait_time
	}


func _set_action_data(data: Dictionary) -> void:
	wait_time = data.get('time_left', wait_time)
