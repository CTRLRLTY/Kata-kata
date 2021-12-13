tool

extends PanelContainer

signal delete

var name_label : Label
var delete_btn : Button
var edit_btn : Button
var profile_texture_rect : TextureRect
var character_data : CharacterData


func _enter_tree() -> void:
	profile_texture_rect = find_node("CharacterProfileTextRect")
	name_label = find_node("CharacterNameLabel")
	delete_btn = find_node("DeleteBtn")
	edit_btn = find_node("EditBtn")
	
	if not character_data:
		character_data = CharacterData.new()

	find_node("NameEdit").text = get_character_name()


func get_character_name() -> String:
	return name_label.text
	
	
func get_profile_texture() -> Texture:
	return profile_texture_rect.texture
	

func _on_EditBtn_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		return
		
	var character_edit_dialog : WindowDialog = find_node("CharacterEditDialog")
	character_edit_dialog.window_title = get_character_name()
	character_edit_dialog.rect_global_position = edit_btn.rect_global_position		
	character_edit_dialog.popup()


func _on_CharacterEditDialog_popup_hide() -> void:
	edit_btn.pressed = false


func _on_NameEdit_text_entered(new_text: String) -> void:
	name_label.text = new_text
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
	profile_texture_rect.texture = load(path)


func _on_CharacterEditDialog_expression_removed(expression_data : CharacterExpressionData) -> void:
	character_data.character_expressions.erase(expression_data)


func _on_CharacterEditDialog_expression_added(expression_data : CharacterExpressionData) -> void:
	character_data.character_expressions.append(expression_data)
