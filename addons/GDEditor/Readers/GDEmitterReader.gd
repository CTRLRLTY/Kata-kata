tool

extends GDDialogueReader

class_name GDEmitterReader


func render(event_name : String, dialogue_viewer, cursor: GDDialogueCursor) -> void:
	dialogue_viewer.emit_signal(event_name)
	
	cursor.next(0)
	dialogue_viewer.next()
