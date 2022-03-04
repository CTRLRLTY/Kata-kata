tool

extends GDDialogueReader

class_name GDChoiceReader


func render(graph_node: GDChoiceGN, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var choices : PoolStringArray = graph_node.s_choices
	
	dialogue_viewer.show_choices(choices)
	dialogue_viewer.block_next(true)
	
	var port : int = yield(dialogue_viewer, "choice_selected")
	
	dialogue_viewer.block_next(false)
	dialogue_viewer.clear_choices()
	
	cursor.skip_flow(port)
