extends CanvasLayer
class_name EditorUI

@onready var play_button: Button = $PlayButton
@onready var reset_button: Button = $ResetButton

var level_manager: Level_Manager

func _ready() -> void:
	# Connect buttons
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Connect to state changes
	level_manager = get_tree().current_scene as Level_Manager
	if level_manager:
		level_manager.stateChanged.connect(_on_state_changed)
	else:
		push_error("BallHolder couldn't find Level_Manager!")
	
	# Set initial state
	_update_ui_for_state(level_manager.state)

func _on_play_pressed() -> void:
	level_manager.start_playing()

func _on_reset_pressed() -> void:
	level_manager.reset_level()

func _on_state_changed(new_state: Level_Manager.LevelState) -> void:
	_update_ui_for_state(new_state)

func _update_ui_for_state(state: Level_Manager.LevelState) -> void:
	match state:
		level_manager.LevelState.EDITING:
			play_button.visible = true
			play_button.disabled = false
			reset_button.visible = true
			reset_button.text = "Reset"
		
		level_manager.LevelState.PLAYING:
			play_button.visible = true  # Hide play button during gameplay
			reset_button.visible = true
			reset_button.text = "Reset"
		
		level_manager.LevelState.WON:
			play_button.visible = false
			reset_button.visible = true
			reset_button.text = "Try Again"
