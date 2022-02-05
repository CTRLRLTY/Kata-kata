tool

extends WindowDialog

onready var character_item_container := find_node("CharacterItemContainer")
onready var _filter_edit := find_node("FilterEdit")


func _add_item(character_data: CharacterData = null) -> void:
	var character_item : Control = load(GDUtil.get_scene_dir() +
										"CharacterItem.tscn").instance()

	character_item.connect("delete", 
			self, "_on_CharacterItem_delete", 
			[character_item])
	
	character_item.character_data = character_data
			
	character_item_container.add_child(character_item)

	# Reorder AddCharacterBtn to last position
	character_item_container.move_child(
			find_node("AddCharacterBtn"), 
			character_item_container.get_child_count()-1)


func _filter_items(filter: String) -> void:
	# Filter out non matching items inside character item container
	for child in character_item_container.get_children():
		# Auto hide non CharacterItems node
		var target_name := ""
		
		if "character_data" in child:
			assert(child.character_data is CharacterData)
			target_name = child.character_data.character_name

		child.visible = filter.is_subsequence_ofi(target_name)


func _on_CharacterItem_delete(character_item : Control) -> void:
	# Prevent duplicated connection error
	if not $ConfirmationDialog.is_connected("confirmed", character_item, "queue_free"):
		$ConfirmationDialog.connect("confirmed", 
				character_item, "queue_free", [], CONNECT_ONESHOT)
			
	$ConfirmationDialog.dialog_text = "Do you want to delete " +\
									  character_item.character_data.character_name
	
	$ConfirmationDialog.popup_centered()


func _on_AddCharacterBtn_pressed() -> void:
	_add_item()


func _on_FilterEdit_text_changed(new_text: String) -> void:
	_filter_items(new_text)


func _on_about_to_show() -> void:
	var dir := Directory.new()
	
	if dir.dir_exists(GDUtil.get_characters_dir()):
		dir.open(GDUtil.get_characters_dir())
		dir.list_dir_begin(true, true)
		
		var file_name := dir.get_next()
		
		while not file_name.empty():
			var character_data : CharacterData = load(GDUtil.get_characters_dir() + file_name)
			_add_item(character_data)
			
			file_name = dir.get_next()
			
		dir.list_dir_end()
	
		# Wait till the last item is added
		yield(get_tree(), "idle_frame")
	
	_filter_items(_filter_edit.text)


func _on_popup_hide() -> void:
	for child in character_item_container.get_children():
		if "character_data" in child:
			child.queue_free()
