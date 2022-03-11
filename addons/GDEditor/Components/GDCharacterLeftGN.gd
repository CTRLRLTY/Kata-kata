tool

extends GDGraphNode

class_name GDCharacterLeftGN

export var character : Resource = null


onready var _character_selection : OptionButton = find_node("CharacterSelection")


func _ready() -> void:
	_character_selection.graph_node = self


func connection_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	if _character_selection.selected == -1:
		return false
	
	return true


func get_component_name() -> String:
	return "Character Left"


func get_save_data() -> CharacterData:
	return get_character_data()


func get_character_selection() -> OptionButton:
	return _character_selection


func get_character_data() -> CharacterData:
	return _character_selection.get_selected_metadata()


func _on_CharacterSelection_selected_character_deleted() -> void:
	character = null
	port_map().right_disconnect(name, 0)
