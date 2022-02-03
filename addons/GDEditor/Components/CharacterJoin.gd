tool

extends GDGraphNode

class_name GNCharacterJoin

onready var _option_button := find_node("OptionButton")


func get_component_name() -> String:
	return "CharacterJoin"


func _on_OptionButton_pressed() -> void:
	_option_button.clear()
	
	for character_name in get_dialogue_editor().get_character_names():
		_option_button.add_item(character_name)
