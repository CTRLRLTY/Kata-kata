tool

extends GraphNode

class_name GNChoice

export(String) var choice_main
export(PoolStringArray) var choice_extras

var _original_height := rect_size.y


func _enter_tree() -> void:
	$MainChoice/LineEdit.text = choice_main
	
	for choice in choice_extras:
		_add_choice(choice)


func _choice_size() -> int:
	var acc := 0
	
	for child in get_children():
		if child.filename == GDUtil.resolve("ChoiceEditRect.tscn"):
			acc += 1
			
	return acc


func _choice_index(choice_node : Control):
	var acc := 0
	
	for child in get_children():
		if child == choice_node:
			break
		
		if child.filename == GDUtil.resolve("ChoiceEditRect.tscn"):
			acc += 1
		
	# -1 to not count main_choice
	return acc - 1


func _add_choice(value := "") -> void:
	var flowport : HBoxContainer = load(GDUtil.resolve("ChoiceFlowPort.tscn")).instance()
	var edits : MarginContainer = load(GDUtil.resolve("ChoiceEditRect.tscn")).instance()
	var idx := _choice_size() - 1
	
	flowport.connect("remove_choice", flowport, "queue_free", [], CONNECT_ONESHOT)
	flowport.connect("remove_choice", self, "_remove_choice_edit", [edits], CONNECT_ONESHOT)
	flowport.connect("remove_choice", self, "_readjust_rect_size", [], CONNECT_ONESHOT)
	
	edits.get_node("LineEdit").connect("text_changed", 
			self, "_on_choice_edit_text_changed", [edits])
	
	var bottom_margin : int = get_node("MainChoice").get_constant("margin_top")
	
	find_node("AddChoice").connect("pressed", edits, "add_constant_override", ["margin_bottom", bottom_margin])
	get_node("MainChoice").add_constant_override("margin_bottom", bottom_margin)
	
	add_child(flowport)
	add_child(edits)
	
	choice_extras.append(value)


func _on_AddChoice_pressed() -> void:
	_add_choice()
	
	
func _remove_choice_edit(choice_edit : Control) -> void:
	choice_extras.remove(_choice_index(choice_edit))
	
	choice_edit.queue_free()
	
	
func _readjust_rect_size() -> void:
	# Wait till last choice node is removed
	# We wait twice cuz for some reason, the background of 
	# this node will not be updated otherwise.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	# Reset last choice edit bottom margin
	get_child(get_child_count()-1).add_constant_override("margin_bottom", 0)
	
	# This is a fix to readjust the node's height after
	# deleting a choice container.
	rect_size.y = _original_height


func _on_MainChoiceEdit_text_changed(new_text: String) -> void:
	choice_main = new_text


func _on_choice_edit_text_changed(new_text: String, choice_edit : Control)  -> void:
	choice_extras[_choice_index(choice_edit)] = new_text
