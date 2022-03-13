tool

extends GDStandardGN

class_name GDMessageGN

export var message : String
# CharacterData
export var character : Resource = null
# CharacterExpressionData
export var expression : Resource = null

onready var _message_edit := find_node("MessageEdit")
onready var _character_selection := find_node("CharacterSelection")
onready var _expression_selection := find_node("ExpressionSelection")


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	_message_edit.text = message
	_character_selection.graph_node = self
	_expression_selection.graph_node = self
	
	if character:
		var index : int = _character_selection.get_item_count()
		_character_selection.add_item(character.character_name)
		_character_selection.set_item_metadata(index, character)
		_character_selection.select(index)

	if expression:
		var index : int = _expression_selection.get_item_count()
		_expression_selection.add_item(expression.expression_name)
		_expression_selection.set_item_metadata(index, expression)
		_expression_selection.select(index)


func get_save_data() -> Dictionary:
	return {
		"character": get_character_data(),
		"expression": get_expression_data(),
		"text": message
	}


func get_component_name() -> String:
	return "Message"


func get_character_selection() -> OptionButton:
	return _character_selection as OptionButton


func get_character_data() -> CharacterData:
	return _character_selection.get_selected_metadata()


func get_expression_data() -> CharacterExpressionData:
	return _expression_selection.get_selected_metadata()


func _on_CharacterSelection_item_selected(index: int) -> void:
	_expression_selection.select(0)
	character = _character_selection.get_selected_metadata()
	
	expression = null
	
	update_value()


func _on_CharacterSelection_selected_character_deleted() -> void:
	_character_selection.select(0)
	_expression_selection.select(0)
	
	character = null
	expression = null
	
	update_value()


func _on_ExpressionSelection_item_selected(index: int) -> void:
	expression = _expression_selection.get_selected_metadata()
	
	update_value()


func _on_MessageEdit_text_changed() -> void:
	message = _message_edit.text
	update_value()


func _on_EditBtn_toggled(button_pressed: bool) -> void:
	# Might be null when duplicated
	if not _message_edit:
		return
	
	_message_edit.visible = button_pressed
	_message_edit.grab_focus()
