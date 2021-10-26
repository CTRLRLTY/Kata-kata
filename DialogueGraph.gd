extends GraphEdit

onready var _previous_scroll_offset := scroll_offset

func _ready() -> void:
	for child in get_graphfilter():
		if child is ScrollBar:
			child.connect("value_changed", self, "_on_%s_value_changed" % child.get_class(), [child])


func _input(event: InputEvent) -> void:
	_previous_scroll_offset = scroll_offset
	
	
func get_graphfilter() -> Control:
	return get_children()[0].get_children()
	
	
func _on_HScrollBar_value_changed(value: float, scrollbar : ScrollBar) -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		scrollbar.value = _previous_scroll_offset.x 
	
	
func _on_VScrollBar_value_changed(value: float, scrollbar : ScrollBar) -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		scrollbar.value = _previous_scroll_offset.y
