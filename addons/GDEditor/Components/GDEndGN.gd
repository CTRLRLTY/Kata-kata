tool

extends GDGraphNode

class_name GDEndGN


func get_component_name() -> String:
	return "End"


func get_readers() -> Array:
	return [GDEndReader.new()]
