tool

extends PanelContainer

var main : HSplitContainer


func _enter_tree() -> void:
	main = find_node("MainContainer")


func get_dialogue_graphs() -> Array:
	var graph_list := []

	for child in main.get_children():
		if child is GraphEdit:
			graph_list.append(child)

	return graph_list


func _on_TabMenuPopup_save_dialogue() -> void:
	
	var graph_list := get_dialogue_graphs()
	
	for dgraph in graph_list:
		var packer := PackedScene.new()
		dgraph.connection_list = dgraph.get_connection_list()
		packer.pack(dgraph)
		ResourceSaver.save("res://test/test.tscn", packer)
#		for child in dgraph.get_children():
#			print_debug(child.owner)
	
	
	
