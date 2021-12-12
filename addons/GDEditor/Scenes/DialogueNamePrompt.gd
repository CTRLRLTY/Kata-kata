tool

extends WindowDialog

signal confirmed(dialogue_name)


func _enter_tree() -> void:
	get_close_button().visible = false


func _on_CancelBtn_pressed() -> void:
	hide()


func _on_ConfirmBtn_pressed() -> void:
	if $NameEdit.text.empty():
		emit_signal("confirmed", "[empty]")
	else:
		emit_signal("confirmed", $NameEdit.text)
		
	$NameEdit.text = ""
		
	hide()
