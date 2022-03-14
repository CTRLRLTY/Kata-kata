tool

extends GDDialogueReader

class_name GDStartReader


func render(data, dialogue_viewer, cursor: GDDialogueCursor) -> void:
#	cursor.next(0)
#	dialogue_viewer.next()
	cursor.forward(0)
