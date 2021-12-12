tool

extends WindowDialog


func _on_CharacterItem_delete(character_item : Control) -> void:
	# Prevent duplicated connection error
	if not $ConfirmationDialog.is_connected("confirmed", character_item, "queue_free"):
		$ConfirmationDialog.connect("confirmed", 
				character_item, "queue_free", [], CONNECT_ONESHOT)
			
	$ConfirmationDialog.dialog_text = "Do you want to delete " +\
									  character_item.get_character_name()
	
	$ConfirmationDialog.popup_centered()
