extends GDDialogueReader

class_name GDCharacterJoinReader


func render(graph_node: GDCharacterJoinGN, dialogue_view: GDDialogueView, cursor: GDDialogueCursor) -> void:
	if dialogue_view.has_method("character_rjoin") and \
	   dialogue_view.has_method("show_character") \
	:
		var expression_data := graph_node.get_expression_data()
		var character_data := graph_node.get_character_data()
		
		dialogue_view.character_rjoin(graph_node)
		
		if expression_data:
			dialogue_view.show_character(character_data, expression_data)
