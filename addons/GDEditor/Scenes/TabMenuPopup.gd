tool

extends PopupMenu

signal preview_dialogue
signal new_dialogue(dialogue_name)
signal save_dialogue


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
#			emit_signal("open_dialogue")
			pass


func _preview_visible() -> bool:
	var dialogue_editor : GDDialogueEditor = GDUtil.get_dialogue_editor()
	var graph_editor_container := dialogue_editor.get_graph_editor_container()
	var graph_editor := graph_editor_container.get_active_editor()
	
	return graph_editor.get_dialogue_preview().visible


func _on_DialogueNamePrompt_confirmed(dialogue_name) -> void:
	emit_signal("new_dialogue", dialogue_name)


func _on_about_to_show() -> void:
	if _preview_visible():
		set_item_text(MENU_PREVIEW_DIALOGUE, "Preview [on]")
	else:
		set_item_text(MENU_PREVIEW_DIALOGUE, "Preview [off]")
