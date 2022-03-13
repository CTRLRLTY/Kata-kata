tool

extends GDDialogueReader

class_name GDChoiceReader


func render(choices : PoolStringArray, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	dialogue_viewer.show_choices(choices)
	dialogue_viewer.block_next(true)
	
	var port : int = yield(dialogue_viewer, "choice_selected")
	
	dialogue_viewer.block_next(false)
	dialogue_viewer.clear_choices()
	
#	cursor.next(port)
#	dialogue_viewer.next()
	cursor.forward(port)
