@tool
extends OptionButton

var hint_string: String : set = set_hint_string
var selected_text: String : set = set_selected_text, get = get_selected_text


func set_hint_string(value: String) -> void:
	var enum_items = value.split(',', false)
	for index in range(enum_items.size()):
		var item_id: Array = enum_items[index].split(':')
		if item_id.size() == 1:
			item_id.append(-1)
		add_item(item_id[0], int(item_id[1]))


func set_selected_text(value: String) -> void:
	for id in range(item_count):
		if get_item_text(id) == value:
			select(id)
			return
	select(-1)


func get_selected_text() -> String:
	return get_item_text(get_selected_id())
