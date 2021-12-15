tool

extends WindowDialog

signal confirmed

var type_option : OptionButton
var array_check : CheckBox
var array_size : SpinBox
var array_dialog : WindowDialog
var value_edit : LineEdit
var value_check : CheckBox
var value_array : Button

var state_data : ContextStateData

var _edit_filter := RegEx.new()


func _enter_tree() -> void:
	type_option = find_node("TypeOption")
	
	value_edit = find_node("ValueEdit")
	value_check = find_node("ValueCheck")
	value_array = find_node("ValueArray")
	
	array_check = find_node("ArrayCheck")
	array_size = find_node("ArraySize")
	array_dialog = value_array.get_node("ValueArrayDialog")

	
	if not state_data:
		state_data = ContextStateData.new()
	
	
	value_edit.connect("focus_exited", self, "_on_ValueEdit_focus_exited", [value_edit])
	
	_update_value_inputnode(type_option.get_selected_id())
	

func _exit_tree() -> void:
	value_edit.disconnect("focus_exited", self, "_on_ValueEdit_focus_exited")


func _update_value_inputnode(state_type : int, is_array := false) -> void:
	match state_type:
		ContextStateData.TYPE_BOOL:
			value_edit.hide()
			value_check.show()
			value_array.hide()
			
			value_check.pressed = false
			array_check.disabled = true
			array_check.pressed = false
			
		ContextStateData.TYPE_STRING:
			value_edit.text = ""
			_edit_filter.compile(".*")
			continue
			
		ContextStateData.TYPE_INT:
			value_edit.text = "0"
			_edit_filter.compile("[-]?\\d+")
			continue
			
		ContextStateData.TYPE_FLOAT:
			value_edit.text = "0.0"
			_edit_filter.compile("[-]?\\d*\\.?\\d+")
			continue
		_:
			array_check.disabled = false
			
			if array_check.pressed:
				value_edit.hide()
				value_check.hide()
				value_array.show()
			else:
				value_array.hide()
				value_edit.show()
				value_check.hide()


func _on_TypeOption_item_selected(index: int) -> void:
	state_data.state_type = type_option.get_item_id(index)
	array_size.value = array_size.min_value
	array_dialog.clear()
	
	_update_value_inputnode(state_data.state_type, array_check.pressed)


func _on_ArrayCheck_toggled(button_pressed: bool) -> void:
	_update_value_inputnode(state_data.state_type, button_pressed)
	array_size.editable = button_pressed


func _on_ArraySize_value_changed(value: float) -> void:
	array_dialog.resize(value)


func _on_ValueEdit_focus_exited(edit : LineEdit) -> void:
	match state_data.state_type:
		ContextStateData.TYPE_INT:
			GDUtil.filter_edit(_edit_filter, edit, "0")
		ContextStateData.TYPE_FLOAT:
			GDUtil.filter_edit(_edit_filter, edit, "0.0")


func _on_ValueArray_pressed() -> void:
	array_dialog.popup_centered()
	

func _on_CancelBtn_pressed() -> void:
	hide()


func _on_ConfirmBtn_pressed() -> void:
	hide()
	
	if array_check.pressed:
		state_data.state_value = array_dialog.value_list
	else:
		match state_data.state_type:
			ContextStateData.TYPE_STRING:
				state_data.state_value = [value_edit.text]
			ContextStateData.TYPE_INT:
				state_data.state_value = [int(value_edit.text)]
			ContextStateData.TYPE_FLOAT:
				state_data.state_value = [float(value_edit.text)]
			ContextStateData.TYPE_BOOL:
				state_data.state_value = [value_check.pressed]
		
	print_debug(state_data.state_value)
	emit_signal("confirmed")
