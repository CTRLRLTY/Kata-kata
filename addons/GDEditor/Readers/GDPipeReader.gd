extends GDDialogueReader

class_name GDPipeReader


class WaitManager:
	func _init() -> void:
		assert(false, "WaitManager is not instantiable")
	
	static func yield_for(obj: Object, signal_name: String, callback: FuncRef, args := []) -> void:
		yield(obj, signal_name)
		
		callback.call_funcv(args)


class Awaitable extends Resource:
	signal finished
	
	var _finished := false
	var _data 
	
	func is_finished() -> bool:
		return _finished
	
	func get_data():
		if _finished:
			return _data
	
	func set_data(value) -> void:
		assert(not _finished)
		_data = value
		finish()
	
	func finish() -> void:
		_finished = true
		emit_signal("finished")


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GDPipeGN


func render(graph_node: GDPipeGN, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var node_connection := graph_node.get_connections()
	
	var awaitable := read(graph_node)
	
	if not awaitable.is_finished():
		yield(awaitable, "finished")
	
	match graph_node.s_type:
		GDPipeGN.PipeType.CONDITION:
			var evaluation : bool = awaitable.get_data()
			
			var flows := cursor.get_flows_right()
			
			var next_index := 0
			
			if evaluation:
				# Output true port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 0}])
				assert(next_index != -1, "%s Output port 0 has no connection" % [graph_node.name])
			else:
				# Output false port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 1}])
				assert(next_index != -1, "%s Output port 1 has no connection" % [graph_node.name])
			
			cursor.next(next_index)
			
		GDPipeGN.PipeType.WAIT_FOR:
			cursor.next()
			
		GDPipeGN.PipeType.WAIT_TILL:
			cursor.next()
		
	dialogue_viewer.next()


func read(graph_node: GDPipeGN) -> Awaitable:
	var awaitable := Awaitable.new()
	
	match graph_node.s_type:
		GDPipeGN.PipeType.CONDITION:
			var expression_edit : Control = graph_node.get_node("ExpressionEdit")
			var value : bool = expression_edit.get_value()
			awaitable.set_data(value)
			
		GDPipeGN.PipeType.WAIT_FOR:
			var wait_section : Control = graph_node.get_node("WaitSection")
			var callback := funcref(awaitable, "finish")
			WaitManager.yield_for(wait_section, "wait_finished", callback)
			wait_section.start()
			
		GDPipeGN.PipeType.WAIT_TILL:
			var signal_section : Control = graph_node.get_node("SignalSection")
			var callback := funcref(awaitable, "finish")
			WaitManager.yield_for(signal_section, "wait_finished", callback)
			signal_section.start()
	
	return awaitable
