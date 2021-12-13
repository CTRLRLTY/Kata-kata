tool

extends WindowDialog

# carries the removed expression_data
signal expression_removed(expression_data) # CharacterExpressionData
signal expression_added(expression_data)

var character_expression_container : Container
var selected_expression : Control
var file_dialog : FileDialog


func _enter_tree() -> void:
	character_expression_container = find_node("CharacterExpressionContainer")
	file_dialog = find_node("FileDialog")


func _on_AddExpressionBtn_pressed() -> void:
	var character_expression = load(
			GDUtil.get_scene_dir() + "CharacterExpressionItem.tscn").instance()
	
	character_expression.connect("focus_entered", 
			self, "_on_CharacterExpression_focus_entered", [character_expression])
	character_expression.connect("profile_pressed", file_dialog, "popup_centered")
	
	character_expression_container.add_child(character_expression)
	
	emit_signal("expression_added", character_expression.expression_data)
	
	# Wait till character_expression is added
	yield(get_tree(), "idle_frame")
	character_expression.grab_focus()


func _on_DeleteExpressionBtn_pressed() -> void:
	if not selected_expression:
		if not character_expression_container.get_child_count():
			return
			
		selected_expression = character_expression_container.get_child(
				character_expression_container.get_child_count()-1)
		
		
	emit_signal("expression_removed", selected_expression.expression_data)
			
	selected_expression.queue_free()
	selected_expression = null


func _on_CharacterExpression_focus_entered(character_expression : Control) -> void:
	selected_expression = character_expression
	

func _on_FileDialog_file_selected(path: String) -> void:
	var texture_resource : Texture = load(path)
	
	if selected_expression:
		selected_expression.expression_texture_rect.texture = texture_resource
		selected_expression.expression_data.expression_texture = texture_resource

