tool

extends ConfirmationDialog

signal node_rename(new_name)

onready var name_edit: LineEdit = $NameEdit


func _ready() -> void:
	connect("confirmed", self, "_on_confirmed")


func popup_dialog(node_name: String) -> void:
	name_edit.text = ""
	name_edit.text = node_name
	popup()


func _on_confirmed() -> void:
	emit_signal("node_rename", name_edit.text)
