extends GDDialogueReader

class_name GDMessageReader


func render(graph_node: GDMessageGN, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var message := read(graph_node)
	
	dialogue_viewer.set_text_box(message)
	
	if dialogue_viewer.has_method("show_character") and \
	   dialogue_viewer.has_method("has_character_join") \
	:
		var character_data := graph_node.get_character_data()
		var expression_data := graph_node.get_expression_data()
		
		if dialogue_viewer.has_character_join(character_data):
			dialogue_viewer.show_character(character_data, expression_data)
	
	cursor.nextf()


func read(graph_node: GDMessageGN) -> String:
	return graph_node.s_message
