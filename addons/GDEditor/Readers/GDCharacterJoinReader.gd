extends GDDialogueReader

class_name GDCharacterJoinReader


func render(graph_node: GDCharacterJoinGN, dialogue_view: GDDialogueView, cursor: GDDialogueCursor) -> void:
	if dialogue_view.has_method("set_character_left_texture") and \
	   dialogue_view.has_method("set_character_right_texture") \
	:
		var expression_data := graph_node.get_expression_data()
		
		if expression_data:
			var position : String = graph_node.CharacterPosition.keys()[graph_node.get_character_position()].to_lower()
			
			dialogue_view.call("set_character_%s_texture" % [position], 
					expression_data.expression_texture, graph_node.s_character_offset)
