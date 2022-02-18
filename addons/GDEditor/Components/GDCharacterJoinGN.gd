tool

extends GDGraphNode

class_name GDCharacterJoinGN


enum CharacterPosition {
	LEFT,
	RIGHT
}

var _previous_selected_character : CharacterData


onready var _position_btn := find_node("PositionBtn")
onready var _expand_btn := find_node("ExpandBtn")
onready var _character_selection := find_node("CharacterSelection")
onready var _expression_selection := find_node("ExpressionSelection")
onready var _vbox_expression := find_node("VBoxExpression")


func _ready() -> void:
	_vbox_expression.visible = not _expand_btn.pressed
	_character_selection.graph_node = self
	_expression_selection.graph_node = self
	
	if get_dialogue_view():
		get_dialogue_view().connect("character_deleted", self, "_on_character_deleted")
		get_dialogue_view().connect("character_renamed", self, "_on_character_renamed")


func get_component_name() -> String:
	return "Character Join"


func get_character_data() -> CharacterData:
	return _character_selection.get_selected_metadata()


func get_expression_data() -> CharacterExpressionData:
	return _expression_selection.get_selected_metadata()


func get_character_position() -> int:
	return _position_btn.pressed as int


func get_character_selection() -> OptionButton:
	return _character_selection as OptionButton


func connect_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	if graph_node is GDMessageGN:
		if not get_character_data():
			return false
		
		get_dialogue_view().character_join(get_character_data(), self)
		
		return true
	
	return false


func disconnect_to(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	get_dialogue_view().character_left(get_character_data(), self)
	
	return true


func _on_ExpandBtn_toggled(button_pressed: bool) -> void:
	_vbox_expression.visible = not button_pressed


func _on_VBoxExpression_visibility_changed() -> void:
	yield(get_tree(), "idle_frame")
	rect_size = Vector2.ZERO


func _on_CharacterSelection_pressed() -> void:
	if _character_selection.selected != -1:
		_previous_selected_character = _character_selection.get_selected_metadata()


func _on_CharacterSelection_item_selected(index: int) -> void:
	if is_connection_connected_output(0):
		get_dialogue_view().character_left(_previous_selected_character, self)
		get_dialogue_view().character_join(get_character_data(), self)
	
	_expression_selection.clear()


func _on_CharacterSelection_selected_character_deleted() -> void:
	_character_selection.clear()
	_expression_selection.clear()
	disconnect_output(0)
