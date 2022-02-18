tool

extends OptionButton

signal character_selected_left

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

	if graph_node.get_dialogue_view():
		graph_node.get_dialogue_view().connect("character_left", self, "_on_character_left")
		graph_node.get_dialogue_view().connect("character_renamed", self, "_on_character_renamed")


func _on_pressed() -> void:
	var selected_character : CharacterData = graph_node.get_character_selection().get_selected_metadata()
	
	graph_node.get_character_selection().clear()
	
	for character_data in graph_node.get_dialogue_view().get_joined_characters():
		assert(character_data is CharacterData)
		
		var idx : int = graph_node.get_character_selection().get_item_count()
		
		graph_node.get_character_selection().add_item(character_data.character_name)
		graph_node.get_character_selection().set_item_metadata(idx, character_data)
		
		if character_data == selected_character:
			graph_node.get_character_selection().select(idx)


func _on_character_renamed(character_data: CharacterData) -> void:
	var idx : int = graph_node.get_character_selection().selected
	
	if idx != -1:
		var selected_character : CharacterData = graph_node.get_character_selection().get_selected_metadata()
		
		if character_data == selected_character:
			graph_node.get_character_selection().set_item_text(idx, character_data.character_name)


func _on_character_left(left_character: CharacterData) -> void:
	for idx in range(graph_node.get_character_selection().get_item_count()):
		var character_data : CharacterData = graph_node.get_character_selection().get_item_metadata(idx)
		
		if left_character == character_data:
			if character_data == graph_node.get_character_selection().get_selected_metadata():
				graph_node.get_character_selection().clear()
				emit_signal("character_selected_left")
			else:
				graph_node.get_character_selection().remove_item(idx)
			
			return
