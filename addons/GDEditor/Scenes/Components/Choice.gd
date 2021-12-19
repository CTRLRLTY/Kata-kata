tool

extends GraphNode

var FLOW_PORT_SCENE : PackedScene = load(GDUtil.get_attachment_dir() + "ChoiceFlowPort.tscn")
var CHOICE_EDIT_RECT : PackedScene = load(GDUtil.get_attachment_dir() + "ChoiceEditRect.tscn")

var _original_height := rect_size.y

func _on_AddChoice_pressed() -> void:
	var flowport : HBoxContainer = FLOW_PORT_SCENE.instance()
	var edits : MarginContainer = CHOICE_EDIT_RECT.instance()
	
	flowport.connect("remove_choice", flowport, "queue_free", [], CONNECT_ONESHOT)
	flowport.connect("remove_choice", edits, "queue_free", [], CONNECT_ONESHOT)
	flowport.connect("remove_choice", self, "_on_RemoveChoice_pressed", [], CONNECT_ONESHOT)
	
	var bottom_margin : int = get_node("MainChoice").get_constant("margin_top")
	find_node("AddChoice").connect("pressed", edits, "add_constant_override", ["margin_bottom", bottom_margin])
	get_node("MainChoice").add_constant_override("margin_bottom", bottom_margin)
	
	add_child(flowport)
	add_child(edits)
	
	
func _on_RemoveChoice_pressed() -> void:
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
