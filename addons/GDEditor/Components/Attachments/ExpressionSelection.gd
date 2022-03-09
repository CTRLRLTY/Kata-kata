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
	
	if get_item_count() == 0:
		add_item("None")


func _on_pressed() -> void:
	var selected_expression : CharacterExpressionData = get_selected_metadata()
	
	clear()
	
	add_item("None")
	
	var character_data : CharacterData = graph_node.get_character_data()
	
	if character_data:
		for expression in character_data.character_expressions:
			assert(expression is CharacterExpressionData)
			
			var idx: int = get_item_count()
			
			add_item(expression.expression_name)
			set_item_metadata(idx, expression)
			
			if expression == selected_expression:
				select(idx)
