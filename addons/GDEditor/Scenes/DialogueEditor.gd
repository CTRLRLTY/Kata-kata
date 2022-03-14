tool

extends Control

class_name GDDialogueEditor

var active_graph: DialogueGraph
var active_view: DialogueGraph

onready var _tabs := find_node("Tabs")

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
	
	GDutil.set_debug(true)
	GDutil.set_log_verbosity(2)
	
	GDutil.set_dialogue_editor(self)
	
	_views.connect('view_active', self, "_on_view_active")

	add_empty_tab()


func add_empty_tab() -> void:
	add_tab("[empty]")


func add_tab(tab_name: String) -> void:
	_main.tab_add_empty()
	_tabs.add_tab(tab_name)


func change_tab(tab: int) -> void:
	GDutil.print([self, " change to tab:", tab], GDutil.PR_INFO, 2)
	
	_main.tab_show(tab)


func _on_save_dialogue() -> void:
	var file_name : String = _tabs.get_tab_title(_tabs.current_tab)
	
	if file_name.is_valid_filename() and not file_name == "[empty]":
		GDutil.print([self, " Saving tab[%d]..." % _tabs.current_tab], GDutil.PR_INFO, 2)
		
		var file_path := GDutil.get_save_dir() + "/" + file_name + ".tscn"
		
		pass


func _on_new_dialogue(dialogue_name: String) -> void:
	add_tab(dialogue_name)


func _on_preview_dialogue() -> void:
	_views.visible = not _views.visible
	GDutil.print([self, " tab(%d) preview visibile: " % _tabs.current_tab, _views.visible], GDutil.PR_INFO, 2)


func _on_open_dialogue(graph_editor: GDGraphEditor) -> void:
	GDutil.print([self, " Opening dialogue file: %s" % graph_editor.filename], GDutil.PR_INFO, 2)
	var tab_name : String = graph_editor.filename.get_file().get_basename()


func _on_tab_changed(tab: int) -> void:
	change_tab(tab)


func _on_tab_closed(tab) -> void:
	_main.tab_close(tab)

	if _tabs.get_tab_count() == 0:
		add_empty_tab()
	else:
		change_tab(_tabs.current_tab)


func _on_view_changed(dv: GDDialogueView) -> void:
	if not active_view:
		return
	
	if dv is active_view.get_script():
		GDutil.print([self, " Selecting same view... No change"], GDutil.PR_INFO, 2)
		return
	


func _on_view_active(view: GDDialogueView) -> void:
	# Called twice when adding a new tab... Issue?
	
	_tools_container.clear_tools()
	
	GDutil.print([self, " set active_view: ", view], GDutil.PR_INFO, 4)
	
	# active_view must be set before adding tools. Because each add_tools invocation
	# will set each ToolBtn dialogue_view, which uses the active_view.
	_tools_container.active_view = view
	_main.active_view = view
	
	_tools_container.add_tools(view.get_tools())
	
	GDutil.print([self, " populating node selections..."], GDutil.PR_INFO, 3)
	
	var node_selection = _left_dock.get_node_selection()
	node_selection.clear()
	
	for component in view.get_components():
		var component_scene : PackedScene = component.scene
		
		var idx : int = node_selection.get_item_count()
		
		node_selection.add_item(component.name)
		node_selection.set_item_metadata(idx, component_scene)


func _on_TabMenuPopup_about_to_show() -> void:
	if _views.visible:
		_tab_menu.set_item_text(_tab_menu.MENU_PREVIEW_DIALOGUE, "Preview [on]")
	else:
		_tab_menu.set_item_text(_tab_menu.MENU_PREVIEW_DIALOGUE, "Preview [off]")
