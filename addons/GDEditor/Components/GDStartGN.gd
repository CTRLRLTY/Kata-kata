tool

extends GDStandardGN

class_name GDStartGN


func get_component_name() -> String:
	return "Start"


func get_readers() -> Array:
	return [GDStartReader.new()]
