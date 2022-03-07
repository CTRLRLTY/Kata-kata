tool

extends Tabs

signal tab_added
signal tab_closed(tab)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.doubleclick:
			return


		var curr_tab_rect := get_tab_rect(current_tab)

		if not curr_tab_rect.has_point(event.position):
			return

		var curr_tab_title := get_tab_title(current_tab)

		# Repositioned NameEdit.
		$NameEdit.rect_size = curr_tab_rect.size
		$NameEdit.rect_position = get_global_rect().position + curr_tab_rect.position
		$NameEdit.text = curr_tab_title
		$NameEdit.caret_position = curr_tab_title.length()
		$NameEdit.set_as_toplevel(true)
		$NameEdit.show_modal()
		$NameEdit.grab_focus()
		
		accept_event()


func add_tab(title := "", icon: Texture = null) -> void:
	.add_tab(title, icon)
	emit_signal("tab_added")
	emit_signal("tab_changed", get_tab_count() - 1)


func _on_tab_close(tab: int) -> void:
	if $NameEdit.visible:
		return

	if current_tab == tab:
		remove_tab(tab)
	else:
		current_tab = tab
		
	if not get_tab_count():
		add_tab("[empty]")
		current_tab = 0
	
	emit_signal("tab_closed", tab)


func _on_TabMenuPopup_new_dialogue(dialogue_name : String) -> void:
	add_tab(dialogue_name)


func _on_TabMenuPopup_open_dialogue(graph_editor : GDGraphEditor) -> void:
	add_tab(graph_editor.filename.get_file().get_basename())


func _on_NameEdit_text_entered(new_text: String) -> void:
	$NameEdit.hide()
	set_tab_title(current_tab, new_text)


func _on_NameEdit_hide() -> void:
	set_tab_title(current_tab, $NameEdit.text)
