tool

extends GDGraphNode

class_name GDCharacterJoinGN


onready var _expand_btn := find_node("ExpandBtn")
onready var _character_selection := find_node("CharacterSelection")
onready var _vbox_expression := find_node("VBoxExpression")


func _ready() -> void:
	_vbox_expression.visible = not _expand_btn.pressed


func get_component_name() -> String:
	return "CharacterJoin"


func _on_OptionButton_pressed() -> void:
	var selected_id : int =  _character_selection.selected
	var selected_character : CharacterData
	
	if selected_id != -1:
		_character_selection.get_item_text(selected_id)
		selected_character = _character_selection.get_item_metadata(selected_id)

	_character_selection.clear()
	
	var graph_editor : GDGraphEditor = get_dialogue_editor()\
			.get_graph_editor_container()\
			.get_active_editor()
	
	var dialogue_view : GDDialogueView = graph_editor.get_dialogue_preview()
	
	assert(dialogue_view.has_method("get_character_names"))
	
	var acc := 0
	for character_data in dialogue_view.get_character_datas():
		_character_selection.add_item(character_data.character_name)
		_character_selection.set_item_metadata(acc, character_data)
		
		if character_data == selected_character:
			_character_selection.select(acc)
		
		acc += 1


func _on_ExpandBtn_toggled(button_pressed: bool) -> void:
	_vbox_expression.visible = not button_pressed


func _on_VBoxExpression_visibility_changed() -> void:
	yield(get_tree(), "idle_frame")
	rect_size = Vector2.ZERO
