tool

extends WindowDialog

signal confirmed

var type_option : OptionButton
var value_edit : LineEdit
var value_check : CheckBox

var state_data : ContextStateData


func _enter_tree() -> void:
	type_option = find_node("TypeOption")
	value_edit = find_node("ValueEdit")
	value_check = find_node("ValueCheck")
	
	if not state_data:
		state_data = ContextStateData.new()
	

func _on_TypeOption_item_selected(index: int) -> void:
	state_data.state_type = type_option.get_item_id(index)
	match state_data.state_type:
		ContextStateData.TYPE_STRING:
			value_edit.show()
			value_check.hide()
			value_edit.text = ""
			state_data.state_value = value_edit.text
			
		ContextStateData.TYPE_BOOL:
			value_edit.hide()
			value_check.show()
			value_check.pressed = false
			state_data.state_value = ""
			
		ContextStateData.TYPE_INT:
			value_edit.show()
			value_check.hide()
			value_edit.text = "0"
			state_data.state_value = value_edit.text
			
		ContextStateData.TYPE_FLOAT:
			value_edit.show()
			value_check.hide()
			value_edit.text = "0"
			state_data.state_value = value_edit.text


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


func _on_CancelBtn_pressed() -> void:
	hide()


func _on_ConfirmBtn_pressed() -> void:
	hide()
	emit_signal("confirmed")

