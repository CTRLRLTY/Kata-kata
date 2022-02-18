tool

extends HBoxContainer

signal selected(idx)


func _ready() -> void:
	var btngroup := ButtonGroup.new()
	
	for child in get_children():
		child.group = btngroup
	
	btngroup.connect("pressed", self, "_on_button_group_pressed")


func _on_button_group_pressed(button: BaseButton) -> void:
	emit_signal("selected", button.get_position_in_parent())
