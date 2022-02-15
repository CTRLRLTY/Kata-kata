tool

extends GDGraphNode

class_name GDCharacterJoinGN


onready var _expand_btn := find_node("ExpandBtn")
onready var _character_selection := find_node("CharacterSelection")
onready var _expression_selection := find_node("ExpressionSelection")
onready var _vbox_expression := find_node("VBoxExpression")


func _ready() -> void:
	_vbox_expression.visible = not _expand_btn.pressed


func get_component_name() -> String:
	return "CharacterJoin"


func _on_CharacterSelection_pressed() -> void:
	var selected_character : CharacterData = _character_selection.get_selected_metadata()
	
	_character_selection.clear()
	
	var dialogue_view := get_dialogue_view()
	
	assert(dialogue_view.has_method("get_character_datas"))
	
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
	

func _on_ExpressionSelection_pressed() -> void:
	if _character_selection.selected == -1:
		return
		
	var character_data : CharacterData = _character_selection.get_selected_metadata()
	
	var selected_expression : CharacterExpressionData = _expression_selection.get_selected_metadata()
	
	_expression_selection.clear()
	
	for expression in character_data.character_expressions:
		assert(expression is CharacterExpressionData)
		
		var idx: int = _expression_selection.get_item_count()
		
		_expression_selection.add_item(expression.expression_name)
		_expression_selection.set_item_metadata(idx, expression)
		
		if expression == selected_expression:
			_expression_selection.select(idx)


func _on_CharacterSelection_item_selected(index: int) -> void:
	_expression_selection.clear()
