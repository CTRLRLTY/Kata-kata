tool

extends GDGraphNode

class_name GDCharacterLeftGN


onready var _character_selection : OptionButton = find_node("CharacterSelection")


func _ready() -> void:
	_character_selection.graph_node = self


func get_component_name() -> String:
	return "Character Left"


func get_character_selection() -> OptionButton:
	return _character_selection


func _on_CharacterSelection_character_selected_left() -> void:
	disconnect_input(0)
