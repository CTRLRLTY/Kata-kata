extends GraphEdit

func _ready() -> void:
	print_debug(get_children()[0].get_children())
	print_debug(get_zoom_hbox().get_children())
