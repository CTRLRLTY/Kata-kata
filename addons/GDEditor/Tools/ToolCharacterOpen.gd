tool

extends GDDialogueTool


onready var _character_definition := $CharacterDefinitionPopup
onready var _filter_edit := find_node("FilterEdit")


func _on_pressed() -> void:
	$CharacterDefinitionPopup.popup_centered()


func _on_CharacterDefinitionPopup_about_to_show() -> void:
	var dir := Directory.new()
	
	for character_data in get_dialogue_view().get_character_datas():
		_character_definition.add_item(character_data)
	
	# Wait till the last item is added
	yield(get_tree(), "idle_frame")
	
	_character_definition.filter_items(_filter_edit.text)


func _on_CharacterDefinitionPopup_popup_hide() -> void:
	var DIR := Directory.new()
	var characters_dir := GDUtil.get_characters_dir()
	var resource_name_filter := RegEx.new()
	resource_name_filter.compile("[:/\\\\?*\"|%<>]+")

	var stored_characters : Array = get_dialogue_view().get_character_datas()
	
	if not DIR.dir_exists(characters_dir):
		DIR.make_dir_recursive(characters_dir)
	
	for child in _character_definition.get_character_item_container().get_children():
		if "character_data" in child:
			var character_data : CharacterData = child.character_data
			
			var stored_idx := stored_characters.find(character_data)
			var fname : String = resource_name_filter.sub(character_data.character_name, "")
			var fpath : String = characters_dir + fname + ".tres"
			
			if stored_idx != -1:
				if fpath != character_data.resource_path:
					DIR.rename(character_data.resource_path, fname)
			
			ResourceSaver.save(characters_dir + 
					"%s.tres" % [fname], character_data)
			
		if "character_data" in child:
			child.queue_free()


func _on_CharacterDefinitionPopup_character_item_delete(character_item: Control) -> void:
	var DIR := Directory.new()
	var character_data : CharacterData = character_item.character_data
	
	if character_data:
		DIR.remove(character_data.resource_path)
		character_item.queue_free()
