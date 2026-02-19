extends Node


@export var starting_level: LevelConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	LevelManager.load_level(starting_level)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		LevelManager.reset_level()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Forward to Level_Manager
		if has_node("Level_Manager"):
			$Level_Manager.handle_click(event.position)
