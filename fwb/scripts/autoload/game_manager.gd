extends Node

enum GameState {
	MAIN_MENU,
	LEVEL_SELECT,
	IN_LEVEL
}

var current_level := 0

var current_state : GameState

func go_to_main_menu():
	current_state = GameState.MAIN_MENU
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func go_to_level_select():
	current_state = GameState.LEVEL_SELECT
	get_tree().change_scene_to_file("res://scenes/ui/level_select/level_select.tscn")

func go_to_level(level_id: int):
	current_state = GameState.IN_LEVEL
	LevelManager.currentLevel = level_id
	current_level = level_id
	get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % level_id)
