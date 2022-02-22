extends GDDialogueReader

class_name GDEndReader


func render(graph_node, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	cursor.reset()
	dialogue_viewer.reset()
