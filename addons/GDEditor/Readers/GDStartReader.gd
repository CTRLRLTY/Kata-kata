tool

extends GDDialogueReader

class_name GDStartReader


func render(data, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	cursor.next(0)
	dialogue_viewer.next()
