tool

extends PanelContainer

signal delete


var character_data : CharacterData

var _character_data_dirty : CharacterData
var _resource_name_filter : RegEx

onready var _name_label : Label =  find_node("CharacterNameLabel")
onready var _delete_btn : Button = find_node("DeleteBtn")
onready var _edit_btn : Button = find_node("EditBtn")
onready var _profile_texture_rect : TextureRect = find_node("CharacterProfileTextRect")


func _ready() -> void:
	_character_data_dirty = character_data.duplicate()
	_resource_name_filter = RegEx.new()
	_resource_name_filter.compile("[:/\\\\?*\"|%<>]+")

	_name_label.text = character_data.character_name
	_profile_texture_rect.texture = character_data.profile_texture

	find_node("NameEdit").text = _name_label.text


func save() -> void:
	var DIR := Directory.new()
	var characters_dir := GDUtil.get_characters_dir()
	
	if not DIR.dir_exists(characters_dir):
		DIR.make_dir_recursive(characters_dir)
		
	var filename_old : String = _resource_name_filter.sub(character_data.character_name, "")
	var filename_new : String = _resource_name_filter.sub(_character_data_dirty.character_name, "")
	var filepath_old : String = characters_dir + filename_old + ".tres"
	var filepath_new : String = characters_dir + filename_new + ".tres"
	
	if DIR.file_exists(filepath_old):
		DIR.rename(filepath_old, filepath_new)
	
	character_data = _character_data_dirty
		
	ResourceSaver.save(characters_dir + 
			"%s.tres" % [filename_new], character_data)
	
	_character_data_dirty = character_data.duplicate()


func delete() -> void:
	var DIR := Directory.new()
	
	var filepath : String = GDUtil.get_characters_dir() + \
			_resource_name_filter.sub(character_data.character_name, "") + ".tres"
			
	DIR.remove(filepath)
	
	queue_free()


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
	
#	var filtered_text = GDUtil.regex_filter(new_text, _resource_name_filter)
	_character_data_dirty.character_name = new_text
	

func _on_DescriptionEdit_text_changed() -> void:
	var character_description_edit : TextEdit = get_node(
		"HBoxContainer/VBoxContainer/EditBtn/CharacterEditDialog/MarginContainer/HSplitContainer/VBoxContainer/GridContainer/DescriptionEdit")
	_character_data_dirty.character_description = character_description_edit.text


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
