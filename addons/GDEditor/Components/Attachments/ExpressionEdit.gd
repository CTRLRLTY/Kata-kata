tool

extends HBoxContainer


func get_expression() -> String:
	return $Label.text


func get_value() -> bool:
	return $ValidIndicator.pressed
