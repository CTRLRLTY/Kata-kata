extends GDDialogueReader

class_name GDCharacterLeftReader


func render(graph_node: GDCharacterLeftGN, dialogue_view: GDDialogueView, cursor: GDDialogueCursor) -> void:
	if dialogue_view.has_method("character_rleft"):
		dialogue_view.character_rleft(graph_node.get_character_data())
