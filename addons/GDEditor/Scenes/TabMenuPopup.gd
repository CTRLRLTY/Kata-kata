tool

extends PopupMenu

signal preview_dialogue
signal new_dialogue(dialogue_name)
signal save_dialogue


enum {
	MENU_PREVIEW_DIALOGUE,
	MENU_NEW_DIALOGUE,
	MENU_OPEN_DIALOGUE,
	MENU_OPEN_CHARACTER,
	MENU_SAVE_DIALOGUE,
	MENU_SAVE_DIALOGUE_AS,
	MENU_IMPORT_CHARACTER,
	MENU_EXPORT_CHARACTER
}


func _ready() -> void:
	# There exist a case where somehow an item 
	# is added multiple time. This is to prevent that.
	if get_item_count():
		clear()
	
	add_item("Preview", MENU_PREVIEW_DIALOGUE)
	add_separator("", -999)
	add_item("New Dialogue", MENU_NEW_DIALOGUE)
	add_item("Open Dialogue", MENU_OPEN_DIALOGUE)
	add_item("Open Character", MENU_OPEN_CHARACTER)
	add_separator("", -998)
	add_item("Save Dialogue", MENU_SAVE_DIALOGUE)
	add_item("Save Dialogue As", MENU_SAVE_DIALOGUE_AS)
	add_separator("", -997)
	add_item("Import Character", MENU_IMPORT_CHARACTER)
	add_item("Export Character", MENU_EXPORT_CHARACTER)
	

func _on_id_pressed(id: int) -> void:
	match id:
		MENU_PREVIEW_DIALOGUE:
			emit_signal("preview_dialogue")
		MENU_NEW_DIALOGUE:
			$DialogueNamePrompt.popup_centered()
		MENU_OPEN_CHARACTER:
			$CharacterDefinitionPopup.popup_centered()
		MENU_SAVE_DIALOGUE:
			emit_signal("save_dialogue")


func _on_DialogueNamePrompt_confirmed(dialogue_name) -> void:
	emit_signal("new_dialogue", dialogue_name)
