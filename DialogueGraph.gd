extends GraphEdit

onready var _previous_scroll_offset := scroll_offset

func _ready() -> void:
	for child in get_graphfilter():
		if child is ScrollBar:
			child.connect("value_changed", self, "_on_%s_value_changed" % child.get_class(), [child])


func _input(event: InputEvent) -> void:
	_previous_scroll_offset = scroll_offset
	
	if event is InputEventMouseButton:
		if not event.control:
			return
			
		if not event.is_pressed():
			return
			
		if event.button_index == BUTTON_WHEEL_UP:
			zoom *= 1.2
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom /= 1.2
		
	
func get_graphfilter() -> Control:
	return get_children()[0].get_children()


func _on_HScrollBar_value_changed(value: float, scrollbar : ScrollBar) -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		scrollbar.value = _previous_scroll_offset.x 
	
	
func _on_VScrollBar_value_changed(value: float, scrollbar : ScrollBar) -> void:
	if Input.is_key_pressed(KEY_CONTROL):
		scrollbar.value = _previous_scroll_offset.y
