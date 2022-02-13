extends GDDialogueReader

class_name GDMessageReader


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GNMessage


func render(graph_node: GNMessage, dialogue_viewer: GDDialogueView, cursor: DialogueCursor) -> void:
	var message := get_node_data(graph_node)
	
	dialogue_viewer.set_text_box(message)
	
	cursor.next()


func get_node_data(graph_node: GNMessage) -> String:
	return graph_node.s_message
