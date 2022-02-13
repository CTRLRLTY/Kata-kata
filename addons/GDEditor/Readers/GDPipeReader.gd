extends GDDialogueReader

class_name GDPipeReader


class WaitManager extends Resource:
	func _init(obj: Object, signal_name: String, callback: FuncRef, args := []) -> void:
		yield_for(obj, signal_name, callback, args)
	
	func yield_for(obj: Object, signal_name: String, callback: FuncRef, args := []) -> void:
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
		
		_finished = true
		emit_signal("finished")


func can_handle(graph_node: GDGraphNode) -> bool:
	return graph_node is GNPipe


func render(graph_node: GNPipe, dialogue_viewer: GDDialogueView, cursor: GDDialogueCursor) -> void:
	var node_connection := graph_node.get_connections()
	
	var awaitable := get_node_data(graph_node)
	
	if not awaitable.is_finished():
		yield(awaitable, "finished")
	
	var pipe_data = awaitable.get_data()
	
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			var flows := cursor.get_flows_right()
			
			var next_index := 0
			
			if pipe_data:
				# Output true port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 0}])
				assert(next_index != -1, "%s Output port 0 has no connection" % [graph_node.name])
			else:
				# Output false port
				next_index = GDUtil.array_dictionary_findv(flows, [{"from_port": 1}])
				assert(next_index != -1, "%s Output port 1 has no connection" % [graph_node.name])
			
			cursor.next(next_index)
			dialogue_viewer.next()
		GNPipe.PipeType.WAIT_FOR:
			pass
		GNPipe.PipeType.WAIT_TILL:
			pass


func get_node_data(graph_node: GNPipe) -> Awaitable:
	var awaitable := Awaitable.new()
	
	match graph_node.s_type:
		GNPipe.PipeType.CONDITION:
			var expression_edit = graph_node.get_node("ExpressionEdit")
			var value : bool = expression_edit.get_value()
			awaitable.set_data(value)
			
		GNPipe.PipeType.WAIT_FOR:
			pass
		GNPipe.PipeType.WAIT_TILL:
			pass

	return awaitable
