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


func _on_character_deleted(deleted_data: CharacterData) -> void:
	for idx in range(_character_selection.get_item_count()):
		var character_data : CharacterData = _character_selection.get_item_metadata(idx)

		if deleted_data == character_data:
			if character_data == _character_selection.get_selected_metadata():
				_character_selection.clear()
				_expression_selection.clear()
				disconnect_output(0)
			else:
				_character_selection.remove_item(idx)

			get_dialogue_view().character_left(character_data, self)
			return
	
	
func _on_character_renamed(character_data: CharacterData) -> void:
	var idx : int = _character_selection.selected
	
	if idx != -1:
		var selected_character : CharacterData = _character_selection.get_selected_metadata()
		
		if character_data == selected_character:
			_character_selection.set_item_text(idx, character_data.character_name)


func _on_CharacterSelection_pressed() -> void:
	var selected_character : CharacterData = _character_selection.get_selected_metadata()

	_previous_selected_character = selected_character
	
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
	if is_connection_connected_output(0):
		get_dialogue_view().character_left(_previous_selected_character, self)
		get_dialogue_view().character_join(get_character_data(), self)
	
	_expression_selection.clear()
