tool

extends PopupMenu

signal state_edited
signal delete_selected

enum {
	STATE_EDIT,
	STATE_DELETE
}


func _on_id_pressed(id: int) -> void:
	match id:
		STATE_EDIT:
			emit_signal("state_edited")
		STATE_DELETE:
			emit_signal("delete_selected")
