tool

extends WindowDialog

signal item_edit_focus_exited(edit)

enum {
	NONE = -2
	GUIDE_TOP,
	GUIDE_CENTER, 
	GUIDE_BOTTOM,
}

var item_container : Container

var _value_list : Array


func _enter_tree() -> void:
	item_container = find_node("ItemContainer")
	
	
func get_value_list() -> Array:
	if not _value_list:
		return []
		
	return _value_list.duplicate()
	
	
func set_value_list(list : Array) -> void:
	_value_list = []
	
	for value in list:
		add_item(value)


func resize(num : int) -> void:
	# Array is growing
	if _value_list.size() > num:
		for _i in range(num):
			pop_item()
	# Array list shrinking
	elif _value_list.size() < num:
		for _i in range(num - _value_list.size()):
			add_item()


func add_item(value := "") -> void:
	var item = load(GDUtil.resolve("ValueArrayItem.tscn")).instance()
	
	item.connect("drag_start", self, "_on_item_drag_start")
	item.connect("drag_end", self, "_on_item_drag_end")
	
	item_container.add_child(item)
	
	# In some cases, item may have not been added to the tree yet,
	# which can make its property null.
	if not item.is_inside_tree():
		yield(item, "tree_entered")
	
	item.index_label.text = str(_value_list.size())
	item.value_edit.text = value
	item.value_edit.connect("hide", self, "_update_value_list", [item, item.value_edit])
	item.value_edit.connect("focus_exited", self, "emit_signal", ["item_edit_focus_exited", item.value_edit])
	
	# Expand the list
	_value_list.append(value)


func pop_item() -> void:
	var last_child : Control = item_container.get_child(item_container.get_child_count() - 1)
	
	# Make sure last pop invocation finishes, otherwise skip waiting.
	if last_child.is_queued_for_deletion():
		yield(get_tree(), "idle_frame")
		pop_item()
	else:
		last_child.queue_free()
		_value_list.remove(last_child.get_position_in_parent())


func clear() -> void:
	if _value_list.empty():
		return
	
	for item in item_container.get_children():
		item.queue_free()
		
	_value_list.clear()
		
		
func can_drop_data_fw(position: Vector2, data : Control, from_control : Control) -> bool:
	return item_container.is_a_parent_of(data)
		
		
func get_drag_data_fw(position: Vector2, from_control : Control):
	set_drag_preview(from_control.duplicate(0))
	return from_control
	
	
func drop_data_fw(position: Vector2, data : Control , from_control : Control) -> void:
	# Okay, I am currently drunk, and I have to finish this shit fast. 
	# I'll review it if any issues popup later in life, for now idk why 
	# I wrote it like this...
	
	var from := data.get_position_in_parent()
	var to := from_control.get_position_in_parent()
	
	# +1 downward, -1 upward
	var direction = sign(to - from)
	
	# Dropping on same position
	if direction == 0:
		return
	
	match from_control.get_active_guide():
		# Swap position
		from_control.GUIDE_CENTER:
			item_container.move_child(data, to)
			item_container.move_child(from_control, from)
			
		from_control.GUIDE_TOP:
			if direction == 1:
				to = max(0, to - 1)
				
			continue

		from_control.GUIDE_BOTTOM:
			if direction == -1:
				to += 1
				
			continue
			
		_:
			item_container.move_child(data, to)
			
	# Readjust index label
	for child in item_container.get_children():
		child.index_label.text = str(child.get_position_in_parent())

	
func _update_value_list(item : Container, edit : LineEdit) -> void:
	assert(_value_list.size() - 1 >= item.get_position_in_parent())

	_value_list[item.get_position_in_parent()] = edit.text


func _on_about_to_show() -> void:
	assert(_value_list != null)
	
	if _value_list.empty():
		add_item()


func _on_item_drag_start() -> void:
	for child in item_container.get_children():
		child.set_drag_forwarding(self)
		child.set_draw_guides(true)
	
	
func _on_item_drag_end() -> void:
	for child in item_container.get_children():
		child.set_drag_forwarding(null)
		child.set_draw_guides(false)


