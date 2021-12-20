tool

extends HBoxContainer

export var TabMenuPopupPath : NodePath
export var TabMenuBtnPath : NodePath

var tab_menu_popup : PopupMenu
var tab_menu_btn : Button
var tab : Tabs


func _enter_tree() -> void:
	tab_menu_popup = get_node(TabMenuPopupPath)
	tab_menu_btn = get_node(TabMenuBtnPath)
	tab = get_node("Tabs")


func _on_TabMenuBtn_pressed() -> void:
	tab_menu_popup.popup(tab_menu_btn.get_global_rect())
