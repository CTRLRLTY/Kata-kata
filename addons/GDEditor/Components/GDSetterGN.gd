tool

extends GDGraphNode

class_name GDSetterGN

export(int) var member_index 


func _enter_tree() -> void:
	find_node("MemberOption").select(member_index)


func get_component_name() -> String:
	return "Setter"


func _on_MemberOption_item_selected(index: int) -> void:
	member_index = index
