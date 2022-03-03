tool

extends WindowDialog

var character_data : CharacterData
var selected_expression : Control 

onready var _expression_container := find_node("CharacterExpressionContainer")
onready var _state_tree := find_node("CharacterStateTree")
onready var _file_dialog := find_node("FileDialog")


func add_expression(expression_data : CharacterExpressionData) -> void:
	var character_expression = load(
			GDUtil.resolve("CharacterExpressionItem.tscn")).instance()
	
	character_expression.expression_data = expression_data
	
	character_expression.connect("focus_entered", 
			self, "_on_CharacterExpression_focus_entered", [character_expression])
	character_expression.connect("profile_pressed", _file_dialog, "popup_centered")
	
	_expression_container.add_child(character_expression)
	
	character_expression.grab_focus()


func _on_about_to_show() -> void:
	assert(character_data, 
			"character_data has to be supplied before shown")
	
	for character_expression in character_data.character_expressions:
		add_expression(character_expression)


func _on_popup_hide() -> void:
	for child in _expression_container.get_children():
		child.queue_free()


func _on_CharacterStateTree_state_changed() -> void:
	character_data.character_states = _state_tree.get_state_list()


func _on_AddExpressionBtn_pressed() -> void:
	var character_expression := CharacterExpressionData.new()
	add_expression(character_expression)
	character_data.character_expressions.append(character_expression)


func _on_DeleteExpressionBtn_pressed() -> void:
	if not selected_expression:
		if not _expression_container.get_child_count():
			return
			
		selected_expression = _expression_container.get_child(
				_expression_container.get_child_count()-1)
	
	character_data.character_expressions.erase(
				selected_expression.expression_data)
	
	selected_expression.queue_free()
	selected_expression = null


func _on_CharacterExpression_focus_entered(character_expression : Control) -> void:
	selected_expression = character_expression


func _on_FileDialog_file_selected(path: String) -> void:
	var texture_resource : Texture = load(path)
	
	if selected_expression:
		selected_expression.set_texture(texture_resource) 
		selected_expression.expression_data.expression_texture = texture_resource
