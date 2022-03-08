tool

extends GDDialogueReader

class_name GDEmitterReader


func render(event_name : String, dialogue_viewer, cursor: GDDialogueCursor) -> void:
	Gaelog.emit_signal("event", event_name)
	
	cursor.skip(0)
