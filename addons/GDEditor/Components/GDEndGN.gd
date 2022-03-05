tool

extends GDGraphNode

class_name GDEndGN


func get_component_name() -> String:
	return "End"


func connect_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	disconnect_input(to_slot)
	
	return true


func get_readers() -> Array:
	return [GDEndReader.new()]
