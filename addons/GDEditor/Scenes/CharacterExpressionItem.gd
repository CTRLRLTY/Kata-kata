tool

extends PanelContainer

signal profile_pressed
signal text_changed(new_text)

var expression_texture_rect : TextureRect
var expression_edit : LineEdit
var expression_data : CharacterExpressionData


func _enter_tree() -> void:
	expression_texture_rect = $"VBoxContainer/ExpressionTextRect"
	expression_edit = $"VBoxContainer/ExpressionEdit"
	
	if not expression_data:
		expression_data = CharacterExpressionData.new()
		expression_data.expression_texture = load(GDUtil.resolve("icon.png"))
		expression_data.expression_name = "owo"
		
	expression_edit.text = expression_data.expression_name
	expression_texture_rect.texture = expression_data.expression_texture
	

func _on_focus_entered() -> void:
	add_stylebox_override("panel", get_stylebox("CharacterExpressionFocus"))
	

func _on_focus_exited() -> void:
	add_stylebox_override("panel", null)


func _on_ExpressionTextRect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.button_index == BUTTON_LEFT:
			return
			
		if not event.doubleclick:
			return
		
		emit_signal("profile_pressed")


func _on_ExpressionEdit_text_changed(new_text: String) -> void:
	expression_data.expression_name = new_text
	emit_signal("text_changed", new_text)



