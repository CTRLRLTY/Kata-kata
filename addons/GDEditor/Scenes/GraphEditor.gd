tool

extends VSplitContainer


func get_dialogue_preview() -> GDDialogueView:
	return $"DialoguePreview" as GDDialogueView


func get_dialogue_graph() -> DialogueGraph:
	return $"MainContainer/DialogueGraph" as DialogueGraph


func save() -> void:
	get_dialogue_graph().save()
