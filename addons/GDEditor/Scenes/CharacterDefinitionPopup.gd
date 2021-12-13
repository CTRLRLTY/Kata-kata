tool

extends WindowDialog

var character_item_container : Control


func _enter_tree() -> void:
	character_item_container = find_node("CharacterItemContainer")


func _on_CharacterItem_delete(character_item : Control) -> void:
	# Prevent duplicated connection error
	if not $ConfirmationDialog.is_connected("confirmed", character_item, "queue_free"):
		$ConfirmationDialog.connect("confirmed", 
				character_item, "queue_free", [], CONNECT_ONESHOT)
			
	$ConfirmationDialog.dialog_text = "Do you want to delete " +\
									  character_item.get_character_name()
	
	$ConfirmationDialog.popup_centered()


func _on_AddCharacterBtn_pressed() -> void:
	var character_item : Control = load(GDUtil.get_scene_dir() +
										"CharacterItem.tscn").instance()

	character_item.connect("delete", 
			self, "_on_CharacterItem_delete", 
			[character_item])
			
	character_item_container.add_child(character_item)

	# Reorder AddCharacterBtn to last position
	character_item_container.move_child(
			find_node("AddCharacterBtn"), 
			character_item_container.get_child_count()-1)


func _on_FilterEdit_text_changed(new_text: String) -> void:
	# Filter out non matching items inside character item container
	for child in character_item_container.get_children():
		# Auto hide non CharacterItems node
		var target_name := ""
		
		if child.has_method("get_character_name"):
			target_name = child.get_character_name()

		child.visible = new_text.is_subsequence_ofi(target_name)
