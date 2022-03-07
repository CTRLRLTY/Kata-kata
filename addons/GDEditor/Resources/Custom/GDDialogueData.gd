extends Resource

class_name GDDialogueData

# assumes dialogue_view is GDDialogueView. 
# assumes dialogue_graph is GDDialogueGraph.
# This is a workaround to cyclic dependency
static func create_from(dialogue_graph: GraphEdit, dialogue_view: Control, is_copy := false):
	var data = load(GDUtil.resolve("GDDialogueData.gd")).new()
	
	var cursor = load(GDUtil.resolve("GDDialogueCursor.gd")).new()
	
	var port_map
	
	if is_copy:
		dialogue_graph.port_map()
	else:
		port_map  = dialogue_graph.port_map().copy()

	var reader_table : Dictionary = dialogue_view.get_reader_table()
	
	cursor.pt = port_map
	
	data.cursor = cursor
	data.view_path = dialogue_view.filename
	
	for gn in dialogue_graph.get_children():
		if gn is GDGraphNode:
			if gn.get_depth() == 0:
				port_map.table.erase(gn.name)
				
				continue
			
			var readers : Array = reader_table[gn.filename]
			
			data.reader_table[gn.name] = readers
			data.data_table[gn.name] = gn.get_save_data()
		
			if gn.name == "Start":
				cursor.root = gn.name
	
	if cursor.root.empty():
		port_map.table.clear()
	
	cursor.current = cursor.root
	
	return data

# GDDialogueCursor
export var cursor : Resource

export var data_table : Dictionary
export var reader_table : Dictionary
export var view_path : String
