extends GDDialogueReader

class_name GDEmitterReader

func render(graph_node, dialogue_viewer, cursor: GDDialogueCursor) -> void:
	var signal_name := read(graph_node)
	
	Gaelog.emit_signal("event", signal_name)
	
	
	cursor.skip_flow()


func read(graph_node) -> String:
	return graph_node.s_event_name
