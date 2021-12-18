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
	
	
	if not value_edit.is_connected("focus_exited", self, "_on_ValueEdit_focus_exited"):
		value_edit.connect("focus_exited", self, "_on_ValueEdit_focus_exited", [value_edit])
	

func _update_value_inputnode(state_type : int, value = null) -> void:
	match state_type:
		ContextStateData.TYPE_BOOL:
			value_edit.hide()
			value_check.show()
			value_array.hide()
			
			value_check.pressed = value if value else false
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
			if value != null:
				value_edit.text = str(value)
		
			array_check.disabled = false
			
			if array_check.pressed:
				value_edit.hide()
				value_check.hide()
				value_array.show()
			else:
				value_array.hide()
				value_edit.show()
				value_check.hide()


func open(p_state_data : ContextStateData) -> void:
	state_data = p_state_data.duplicate()
	
	# is state_value a vector
	if state_data.state_value.size() > 1:
		array_check.pressed = true
		array_dialog.set_value_list(state_data.state_value)
		array_size.value = state_data.state_value.size()
		
	elif not state_data:
		_update_value_inputnode(state_data.state_type, state_data.state_value[0])
	
	popup_centered()


func _on_popup_hide() -> void:
	# Reset every input
	array_size.value = 1
	array_dialog.clear()
	array_check.pressed = false
	type_option.select(state_data.TYPE_STRING)
	value_check.pressed = false
	value_edit.text = ""

	state_data = null

func _on_TypeOption_item_selected(index: int) -> void:
	state_data.state_type = type_option.get_item_id(index)
	array_size.value = array_size.min_value
	array_dialog.clear()
	
	_update_value_inputnode(state_data.state_type)


func _on_ArrayCheck_toggled(button_pressed: bool) -> void:
	_update_value_inputnode(state_data.state_type)
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
	if array_check.pressed:
		state_data.state_value = array_dialog.get_value_list()
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

	emit_signal("confirmed")
	hide()
