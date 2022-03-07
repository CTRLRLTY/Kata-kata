tool

extends VSplitContainer

class_name GDGraphEditor

var _dialogue_data : GDDialogueData

onready var _main := $MainContainer
onready var _node_selection := find_node("NodeSelection")
onready var _state_tree := _main.find_node("ContextStateTree")

func _ready() -> void:
	if not get_dialogue_preview():
		var standard_view : GDDialogueView = load(
				GDUtil.resolve("GDStandardView.tscn")).instance()
		
		set_dialogue_preview(standard_view)
	
	get_dialogue_graph().owner = self


func get_dialogue_preview() -> GDDialogueView:
	var first_child : Node = get_child(0)
	
	if first_child is GDDialogueView:
		return first_child as GDDialogueView
	else:
		return null


func get_dialogue_graph() -> DialogueGraph:
	return _main.get_child(1) as DialogueGraph


func get_dialogue_data() -> GDDialogueData:
	return _dialogue_data


func get_state_tree() -> GDContextStateTree:
	return _state_tree as GDContextStateTree


func set_dialogue_graph(dgraph: DialogueGraph) -> void:
	var current_dgraph : DialogueGraph = get_dialogue_graph()
	
	if is_instance_valid(current_dgraph):
		current_dgraph.queue_free()
	
	dgraph.connect("graph_node_added", self, "_on_DialogueGraph_graph_node_added")
	dgraph.owner = self
	_main.add_child(dgraph)


func set_dialogue_preview(dialogue_view: GDDialogueView) -> void:
	dialogue_view.hide()
	
	var current_dialogue_view := get_dialogue_preview()
	
	dialogue_view.set_dialogue_graph(get_dialogue_graph())
	
	if current_dialogue_view:
		current_dialogue_view.queue_free()
		
		add_child(dialogue_view)
		move_child(dialogue_view, 0)
	else:
		add_child(dialogue_view)
		move_child(dialogue_view, 0)
	
	yield(get_tree(), "idle_frame")
	
	_node_selection.clear()
	
	for component in dialogue_view.get_components():
		var component_scene : PackedScene = component.scene
		
		var idx : int = _node_selection.get_item_count()
		var gn : GDGraphNode = component_scene.instance()
		
		_node_selection.add_item(component.name)
		_node_selection.set_item_metadata(idx, component_scene)


func save(file_path: String) -> void:
	var d := Directory.new()
	
	if not d.dir_exists(GDUtil.get_save_dir()):
		d.make_dir(GDUtil.get_save_dir())
	
	var packer := PackedScene.new()
	var dv := get_dialogue_preview()
	var dgraph := get_dialogue_graph()
	
	dgraph.save()
	dv.save()
	
	_dialogue_data = GDDialogueData.create_from(dgraph, dv)
	
	dv.set_dialogue_data(_dialogue_data)
	
	packer.pack(self)

	ResourceSaver.save(file_path, packer)
	ResourceSaver.save(GDUtil.get_save_dir()+"test.tres", _dialogue_data)


func _on_DialogueGraph_graph_node_added(graph_node: GDGraphNode) -> void:
	graph_node.set_graph_editor(self)
