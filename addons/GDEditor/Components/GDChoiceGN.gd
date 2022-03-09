tool

extends GDGraphNode

class_name GDChoiceGN

export var s_choices : PoolStringArray

var _original_height := rect_size.y


func get_component_name() -> String:
	return "Choice"


func get_save_data() -> PoolStringArray:
	return s_choices


func _choice_index(edit: LineEdit) -> int:
	assert(is_a_parent_of(edit), "edit is not a child of %s" % name)
	
	var index := 0
	
	var children := get_children()
	
	children.erase($Header)
	
	# series: 1 + 2 * index = distance
	var distance : int = children.find(edit)
	index = (distance - 1)/2
	
	return index


func _add_choice(value := "") -> void:
	var flowport : HBoxContainer = load(GDUtil.resolve("ChoiceFlowPort.tscn")).instance()
	var edits := LineEdit.new()
	
	var index := s_choices.size()
	
	flowport.connect("remove_choice", self, "_remove_choice_edit", [flowport, edits], CONNECT_ONESHOT)
	flowport.connect("tree_exited", self, "_readjust_rect_size", [], CONNECT_ONESHOT)
	
	edits.connect("text_changed", self, "_on_choice_text_changed", [edits])
	
	add_child(flowport)
	add_child(edits)
	
	edits.size_flags_horizontal = SIZE_EXPAND_FILL
	flowport.owner = owner
	edits.owner = owner
	
	s_choices.append(value)
	update_value()


func _on_AddChoice_pressed() -> void:
	_add_choice()
	
	
func _remove_choice_edit(flowport: Control, edit: LineEdit) -> void:
	var index : int = _choice_index(edit)
	
	s_choices.remove(index)

	port_map().clear_connection(name)
	
	# They have to be freed in this order	
	edit.queue_free()
	flowport.queue_free()


func _readjust_rect_size() -> void:
	# This is a fix to readjust the node's height after
	# deleting a choice container.
	rect_size.y = _original_height


func _on_choice_text_changed(new_text: String, edit: LineEdit) -> void:
	var index : int = _choice_index(edit)
	
	s_choices[index] = new_text
	update_value()
