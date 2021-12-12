tool

extends Tabs


func _enter_tree() -> void:
	if not get_tab_count():
		add_tab("[empty]")

		
func _on_tab_close(tab: int) -> void:
	if current_tab == tab:
		remove_tab(tab)
	else:
		current_tab = tab
		
	if not get_tab_count():
		add_tab("[empty]")
		current_tab = 0


func _on_TabMenuPopup_new_dialogue(dialogue_name : String) -> void:
	add_tab(dialogue_name)
	
	current_tab = get_tab_count() - 1
