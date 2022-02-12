extends GDDialogueReader

class_name GDPipeReader


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GNPipe


func render(graph_node: GNPipe, dialogue_viewer: GDDialogueView) -> void:
	var data = get_node_data(graph_node)
	var node_connection := graph_node.get_connections()
	
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			pass
		GNPipe.PipeType.WAIT_FOR:
			pass
		GNPipe.PipeType.WAIT_TILL:
			pass


func get_node_data(graph_node: GNPipe):
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			return graph_node.find_node("ExpressionEdit").get_expression()
		GNPipe.PipeType.WAIT_FOR:
			pass
		GNPipe.PipeType.WAIT_TILL:
			pass
