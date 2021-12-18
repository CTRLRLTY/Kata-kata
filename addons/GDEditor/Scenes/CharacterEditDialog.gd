tool

extends WindowDialog

var expression_container : Container
var selected_expression : Control
var state_tree : Tree
var file_dialog : FileDialog

var character_data : CharacterData


func _enter_tree() -> void:
	expression_container = find_node("CharacterExpressionContainer")
	file_dialog = find_node("FileDialog")
	state_tree = find_node("CharacterStateTree")


func _on_about_to_show() -> void:
	assert(character_data, 
			"character_data has to be supplied before shown")


func _on_CharacterStateTree_state_changed() -> void:
#	pass
	character_data.character_states = state_tree.get_state_list()


func _on_AddExpressionBtn_pressed() -> void:
	var character_expression = load(
			GDUtil.resolve("CharacterExpressionItem.tscn")).instance()
	
	character_expression.connect("focus_entered", 
			self, "_on_CharacterExpression_focus_entered", [character_expression])
	character_expression.connect("profile_pressed", file_dialog, "popup_centered")
	
	expression_container.add_child(character_expression)
	character_data.character_expressions.append(character_expression.expression_data)
	
	character_expression.grab_focus()


func _on_DeleteExpressionBtn_pressed() -> void:
	if not selected_expression:
		if not expression_container.get_child_count():
			return
			
		selected_expression = expression_container.get_child(
				expression_container.get_child_count()-1)
	
	character_data.character_expressions.erase(
				selected_expression.expression_data)
	
	selected_expression.queue_free()
	selected_expression = null


func _on_CharacterExpression_focus_entered(character_expression : Control) -> void:
	selected_expression = character_expression


func _on_FileDialog_file_selected(path: String) -> void:
	var texture_resource : Texture = load(path)
	
	if selected_expression:
		selected_expression.expression_texture_rect.texture = texture_resource
		selected_expression.expression_data.expression_texture = texture_resource



