tool

extends WindowDialog

signal character_item_delete(character_item)

onready var _character_item_container := find_node("CharacterItemContainer")


func get_character_item_container() -> Control:
	return _character_item_container as Control


func filter_items(filter: String) -> void:
	# Filter out non matching items inside character item container
	for child in _character_item_container.get_children():
		# Auto hide non CharacterItems node
		var target_name := ""
		
		if "character_data" in child:
			assert(child.character_data is CharacterData)
			target_name = child.character_data.character_name

		child.visible = filter.is_subsequence_ofi(target_name)


func add_item(character_data := CharacterData.new()) -> void:
	var character_item : Control = load(GDutil.get_scene_dir() +
										"CharacterItem.tscn").instance()
	var character_names := []
	
	for child in _character_item_container.get_children():
		if "character_data" in child:
			character_names.append(child.character_data.character_name)
	
	var name_suffix := ""
	var acc := 0
	
	while character_names.has(character_data.character_name + name_suffix):
		name_suffix = "_%d" % [acc]
		acc += 1
	
	character_data.character_name += name_suffix
	
	character_item.connect("delete", 
			self, "_on_CharacterItem_delete", 
			[character_item])
	character_item.connect("name_changed", self, "_on_CharacterItem_name_changed", [character_item])

	character_item.character_data = character_data
			
	_character_item_container.add_child(character_item)


func _on_CharacterItem_delete(character_item: Control) -> void:
	# Prevent duplicated connection error
	if not $ConfirmationDialog.is_connected("confirmed", character_item, "delete"):
		$ConfirmationDialog.connect("confirmed", 
				self, "emit_signal", ["character_item_delete", character_item], CONNECT_ONESHOT)
			
	$ConfirmationDialog.dialog_text = "Do you want to delete " +\
									  character_item.character_data.character_name
	
	$ConfirmationDialog.popup_centered()


func _on_CharacterItem_name_changed(character_item: Control) -> void:
	var character_names := []
	var character_data : CharacterData = character_item.character_data
	
	for child in _character_item_container.get_children():
		if child == character_item:
			continue
		
		if "character_data" in child:
			character_names.append(child.character_data.character_name)
	
	var name_suffix := ""
	var acc := 0
	
	while character_names.has(character_data.character_name + name_suffix):
		name_suffix = "_%d" % [acc]
		acc += 1
	
	character_data.character_name += name_suffix
	character_item.get_name_label().text = character_data.character_name


func _on_FilterEdit_text_changed(new_text: String) -> void:
	filter_items(new_text)


func _on_AddCharacterBtn_pressed() -> void:
	add_item()

