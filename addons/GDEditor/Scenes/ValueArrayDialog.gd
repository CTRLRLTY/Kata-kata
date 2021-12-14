tool

extends WindowDialog

var item_container : Container

var value_list : Array


func _enter_tree() -> void:
	item_container = find_node("ItemContainer")
	
	if not value_list:
		value_list = []



func resize(num : int) -> void:
	# Array is growing
	if value_list.size() > num:
		for _i in range(num):
			pop_item()
	# Array list shrinking
	elif value_list.size() < num:
		for _i in range(num - value_list.size()):
			add_item()


func add_item(value := "") -> void:
	var item := PanelContainer.new()
	var hbox = HBoxContainer.new()
	var drag_btn := ToolButton.new()
	var index_label := Label.new()
	var value_edit := LineEdit.new()
	
	drag_btn.icon = load("res://addons/GDEditor/Resources/Icons/TripleBar.png")
	index_label.text = str(value_list.size())
	index_label.align = Label.ALIGN_CENTER
	index_label.valign = Label.VALIGN_CENTER
	index_label.size_flags_horizontal += SIZE_EXPAND 
	index_label.size_flags_stretch_ratio = 0.4
	
	value_edit.text = value
	value_edit.size_flags_horizontal += SIZE_EXPAND
	value_edit.connect("text_changed", self, "_on_value_edit_changed", [item])
	
	# Expand the list
	value_list.append("")
	
	hbox.add_child(drag_btn)
	hbox.add_child(index_label)
	hbox.add_child(value_edit)
	item.add_child(hbox)
	
	item_container.add_child(item)


func pop_item() -> void:
	var last_child : Control = item_container.get_child(item_container.get_child_count() - 1)
	
	# Make sure last pop invocation finishes, otherwise skip waiting.
	if last_child.is_queued_for_deletion():
		yield(get_tree(), "idle_frame")
		pop_item()
	else:
		last_child.queue_free()
		value_list.remove(last_child.get_position_in_parent())


func clear() -> void:
	for item in item_container.get_children():
		item.queue_free()



func _on_value_edit_changed(new_value : String, item : Container) -> void:
	assert(value_list.size() - 1 >= item.get_position_in_parent())

	value_list[item.get_position_in_parent()] = new_value
