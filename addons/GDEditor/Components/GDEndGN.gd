tool

extends GDGraphNode

class_name GDEndGN


func get_component_name() -> String:
	return "End"


func get_readers() -> Array:
	return [GDEndReader.new()]


func _connection_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	disconnect_input(to_slot)
	
	return true
