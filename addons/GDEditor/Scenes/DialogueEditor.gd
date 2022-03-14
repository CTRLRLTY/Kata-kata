tool

extends Control

class_name GDDialogueEditor

var active_graph: DialogueGraph
var active_view: DialogueGraph

onready var _tabs := find_node("Tabs")
# Deleted soon
onready var _graph_editor_container = null

onready var _top := find_node("Top")
onready var _middle := find_node("Middle")
onready var _bottom := find_node("Bottom")

onready var _tab_menu := _top.find_node("TabMenuPopup")
onready var _tools_container := _top.find_node("ToolsContainer")

onready var _left_dock := _bottom.find_node("LeftDock")
onready var _main := _bottom.find_node("Main")
onready var _graphs := _main.get_node("Graphs")
onready var _views := _main.get_node("Views")


func _ready() -> void:
	if get_tree().edited_scene_root == self:
		return
	
	GDUtil.set_debug(true)
	GDUtil.set_log_verbosity(2)
	
	GDUtil.set_dialogue_editor(self)
	add_empty_tab()
	
#	_add_graph_editor(load("res://addons/GDEditor/Saves/uwu.tscn").instance(), "test")
#
#	if not _graph_editor_container.get_editor_count():
#		add_empty_tab()


func get_tabs() -> Tabs:
	return _tabs as Tabs


func get_tools_container() -> Control:
	return _tools_container as Control


func add_empty_tab() -> void:
	add_tab("[empty]")


func add_tab(tab_name: String) -> void:
	_main.tab_add_empty()
	_tabs.add_tab(tab_name)


func change_tab(tab: int) -> void:
	GDUtil.print([self, " change to tab:", tab], GDUtil.PR_INFO, 2)
	
	_main.tab_show(tab)


func _add_graph_editor(graph_editor: GDGraphEditor, tab_name: String, tab_index := -1) -> void:
	_graph_editor_container.add_editor(graph_editor)
	# wait till editor is added
	yield(get_tree(), "idle_frame")
	
	var current_tab: int = _tabs.get_tab_count()
	
	_tabs.add_tab(tab_name)
	_tabs.set_current_tab(current_tab)
	_graph_editor_container.show_editor(current_tab)
	
	print_debug(self, " Added GDGraphEditor to graph_editor_container")


func _on_save_dialogue() -> void:
	var file_name : String = _tabs.get_tab_title(_tabs.current_tab)
	
	if file_name.is_valid_filename() and not file_name == "[empty]":
		print_debug(self, " Saving tab[%d]..." % _tabs.current_tab)
		
		var file_path := GDUtil.get_save_dir() + "/" + file_name + ".tscn"
		
		_graph_editor_container.save_editor(_tabs.current_tab, file_path)


func _on_new_dialogue(dialogue_name: String) -> void:
	add_tab(dialogue_name)
#	_add_graph_editor(
#			load(GDUtil.resolve("GraphEditor.tscn")).instance(), dialogue_name)


func _on_preview_dialogue() -> void:
	_views.visible = not _views.visible
	GDUtil.print([self, " tab(%d) preview visibile: " % _tabs.current_tab, _views.visible], GDUtil.PR_INFO, 2)


func _on_open_dialogue(graph_editor: GDGraphEditor) -> void:
	print_debug(self, " Opening dialogue: %s" % graph_editor.filename)
	var tab_name : String = graph_editor.filename.get_file().get_basename()
	
	_add_graph_editor(graph_editor, tab_name)


func _on_tab_changed(tab: int) -> void:
	change_tab(tab)


func _on_tab_closed(tab) -> void:
	_main.tab_close(tab)
#	var editor : GDGraphEditor = _graph_editor_container.get_editor(tab)
#
#	_graph_editor_container.remove_editor(tab)
#
#	# wait till editor is deleted
#	while is_instance_valid(editor):
#		yield(get_tree(), "idle_frame")
#
#
#	if _tabs.get_tab_count() == 0:
#		add_empty_tab()
#
#		# Wait till tab is added
#		while _tabs.get_tab_count() == 0:
#			yield(get_tree(), "idle_frame")
#
	if _tabs.get_tab_count() == 0:
		add_empty_tab()
	else:
		change_tab(_tabs.current_tab)


func _on_view_changed(dialogue_view: GDDialogueView) -> void:
	var current_view : GDDialogueView = _graph_editor_container.get_editor_preview(_tabs.current_tab)
	
	if dialogue_view is current_view.get_script():
		GDUtil.print([self, " Selecting same view... No change"], GDUtil.PR_INFO, 2)
		return
	
	var graph_editor = _graph_editor_container.get_editor(_tabs.current_tab)
	
	var dialogue_graph : DialogueGraph = load(GDUtil.resolve("DialogueGraph.tscn")).instance()
	
	graph_editor.set_dialogue_preview(dialogue_view)
	graph_editor.set_dialogue_graph(dialogue_graph)
	
	_tools_container.set_tools(dialogue_view.get_tools())


func _on_view_active(view: GDDialogueView) -> void:
	# Called twice when adding a new tab... Issue?
	
	_tools_container.clear_tools()
	
	GDUtil.print([self, " set active_view: ", view], GDUtil.PR_INFO, 4)
	
	# active_view must be set before adding tools. Because each add_tools invocation
	# will set each ToolBtn dialogue_view, which uses the active_view.
	_tools_container.active_view = view
	_main.active_view = view
	
	_tools_container.add_tools(view.get_tools())
	
	GDUtil.print([self, " populating node selections..."], GDUtil.PR_INFO, 3)
	
	var node_selection = _left_dock.get_node_selection()
	node_selection.clear()
	
	for component in view.get_components():
		var component_scene : PackedScene = component.scene
		
		var idx : int = node_selection.get_item_count()
		
		node_selection.add_item(component.name)
		node_selection.set_item_metadata(idx, component_scene)


func _on_view_active_next() -> void:
	pass # Replace with function body.


func _on_graph_active(graph: DialogueGraph) -> void:
	GDUtil.print([self, " set active_graph: ", graph], GDUtil.PR_INFO, 4)
	
	active_graph = graph


func _on_TabMenuPopup_about_to_show() -> void:
	if _views.visible:
		_tab_menu.set_item_text(_tab_menu.MENU_PREVIEW_DIALOGUE, "Preview [on]")
	else:
		_tab_menu.set_item_text(_tab_menu.MENU_PREVIEW_DIALOGUE, "Preview [off]")
