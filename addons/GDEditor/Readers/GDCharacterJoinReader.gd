tool

extends GDDialogueReader

class_name GDCharacterJoinReader


func render(data: Dictionary, dialogue_view: GDDialogueView, cursor: GDDialogueCursor) -> void:
	if dialogue_view.has_method("character_rjoin") and \
	   dialogue_view.has_method("show_character") \
	:
		dialogue_view.character_rjoin(data.character, data.position, data.offset)

		if data.expression:
			dialogue_view.show_character(data.character, data.expression)

#	cursor.next(0)
#	dialogue_view.next()
	cursor.forward(0)
