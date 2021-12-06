extends ItemList

func _ready() -> void:
	var nicon = get_icon("Node2d", "EditorIcons")
	print(nicon)
	add_item("hello", nicon)
