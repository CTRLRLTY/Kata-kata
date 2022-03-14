tool

extends GraphNode

class_name GDGraphNode

signal value_updated

enum Port {
	LEFT,
	RIGHT
}

enum PortType {
	ANY = -1
	FLOW = GDPortMap.PORT_FLOW
}


#######################################################
#	EXTERNAL VARIABLES
# #####################################################
#	These variables are managed externally, don't touch...

var __port_map__: GDPortMap
var __dialogue_view__: Control
#######################################################

var _graph_editor : Control
var _depth := 0


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	if has_meta("GraphEditorPath"):
		var GraphEditorPath = get_meta("GraphEditorPath")
		
		print_debug(self, " Metatada:GraphEditorPath ", GraphEditorPath)
		
		if GraphEditorPath is NodePath:
			if has_node(GraphEditorPath):
				_graph_editor = get_node(GraphEditorPath)
			
				print_debug(self, " dependancy ", _graph_editor)
	
	if has_meta("depth"):
		_depth = get_meta("depth")
		print_debug(self, " Metadata:depth ", _depth)
	
	set_depth(_depth)


func update_value() -> void:
	emit_signal("value_updated")


func set_title(t: String) -> void:
	title = t
	set_depth(_depth)


func get_title() -> String:
	return title.trim_suffix("[%d]" % _depth)


func get_depth() -> int:
	return _depth


func set_depth(num: int) -> void:
	var bare_title = get_title()
	
	title = bare_title + "[%d]" % num
	
	_depth = num
	
	if num > 0:
		modulate.a = 1
	else:
		modulate.a = 0.5
		
	set_meta("depth", num)


func get_dialogue_view() -> Control:
	return __dialogue_view__


func set_graph_editor(ge: Control) -> void:
	print_debug(self, " _graph_editor set ", ge)
	_graph_editor = ge
	
	set_meta("GraphEditorPath", ge.get_path())


func get_component_name() -> String:
	return "GDGraphNode"


func get_readers() -> Array:
	return []


func port_map() -> GDPortMap:
	return __port_map__


func connection_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return _connection_from(graph_node, to_slot, from_slot)


func connection_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return _connection_to(graph_node, from_slot, to_slot)


func disconnection_from(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return _disconnection_from(graph_node, from_slot, to_slot)


func disconnection_to(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return _disconnection_to(graph_node, to_slot, from_slot)


func get_ports(port_type: int, pos: int) -> Array:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var ports := []
	
	var pos_string : String = Port.keys()[pos].to_lower()
	var f_enable := "is_slot_enabled_%s" % pos_string
	var f_type := "get_slot_type_%s" % pos_string
	
	var port_count := 0
	
	for child in get_children():
		var idx : int = child.get_index()
		
		if call(f_enable, idx):
			match port_type:
				PortType.ANY:
					ports.append(port_count)
				_:
					if call(f_type, idx) == port_type:
						ports.append(port_count)
			
			port_count += 1
	
	return ports


func slot2port(slot: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if slot == 0:
				return idx
				
			slot = max(slot - 1, 0)
			
	return -1


func port2slot(port: int, pos: int) -> int:
	assert(pos == Port.LEFT or pos == Port.RIGHT)
	
	var pos_string = Port.keys()[pos].to_lower()
	var acc := 0
	
	for idx in range(get_child_count()):
		if call("is_slot_enabled_%s" % pos_string, idx):
			if port == 0:
				return acc - 1
			
			acc += 1
				
		port = max(port - 1, 0)
			
	return -1


func get_save_data():
	pass


func _connection_from(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return true


func _connection_to(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return true


func _disconnection_from(graph_node: GDGraphNode, from_slot: int, to_slot: int) -> bool:
	return true


func _disconnection_to(graph_node: GDGraphNode, to_slot: int, from_slot: int) -> bool:
	return true
