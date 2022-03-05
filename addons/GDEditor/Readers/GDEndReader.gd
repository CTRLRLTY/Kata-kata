extends GDDialogueReader

class_name GDEndReader


func render(data, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	cursor.reset()
	dialogue_viewer.reset()
