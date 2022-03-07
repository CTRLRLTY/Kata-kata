tool

extends Control

class_name GDDialogueEditor


onready var _tabs := find_node("Tabs")
onready var _graph_editor_container := find_node("GraphEditorContainer")
onready var _tools_container := find_node("ToolsContainer")


func _ready() -> void:
	GDUtil.set_dialogue_editor(self)
	
#	_add_graph_editor(load("res://addons/GDEditor/Saves/asd.tscn").instance(), "asd")
	
	if not _graph_editor_container.get_editor_count():
		_add_graph_editor(load(GDUtil.resolve("GraphEditor.tscn")).instance(), "[empty]")



func get_graph_editor_container() -> GDGraphEditorContainer:
	return _graph_editor_container as GDGraphEditorContainer


func get_tabs() -> Tabs:
	return _tabs as Tabs


func get_tools_container() -> Control:
	return _tools_container as Control


func _add_graph_editor(graph_editor: GDGraphEditor, tab_name: String, tab_index := -1) -> void:
	_graph_editor_container.add_editor(graph_editor)
	# wait till editor is added
	yield(get_tree(), "idle_frame")
	
	var current_tab: int = _tabs.get_tab_count()
	
	_tabs.add_tab(tab_name)
	_tabs.set_current_tab(current_tab)
	_graph_editor_container.show_editor(current_tab)
	
	var dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)
	print_debug("Added GDGraphEditor to graph_editor_container")


func _on_save_dialogue() -> void:
	var file_name : String = _tabs.get_tab_title(_tabs.current_tab)
	
	if file_name.is_valid_filename() and not file_name == "[empty]":
		print_debug("Saving tab[%d]..." % _tabs.current_tab)
		
		var file_path := GDUtil.get_save_dir() + "/" + file_name + ".tscn"
		
		_graph_editor_container.save_editor(_tabs.current_tab, file_path)


func _on_new_dialogue(dialogue_name) -> void:
	_add_graph_editor(
			load(GDUtil.resolve("GraphEditor.tscn")).instance(), dialogue_name)


func _on_preview_dialogue() -> void:
	var ge : GDGraphEditor = _graph_editor_container.get_active_editor()
	var dv = ge.get_dialogue_preview()
	
	if not dv.visible:
		dv.set_dialogue_data(ge.dialogue_data)
		dv.show()


func _on_open_dialogue(graph_editor: GDGraphEditor) -> void:
	print_debug("Opening dialogue: %s" % graph_editor.filename)
	var tab_name : String = graph_editor.filename.get_file().get_basename()
	
	_add_graph_editor(graph_editor, tab_name)


func _on_tab_changed(tab: int) -> void:
	_tools_container.clear_tools()
	var previous_dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(
			_graph_editor_container.get_active_editor().get_index())
	
	_graph_editor_container.show_editor(tab)
	
	var dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(tab)
	_tools_container.add_tools(dialogue_preview.get_tools())


func _on_tab_closed(tab) -> void:
	_graph_editor_container.remove_editor(tab)
	_graph_editor_container.show_editor(_tabs.current_tab)


func _on_view_changed(dialogue_view: GDDialogueView) -> void:
	var current_view : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)
	
	if dialogue_view is current_view.get_script():
		print_debug("Selecting same view... No change.")
		return
	
	var graph_editor = _graph_editor_container.get_editor(_tabs.current_tab)
	
	var dialogue_graph : DialogueGraph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	graph_editor.set_dialogue_preview(dialogue_view)
	graph_editor.set_dialogue_graph(dialogue_graph)
	
	_tools_container.set_tools(dialogue_view.get_tools())
