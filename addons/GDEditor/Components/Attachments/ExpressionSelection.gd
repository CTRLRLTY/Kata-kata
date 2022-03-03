tool

extends OptionButton

var graph_node : GDGraphNode


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	if not is_connected("pressed", self, "_on_pressed"):
		connect("pressed", self, "_on_pressed")
	
	# Force the rest of the _ready() code to be executed on idle_frame
	yield(get_tree(), "idle_frame")
	
	assert(graph_node, "graph_node has to be assigned externally on _ready")
	assert(graph_node.has_method("get_character_selection"), "graph_node has to implement get_character_selection")


func _on_pressed() -> void:
	if graph_node.get_character_selection().selected == -1:
		return
		
	var character_data : CharacterData = graph_node.get_character_selection().get_selected_metadata()
	
	var selected_expression : CharacterExpressionData = get_selected_metadata()
	
	clear()
	
	if character_data:
		for expression in character_data.character_expressions:
			assert(expression is CharacterExpressionData)
			
			var idx: int = get_item_count()
			
			add_item(expression.expression_name)
			set_item_metadata(idx, expression)
			
			if expression == selected_expression:
				select(idx)
