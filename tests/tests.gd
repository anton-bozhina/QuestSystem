extends Node


var total_tests: int = 0
var total_passed: int = 0
var node_test: int = 0


func _ready() -> void:
	print_rich('[color=white]Testing is started! Test count: %d[/color]' % get_child_count())
	for child in get_children() as Array[TestsTest]:
		if not child is TestsTest:
			continue

		node_test = 0
		child.tested.connect(_check_print)
		print_rich('[color=yellow]%s testing has begun![/color]' % child.name)
		child._tests()
		child.tested.disconnect(_check_print)

	print_rich('[color=white]Testing is ended! Test cases passed: %d/%d[/color]' % [total_passed, total_tests])


func _check_print(conditions: bool, message: String) -> void:
	node_test += 1
	total_tests += 1
	if conditions:
		total_passed += 1
		print_rich('Test %02d [color=cyan][Line %d][/color] [color=orange]%s[/color] [color=green]passed![/color]' % [node_test, get_stack()[1].line, message])
	else:
		print_rich('Test %02d [color=cyan][Line %d][/color] [color=orange]%s[/color] [color=red]failed![/color]' % [node_test, get_stack()[1].line, message])
