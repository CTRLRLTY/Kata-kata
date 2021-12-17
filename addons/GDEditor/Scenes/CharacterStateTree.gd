tool

extends Tree

signal state_edited
signal state_deleted(state)

const ITEM_SUFFIX_SEPERATOR = "="

var state_popup : PopupMenu
var state_dialog : WindowDialog

var state_list : Array
 

func _enter_tree() -> void:
	state_popup = $CharacterStatePopup
	state_dialog = $CharacterStateDialog
	
	if not state_list:
		state_list = []
		
	if not get_root():
		var root := create_item()
		root.set_selectable(0, false)
		root.disable_folding = true
		root.set_text(0, "Character Properties")
		root.add_button(0, GDUtil.get_icon("Add"))


func _get_state(item : TreeItem) -> CharacterStateData:
	return item.get_metadata(0)
	

func _has_state_name(state_name : String) -> bool:
	for state in state_list:
		if state.state_name == state_name:
			return true
			
	return false


func _on_button_pressed(item: TreeItem, column: int, id: int) -> void:
	var DEFAULT_NAME = "new_variable"
	
	# Add new state
	if item == get_root():
		var new_item = create_item(get_root())
			
		new_item.set_text(0, DEFAULT_NAME)
		
		var state = CharacterStateData.new()
		state.state_name = DEFAULT_NAME
		
		new_item.set_suffix(0, "%s Null" % [ITEM_SUFFIX_SEPERATOR])
		new_item.set_metadata(0, state)
		new_item.set_editable(0, true)
		
		state_list.append(state)


func _on_item_edited() -> void:
	var edited := get_edited()
	
	# TODO: show a warning popup instead of a print.
	if not edited.get_text(0).is_valid_identifier():
		print_debug("state_name has to be a valid identifier")
		return
	
	var state := _get_state(edited)
	var old_name = state.state_name
	var state_name := edited.get_text(0)
	
	state.state_name = ""
	
	# TODO: show a warning popup instead of a print
	if _has_state_name(state_name):
		print_debug("Name: '%s' is already in used" % [state_name])
		state_name = old_name
	
	state.state_name = state_name

	edited.set_text(0, state_name)


func _on_item_rmb_selected(position: Vector2) -> void:
	state_popup.set_position(rect_global_position + position)
	state_popup.set_size(Vector2.ZERO)
	state_popup.popup()


func _on_StatePopup_delete_selected() -> void:
	emit_signal("state_deleted", _get_state(get_selected()))
	state_list.erase(_get_state(get_selected()))
	get_selected().free()


func _on_StatePopup_state_edited() -> void:
	state_dialog.popup_centered()


func _on_CharacterStateDialog_confirmed() -> void:
	_get_state(get_selected()).state_value = state_dialog.state_data.state_value
	
	for state in state_list:
		print_debug(state.state_value)
	
	get_selected().set_suffix(0, 
			"%s %s" % [ITEM_SUFFIX_SEPERATOR, str(state_dialog.state_data.state_value)])
