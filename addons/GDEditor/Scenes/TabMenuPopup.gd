tool

extends PopupMenu

signal preview_dialogue
signal new_dialogue(dialogue_name)
signal save_dialogue
signal open_dialogue(dialogue_path)


enum {
	MENU_PREVIEW_DIALOGUE,
	MENU_NEW_DIALOGUE,
	MENU_OPEN_DIALOGUE,
	MENU_SAVE_DIALOGUE,
	MENU_SAVE_DIALOGUE_AS,
}


func _ready() -> void:
	# There exist a case where somehow an item 
	# is added multiple time. This is to prevent that.
	if get_item_count():
		clear()
	
	add_item("Preview [off]", MENU_PREVIEW_DIALOGUE)
	add_separator("", -999)
	add_item("New Dialogue", MENU_NEW_DIALOGUE)
	add_item("Open Dialogue", MENU_OPEN_DIALOGUE)
	add_separator("", -998)
	add_item("Save Dialogue", MENU_SAVE_DIALOGUE)
	add_item("Save Dialogue As", MENU_SAVE_DIALOGUE_AS)


func _on_id_pressed(id: int) -> void:
	match id:
		MENU_PREVIEW_DIALOGUE:
			emit_signal("preview_dialogue")
		MENU_NEW_DIALOGUE:
			$DialogueNamePrompt.popup_centered()
		MENU_SAVE_DIALOGUE:
			emit_signal("save_dialogue")
		MENU_OPEN_DIALOGUE:
			$DialogueQuickOpen.popup_dialog("PackedScene", GDutil.get_save_dir())


func _on_DialogueNamePrompt_confirmed(dialogue_name) -> void:
	emit_signal("new_dialogue", dialogue_name)


func _on_DialogueQuickOpen_confirmed() -> void:
	var file_name = $DialogueQuickOpen.get_selected()
	
	GDutil.print([self, " DialogueQuickOpen Selected: %s" % file_name], GDutil.PR_INFO, 2)
	
	if not file_name.empty():
		var file_path : String = "res://" + file_name
		
		GDutil.print([self, " open " + file_path], GDutil.PR_INFO, 3)
		
		emit_signal('open_dialogue', file_path)

