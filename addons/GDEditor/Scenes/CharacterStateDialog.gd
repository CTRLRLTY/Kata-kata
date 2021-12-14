extends WindowDialog


func _on_TypeOption_item_selected(index: int) -> void:
	var state_type = find_node("TypeOption").get_item_text(index)
