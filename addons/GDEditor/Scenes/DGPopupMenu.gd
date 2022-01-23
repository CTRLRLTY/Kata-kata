tool

extends PopupMenu

enum Item {
	NONE = 0,
	DELETE,
	COPY,
	PASTE
}


func open() -> void:
	if get_item_count():
		clear()

	add_item("Copy", Item.COPY)
	add_separator("", 999)
	add_item("Delete", Item.DELETE)
	popup()


func open_paste() -> void:
	if get_item_count():
		clear()

	add_item("Paste", Item.PASTE)
	add_item("Copy", Item.COPY)
	add_separator("", 999)
	add_item("Delete", Item.DELETE)
	popup()
