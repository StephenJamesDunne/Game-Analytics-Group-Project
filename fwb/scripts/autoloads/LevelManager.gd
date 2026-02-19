extends Node
class_name Level_Manager


# References
@onready var ball: Ball = $Ball
@onready var property_panel: PropertyPanel = $CanvasLayer/PropertyPanel

enum LevelState {
	PLAYING, WON, EXPIRED, EDITING
}

var currentLevel: int = 0
var currentConfig: LevelConfig
var state: LevelState = LevelState.EDITING

signal levelLoaded(config)
signal levelWon
signal levelReset
signal stateChanged(new_state: LevelState)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_scene_changed() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	ball = current_scene.get_node_or_null("Ball")
	property_panel = current_scene.get_node_or_null("CanvasLayer/PropertyPanel")

	if _is_level_scene(current_scene):
		set_state(LevelState.EDITING)
		

func _is_level_scene(scene: Node) -> bool:
	return "level_" in scene.name.to_lower()

# Added specifically for clicks checks as we need to know what level it is in
## -------------------------------
func _input(event: InputEvent) -> void:
	# Only handle clicks when a level is loaded and we're in playing state
	if state != LevelState.PLAYING:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click(event.position)


func handle_click(mouse_pos: Vector2) -> void:	
	var currentScene = get_tree().current_scene
	if not currentScene:
		return
	
	# Get references to ball and property panel from current level
	var ball = currentScene.get_node_or_null("Ball")
	var property_panel = currentScene.get_node_or_null("CanvasLayer/PropertyPanel")
	
	if not ball or not property_panel:
		return
	
	# Don't open if already open
	if property_panel.visible:
		return
	
	# Check if clicked on ball
	if _is_clicking_ball(mouse_pos, ball):
		_open_property_panel(ball, property_panel)

func _is_clicking_ball(mouse_pos: Vector2, ball: Ball) -> bool:
	var distance = mouse_pos.distance_to(ball.global_position)
	return distance <= ball.ball_radius

func _open_property_panel(ball: Ball, property_panel: PropertyPanel) -> void:
	if state != LevelState.EDITING:
		return
	
	var viewport_size = get_viewport().get_visible_rect().size
	property_panel.position = Vector2(
		(viewport_size.x - property_panel.size.x) / 2,
		(viewport_size.y - property_panel.size.y) / 2
	)
	
	property_panel.setup(ball)
	property_panel.visible = true
## --------------------------------

# Called when Play button is pressed
func start_playing() -> void:
	print("in start_play")
	print("State: ", state)
	if state == LevelState.EDITING:
		if property_panel and property_panel.visible:
			property_panel.hide()
			
		set_state(LevelState.PLAYING)
		print("Started PLAY mode")

# Called when Reset button is pressed
func reset_level() -> void:
	print("Resetting level...")
	
	get_tree().reload_current_scene()
	
	set_state(LevelState.EDITING)
	levelReset.emit()

func on_goal_completed():
	if state != LevelState.PLAYING:
		return

	state = LevelState.WON
	levelWon.emit()
	on_level_won()


func on_level_won():
	print("Level completed!")
	# Freeze input, show UI, unlock next level, etc.


func set_state(new_state: LevelState):
	state = new_state
	stateChanged.emit(state)


func _on_level_select_pressed() -> void:
	GameManager.go_to_level_select()
