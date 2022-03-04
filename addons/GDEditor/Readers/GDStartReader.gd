extends GDDialogueReader

class_name GDStartReader


func render(graph_node: GDGraphNode, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	cursor.next_flow()
	dialogue_viewer.next()
