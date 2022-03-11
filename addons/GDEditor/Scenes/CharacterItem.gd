tool

extends PanelContainer

signal delete
signal name_changed


var character_data : CharacterData

onready var _name_label : Label =  find_node("CharacterNameLabel")
onready var _name_edit : LineEdit = find_node("NameEdit")
onready var _description_edit : TextEdit = find_node("DescriptionEdit")
onready var _delete_btn : Button = find_node("DeleteBtn")
onready var _edit_btn : Button = find_node("EditBtn")
onready var _profile_texture_rect : TextureRect = find_node("CharacterProfileTextRect")


func _ready() -> void:
	_name_label.text = character_data.character_name
	_profile_texture_rect.texture = character_data.profile_texture

	find_node("NameEdit").text = _name_label.text


func get_name_label() -> Label:
	return _name_label


func _on_EditBtn_toggled(button_pressed: bool) -> void:
	if not button_pressed:
		return
		
	var character_edit_dialog : WindowDialog = find_node("CharacterEditDialog")
	character_edit_dialog.window_title = character_data.character_name
	character_edit_dialog.rect_global_position = _edit_btn.rect_global_position		
	character_edit_dialog.character_data = character_data
	character_edit_dialog.popup()


func _on_CharacterEditDialog_about_to_show() -> void:
	_name_edit.text = _name_label.text
	

func _on_CharacterEditDialog_popup_hide() -> void:
	_edit_btn.pressed = false
	character_data.character_name = _name_edit.text
	emit_signal("name_changed")


func _on_DescriptionEdit_text_changed() -> void:
	character_data.character_description = _description_edit.text


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
