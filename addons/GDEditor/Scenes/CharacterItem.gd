tool

extends PanelContainer

signal delete(character_item)


func get_character_name() -> String:
	return find_node("NameLabel").text
	

func _enter_tree() -> void:
	find_node("DeleteBtn").connect("pressed", self, 
			"emit_signal", ["delete", self]
		)
