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
		
	_update_value_inputnode(type_option.get_selected_id())


func _update_value_inputnode(state_type : int, is_array := false) -> void:
	if not is_array:
		value_array.hide()
		
		match state_type:
			ContextStateData.TYPE_STRING:
				value_edit.show()
				value_check.hide()
				value_edit.text = ""
				
			ContextStateData.TYPE_BOOL:
				value_edit.hide()
				value_check.show()
				value_check.pressed = false
				
			_:
				value_edit.show()
				value_check.hide()
				value_edit.text = "0"
	else:
		value_edit.hide()
		value_check.hide()
		value_array.show()
	

func _on_TypeOption_item_selected(index: int) -> void:
	state_data.state_type = type_option.get_item_id(index)
	_update_value_inputnode(state_data.state_type, array_check.pressed)


func _on_ArrayCheck_toggled(button_pressed: bool) -> void:
	_update_value_inputnode(state_data.state_type, button_pressed)
	array_size.editable = button_pressed


func _on_ArraySize_value_changed(value: float) -> void:
	array_dialog.resize(value)


func _on_ValueEdit_focus_exited() -> void:
	match state_data.state_type:
		ContextStateData.TYPE_INT:
			if not value_edit.text.is_valid_integer():
				value_edit.text = "0"
				
		ContextStateData.TYPE_FLOAT:
			if not value_edit.text.is_valid_float():
				value_edit.text = "0"

	state_data.state_value = value_edit.text


func _on_ValueCheck_toggled(button_pressed: bool) -> void:
	if button_pressed:
		state_data.state_value = "1"
	else:
		state_data.state_value = ""


func _on_ValueArray_pressed() -> void:
	array_dialog.popup_centered()


func _on_CancelBtn_pressed() -> void:
	hide()


func _on_ConfirmBtn_pressed() -> void:
	hide()
	emit_signal("confirmed")
