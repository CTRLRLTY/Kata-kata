tool

extends PopupMenu

signal new_dialogue(dialogue_name)

enum {
	MENU_NEW_DIALOGUE,
	MENU_OPEN_DIALOGUE,
	MENU_OPEN_CHARACTER,
	MENU_SAVE_DIALOGUE,
	MENU_SAVE_DIALOGUE_AS,
	MENU_IMPORT_CHARACTER,
	MENU_EXPORT_CHARACTER
}


func _enter_tree() -> void:
	# Resetting the id space
	_next_seperator_id = 9999
	
	# There exist a case where somehow an item 
	# is added multiple time. This is to prevent that.
	if get_item_count():
		clear()
		
	add_item("New Dialogue", MENU_NEW_DIALOGUE)
	add_separator("", _generate_seperator_id())
	add_item("Open Dialogue", MENU_OPEN_DIALOGUE)
	add_item("Open Character", MENU_OPEN_CHARACTER)
	add_separator("", _generate_seperator_id())
	add_item("Save Dialogue", MENU_SAVE_DIALOGUE)
	add_item("Save Dialogue As", MENU_SAVE_DIALOGUE_AS)
	add_separator("", _generate_seperator_id())
	add_item("Import Character", MENU_IMPORT_CHARACTER)
	add_item("Export Character", MENU_EXPORT_CHARACTER)


# upperbound = 9999, lowerbound = 20
var _next_seperator_id
# Any new seperator has to be set with id returned from this method.
func _generate_seperator_id() -> int:
	assert(_next_seperator_id > 20)
	_next_seperator_id -= 1
	return _next_seperator_id
	

func _on_id_pressed(id: int) -> void:
	match id:
		MENU_NEW_DIALOGUE:
			$DialogueNamePrompt.popup_centered()
		MENU_OPEN_CHARACTER:
			$CharacterDefinitionPopup.popup_centered()


func _on_DialogueNamePrompt_confirmed(dialogue_name) -> void:
	emit_signal("new_dialogue", dialogue_name)
