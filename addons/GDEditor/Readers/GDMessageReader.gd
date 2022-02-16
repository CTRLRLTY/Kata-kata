extends GDDialogueReader

class_name GDMessageReader


func render(graph_node: GDMessageGN, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var message := read(graph_node)
	
	dialogue_viewer.set_text_box(message)
	
	cursor.next()


func read(graph_node: GDMessageGN) -> String:
	return graph_node.s_message
