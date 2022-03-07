tool

extends Control

class_name GDDialogueEditor


onready var _tabs := find_node("Tabs")
onready var _graph_editor_container := find_node("GraphEditorContainer")
onready var _tools_container := find_node("ToolsContainer")


func _ready() -> void:
	GDUtil.set_dialogue_editor(self)
	
	if not _graph_editor_container.get_editor_count():
		_tabs.add_tab("[empty]")


func get_graph_editor_container() -> GDGraphEditorContainer:
	return _graph_editor_container as GDGraphEditorContainer


func get_tabs() -> Tabs:
	return _tabs as Tabs


func get_tools_container() -> Control:
	return _tools_container as Control


func _on_TabMenuPopup_save_dialogue() -> void:
	_graph_editor_container.save_editor(_tabs.current_tab)


func _on_TabMenuPopup_preview_dialogue() -> void:
	var dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)
	dialogue_preview.visible = not dialogue_preview.visible
	dialogue_preview.reset()
	
	_graph_editor_container.save_editor(_tabs.current_tab)


func _on_Tabs_tab_added() -> void:
	_graph_editor_container.add_editor()
	# wait till editor is added
	yield(get_tree(), "idle_frame")
	
	var current_tab: int = _tabs.get_tab_count() - 1
	
	_tabs.set_current_tab(current_tab)
	_graph_editor_container.show_editor(current_tab)
	
	var dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)


func _on_Tabs_tab_changed(tab: int) -> void:
	_tools_container.clear_tools()
	var previous_dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(
			_graph_editor_container.get_active_editor().get_index())
	
	_graph_editor_container.show_editor(tab)
	
	var dialogue_preview : GDDialogueView = _graph_editor_container.get_editor_preview(tab)
	_tools_container.add_tools(dialogue_preview.get_tools())


func _on_view_changed(dv: GDDialogueView) -> void:
	var current_view : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)
	var dialogue_view : GDDialogueView = dv
	
	if dialogue_view is current_view.get_script():
		print_debug("Selecting same view... No change.")
		return
	
	var graph_editor = _graph_editor_container.get_editor(_tabs.current_tab)
	
	var dialogue_graph : DialogueGraph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	graph_editor.set_dialogue_preview(dialogue_view)
	graph_editor.set_dialogue_graph(dialogue_graph)
