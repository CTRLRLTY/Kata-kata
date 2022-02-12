tool

extends PanelContainer

signal delete


var character_data : CharacterData

var _name_label : Label
var _delete_btn : Button
var _edit_btn : Button
var _profile_texture_rect : TextureRect
var _resource_name_filter : RegEx


func _enter_tree() -> void:
	_profile_texture_rect = find_node("CharacterProfileTextRect")
	_name_label = find_node("CharacterNameLabel")
	_delete_btn = find_node("DeleteBtn")
	_edit_btn = find_node("EditBtn")
	
	if not character_data:
		character_data = CharacterData.new()
		character_data.character_name = "Scr1pti3"
		character_data.profile_texture = load(GDUtil.resolve("icon.png"))
		character_data.resource_name = "scr1pti3"
		
	_name_label.text = character_data.character_name
	_profile_texture_rect.texture = character_data.profile_texture
		
	if not _resource_name_filter:
		_resource_name_filter = RegEx.new()
		_resource_name_filter.compile("[\\w ]+")

	find_node("NameEdit").text = _name_label.text


func save() -> void:
	var DIR := Directory.new()
	var characters_dir := GDUtil.get_characters_dir()
	
	if not DIR.dir_exists(characters_dir):
		DIR.make_dir_recursive(characters_dir)
		
	ResourceSaver.save(characters_dir + 
			"%s.tres" % [character_data.resource_name], character_data)


func _on_EditBtn_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		return
		
	var character_edit_dialog : WindowDialog = find_node("CharacterEditDialog")
	character_edit_dialog.window_title = character_data.character_name
	character_edit_dialog.rect_global_position = _edit_btn.rect_global_position		
	character_edit_dialog.character_data = character_data
	character_edit_dialog.popup()


func _on_CharacterEditDialog_popup_hide() -> void:
	_edit_btn.pressed = false


func _on_NameEdit_text_changed(new_text: String) -> void:
	_name_label.text = new_text
	
	var filtered_text = GDUtil.regex_filter(new_text, _resource_name_filter)
	character_data.resource_name = filtered_text.replace(" ", "_")
	character_data.character_name = new_text
	

func _on_DescriptionEdit_text_changed() -> void:
	var character_description_edit : TextEdit = get_node(
		"HBoxContainer/VBoxContainer/EditBtn/CharacterEditDialog/MarginContainer/HSplitContainer/VBoxContainer/GridContainer/DescriptionEdit")
	character_data.character_description = character_description_edit.text
	

func _on_DeleteBtn_pressed() -> void:
	emit_signal("delete")


func _on_CharacterProfileTextRect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.button_index == BUTTON_LEFT:
			return
		
		if not event.doubleclick:
			return
			
		find_node("ProfileFileDialog").popup_centered()


func _on_ProfileFileDialog_file_selected(path: String) -> void:
	_profile_texture_rect.texture = load(path)
