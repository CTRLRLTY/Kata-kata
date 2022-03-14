tool

extends PanelContainer


onready var _state_tree := find_node("ContextStateTree")
onready var _node_selection := find_node("NodeSelection")


func get_state_tree() -> GDContextStateTree:
	return _state_tree as GDContextStateTree


func get_node_selection() -> ItemList:
	return _node_selection as ItemList
