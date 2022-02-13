extends GDDialogueReader

class_name GDMessageReader


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GDMessageGN


func render(graph_node: GDMessageGN, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var message := read(graph_node)
	
	dialogue_viewer.set_text_box(message)
	
	cursor.next()


func read(graph_node: GDMessageGN) -> String:
	return graph_node.s_message
