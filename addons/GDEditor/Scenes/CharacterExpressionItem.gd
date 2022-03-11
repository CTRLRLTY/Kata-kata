tool

extends PanelContainer

signal profile_pressed
signal name_changed

var expression_data : CharacterExpressionData

onready var _expression_texture_rect := $"VBoxContainer/ExpressionTextRect"
onready var _expression_edit := $"VBoxContainer/ExpressionEdit"


func _ready() -> void:
	_expression_edit.text = expression_data.expression_name
	_expression_texture_rect.texture = expression_data.expression_texture


func get_name_edit() -> LineEdit:
	return get_node("VBoxContainer/ExpressionEdit") as LineEdit


func get_texture() -> Texture:
	return _expression_texture_rect.texture


func set_texture(texture: Texture):
	_expression_texture_rect.texture = texture


func set_expression_name(ename: String) -> void:
	get_name_edit().text = ename
	expression_data.expression_name = ename


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
	emit_signal("name_changed")



