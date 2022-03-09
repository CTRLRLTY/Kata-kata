tool

extends GDGraphNode

class_name GDCharacterJoinGN


enum CharacterPosition {
	LEFT,
	RIGHT
}


export var s_character_offset := 0

onready var _position_btn := find_node("PositionBtn")
onready var _expand_btn := find_node("ExpandBtn")
onready var _character_selection := find_node("CharacterSelection")
onready var _expression_selection := find_node("ExpressionSelection")
onready var _vbox_expression := find_node("VBoxExpression")


func _ready() -> void:
	if get_dialogue_view():
		if get_dialogue_view().get_class() == "GDStandardView":
			find_node("OffsetBtn").hide()
	
	_vbox_expression.visible = not _expand_btn.pressed
	_character_selection.graph_node = self
	_expression_selection.graph_node = self


func get_component_name() -> String:
	return "Character Join"


func get_save_data() -> Dictionary:
	return {
		"character": get_character_data(),
		"expression": get_expression_data(),
		"position": get_character_position_string(),
		"offset": s_character_offset
	}


func get_character_data() -> CharacterData:
	return _character_selection.get_selected_metadata()


func get_expression_data() -> CharacterExpressionData:
	return _expression_selection.get_selected_metadata()


func get_character_position() -> int:
	return _position_btn.pressed as int


func get_character_position_string() -> String:
	return CharacterPosition.keys()[get_character_position()].to_lower()


func get_character_selection() -> OptionButton:
	return _character_selection as OptionButton


func _connection_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return get_character_data() != null


func _on_ExpandBtn_toggled(button_pressed: bool) -> void:
	_vbox_expression.visible = not button_pressed


func _on_VBoxExpression_visibility_changed() -> void:
	yield(get_tree(), "idle_frame")
	rect_size = Vector2.ZERO


func _on_CharacterSelection_item_selected(index: int) -> void:
	_expression_selection.select(0)
	
	update_value()


func _on_CharacterSelection_selected_character_deleted() -> void:
	_character_selection.select(0)
	_expression_selection.select(0)
	port_map().right_disconnect(name, 0)
	
	update_value()


func _on_ExpressionSelection_item_selected(index: int) -> void:
	update_value()


func _on_OffsetBtn_selected(idx: int) -> void:
	s_character_offset = idx
	update_value()


func _on_PositionBtn_pressed() -> void:
	update_value()
