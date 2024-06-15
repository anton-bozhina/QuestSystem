@tool
class_name QuestActionFunction
extends QuestAction


var folder_name: StringName = 'Functions'
var folder_position: int = -1

var node_color: Color = Color.DARK_GOLDENROD
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true


func _action_task(arguments: Arguments) -> void:
	_action_function(arguments)
	#if next_action:
		#next_action.perform()


func _action_function(_arguments: Arguments) -> void:
	pass


#func _step_function() -> void:
	#push_error('Not programmed "_step_function" in "%s" script!' % self.get_script().get_path())
#
#
#func _process(_delta: float) -> void:
	#if not active:
		#return
#
	#_step_function()
	#_activate_next_step()
	#active = false
#
#
#func _activate_next_step() -> void:
	#if connection:
		#connection.active = true
