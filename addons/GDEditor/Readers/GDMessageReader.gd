extends GDDialogueReader

class_name GDMessageReader


func render(data, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	dialogue_viewer.set_text_box(data.text)
	
	if dialogue_viewer.has_method("show_character") and \
	   dialogue_viewer.has_method("has_character_join") \
	:	
		if dialogue_viewer.has_character_join(data.character):
			dialogue_viewer.show_character(data.character, data.expression)
	
	cursor.next_flow()
