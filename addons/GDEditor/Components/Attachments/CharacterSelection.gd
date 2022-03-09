tool

extends OptionButton

signal selected_character_deleted

var graph_node : GDGraphNode


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	if not is_connected("pressed", self, "_on_pressed"):
		connect("pressed", self, "_on_pressed")
	
	# Force the rest of the _ready() code to be executed on idle_frame
	yield(get_tree(), "idle_frame")
	
	assert(graph_node, "graph_node has to be assigned externally on _ready")

	if graph_node.get_dialogue_view():
		graph_node.get_dialogue_view().connect("character_deleted", self, "_on_character_deleted")
		graph_node.get_dialogue_view().connect("character_renamed", self, "_on_character_renamed")
	
	
	if get_item_count() == 0:
		add_item("None")


func _on_character_deleted(deleted_data: CharacterData) -> void:
	var select_idx : int = selected
	
	for idx in range(get_item_count()):
		var character_data : CharacterData = get_item_metadata(idx)
		
		if deleted_data == character_data:
			if character_data == get_selected_metadata():
				clear()
				emit_signal("selected_character_deleted")
			else:
				remove_item(idx)
				
				# For some reason, Godot won't decrement OptionButton selected index if we remove
				# an item that is removed_index < selected_index. This can cause get_selected_metadata
				# to raise an "out of bound" error, so this code will decrement the index manually.
				if idx < select_idx:
					select_idx -= 1
					select(select_idx)
			
			return


func _on_character_renamed(character_data: CharacterData) -> void:
	var idx : int = selected
	
	if idx != -1:
		var selected_character : CharacterData = get_selected_metadata()
		
		if character_data == selected_character:
			set_item_text(idx, character_data.character_name)


func _on_pressed() -> void:
	var selected_character : CharacterData 
	
	selected_character = get_selected_metadata()
	
	clear()
	
	add_item("None")
	
	var dialogue_view := graph_node.get_dialogue_view()
	
	assert(dialogue_view.has_method("get_character_datas"))
	
	var acc := get_item_count()
	
	for character_data in dialogue_view.get_character_datas():
		add_item(character_data.character_name)
		set_item_metadata(acc, character_data)
		
		if character_data == selected_character:
			select(acc)
		
		acc += 1
		
