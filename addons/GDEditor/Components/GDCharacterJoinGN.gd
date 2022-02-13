tool

extends GDGraphNode

class_name GDCharacterJoinGN

onready var _option_button := find_node("OptionButton")


func get_component_name() -> String:
	return "CharacterJoin"


func _on_OptionButton_pressed() -> void:
	_option_button.clear()
	
	var graph_editor : GDGraphEditor = get_dialogue_editor()\
			.get_graph_editor_container()\
			.get_active_editor()
	
	var dialogue_view : GDDialogueView = graph_editor.get_dialogue_preview()
	
	assert(dialogue_view.has_method("get_character_names"))
	
	for character_name in dialogue_view.get_character_names():
		_option_button.add_item(character_name)
