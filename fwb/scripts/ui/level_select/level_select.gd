extends Node

func _ready():
	for button in get_tree().get_nodes_in_group("levelButton"):
		button.pressed.connect(_on_level_button_pressed.bind(button))
		
		
func _on_level_button_pressed(button: Button):
	var idString := button.name.split("_")
	if idString.size() != 2:
		push_error("Invalid button name: %s" % button.name)
		return

	var level_id := int(idString[1])
	GameManager.go_to_level(level_id)

func _on_main_menu_pressed() -> void:
	GameManager.go_to_main_menu()
