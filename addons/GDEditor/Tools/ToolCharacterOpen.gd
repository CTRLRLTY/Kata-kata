tool

extends TextureButton



func _on_pressed() -> void:
	$CharacterDefinitionPopup.popup_centered()
