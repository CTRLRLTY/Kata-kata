extends Reference

class_name GDDialogueReader


func can_handle(graph_node) -> bool:
	return false


func render(graph_node, dialogue_viewer, cursor: DialogueCursor) -> void:
	pass


func get_node_data(graph_node):
	pass
