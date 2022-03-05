extends GDDialogueReader

class_name GDStartReader


func render(data, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	cursor.skip_flow()
