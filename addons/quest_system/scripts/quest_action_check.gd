@tool
class_name QuestActionCheck
extends QuestAction

const CONDITIONS = [
	'==',
	'!=',
	'>',
	'>=',
	'<=',
	'<'
]

var folder_name: StringName = 'Checks'
var folder_position: int = -1

var node_color: Color = Color.DARK_OLIVE_GREEN
var node_show_left_slot: bool = true
var node_show_right_slot: bool = true
