extends Node
class_name Level_Manager

# References — fetched on scene change, not via @onready
var ball: Ball = null
var property_panel = null          # legacy, kept for compatibility
var platform_slider: Control = null

enum LevelState {
	PLAYING, WON, EXPIRED, EDITING
}

var currentLevel: int = 0
var currentConfig = null
var state: LevelState = LevelState.EDITING

signal levelWon
signal levelReset
signal stateChanged(new_state: LevelState)


func _ready() -> void:
	_on_scene_changed()


func _on_scene_changed() -> void:
	if not get_tree():
		return
	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	ball           = current_scene.get_node_or_null("Ball")
	property_panel = current_scene.get_node_or_null("CanvasLayer/PropertyPanel")  # legacy
	platform_slider = current_scene.get_node_or_null("CanvasLayer/PlatformSlider")

	if _is_level_scene(current_scene):
		_connect_platform_signals(current_scene)
		set_state(LevelState.EDITING)


func _is_level_scene(scene: Node) -> bool:
	return "level_" in scene.name.to_lower()


## Connect the platform_tapped signal for every BouncePlatform in the scene.
func _connect_platform_signals(_scene: Node) -> void:
	for platform in get_tree().get_nodes_in_group("bounce_platform"):
		if not platform.platform_tapped.is_connected(_on_platform_tapped):
			platform.platform_tapped.connect(_on_platform_tapped)


## Opens the shared PlatformSlider for the tapped platform.
func _on_platform_tapped(platform) -> void:
	print("Platform tapped: ", platform.name)
	print("platform_slider found: ", platform_slider)
	if state != LevelState.EDITING:
		return
	if platform_slider:
		platform_slider.open(platform)


# ─── Input ────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if state != LevelState.PLAYING:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_click(event.position)


func handle_click(mouse_pos: Vector2) -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
	var b = current_scene.get_node_or_null("Ball")
	if not b:
		return
	if _is_clicking_ball(mouse_pos, b):
		# Ball click handling reserved for future use
		pass


func _is_clicking_ball(mouse_pos: Vector2, b: Ball) -> bool:
	return mouse_pos.distance_to(b.global_position) <= b.ball_radius


# ─── Level flow ───────────────────────────────────────────────────────────────

func start_playing() -> void:
	if state == LevelState.EDITING:
		# Close slider if open
		if platform_slider and platform_slider.visible:
			platform_slider.close()
		set_state(LevelState.PLAYING)


func reset_level() -> void:
	# Close slider immediately before reload
	if platform_slider and platform_slider.visible:
		platform_slider.hide()

	get_tree().reload_current_scene()
	set_state(LevelState.EDITING)
	levelReset.emit()


func on_goal_completed() -> void:
	if state != LevelState.PLAYING:
		return
	state = LevelState.WON
	levelWon.emit()
	on_level_won()


func on_level_won() -> void:
	print("Level completed!")


func set_state(new_state: LevelState) -> void:
	state = new_state
	stateChanged.emit(state)


func _on_level_select_pressed() -> void:
	GameManager.go_to_level_select()
