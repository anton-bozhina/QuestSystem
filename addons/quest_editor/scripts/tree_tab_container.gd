@tool
extends TabContainer


const TAB_TITLES: PackedStringArray = [
	'Local Variables',
	'Global Variables',
	'Tab_%d'
]


func _ready() -> void:
	_rename_tabs()


func _rename_tabs() -> void:
	for tab_idx in range(get_tab_count()):
		if TAB_TITLES.size() - 1 > tab_idx:
			set_tab_title(tab_idx, TAB_TITLES[tab_idx])
		else:
			set_tab_title(tab_idx, TAB_TITLES[TAB_TITLES.size() - 1] % (tab_idx + 1))
