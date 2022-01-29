extends Reference

class_name GDDialogueReader


func can_handle(graph_node: GDGraphNode) -> bool:
	return false


func render(graph_node: GDGraphNode, dialogue_viewer: GDDialogueView) -> void:
	pass


func get_node_data(graph_node: GDGraphNode):
	pass
