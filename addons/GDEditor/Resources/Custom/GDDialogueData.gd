tool

extends Resource

class_name GDDialogueData

# GDPortMap
export var s_port_map : Resource = null

export var data_table : Dictionary

# node_name -> [GDDialougeReader, ...]
export var reader_table : Dictionary
export var view_path : String


func port_map() -> GDPortMap:
	return GDPortMap.create(s_port_map)
