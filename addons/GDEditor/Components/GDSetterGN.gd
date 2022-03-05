tool

extends GDGraphNode

class_name GDSetterGN

export var s_state : Resource = ContextStateData.new()

onready var _member_option := find_node("MemberOption")
onready var _state_dialog := find_node("ContextStateDialog")


func get_component_name() -> String:
	return "Setter"


func get_save_data() -> ContextStateData:
	return s_state as ContextStateData


func _on_EditButton_toggled(button_pressed: bool) -> void:
	if button_pressed:
		var ge : GDGraphEditor = get_graph_editor()
		var state_tree := ge.get_state_tree()
		var state_list := state_tree.get_state_list()
		
		var idx := state_list.find(s_state)
		
		if idx != -1:
			s_state = state_list[idx]
		
		_state_dialog.open(s_state)


func _on_StateEdit_text_changed(new_text: String) -> void:
	s_state.state_name = new_text


func _on_ContextStateDialog_confirmed() -> void:
	s_state = _state_dialog.state_data
