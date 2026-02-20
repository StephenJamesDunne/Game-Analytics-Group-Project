extends StaticBody2D
class_name BallHolder

var ball: Ball
var collision_shape: CollisionShape2D
var circle_shape: CircleShape2D
var hold_position: Vector2 
var level_manager: LevelManager

func _ready() -> void:
	ball = get_parent().get_node_or_null("Ball")
	
	if not ball:
		push_error("BallHolder couldn't find Ball!")
		return
	
	# Wait one frame for ball to be fully initialized
	await get_tree().process_frame
	
	hold_position = ball.global_position
	global_position = hold_position
	
	circle_shape = CircleShape2D.new()
	circle_shape.radius = ball.ball_radius + 2
	
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	add_child(collision_shape)
	
	# Visible for debugging
	modulate = Color(0, 1, 0, 0.3)  
	
	# Get Level_Manager from scene root
	level_manager = get_tree().current_scene as Level_Manager
	if level_manager:
		level_manager.stateChanged.connect(_on_state_changed)
	
	show()
	_enable_collision(true)

func _on_state_changed(new_state: Level_Manager.LevelState) -> void:
	
	match new_state:
		LevelManager.LevelState.EDITING:
			show()
			_enable_collision(true)
			if ball:
				ball.global_position = hold_position
				ball.linear_velocity = Vector2.ZERO
				ball.angular_velocity = 0
				ball.sleeping = false
						
		LevelManager.LevelState.PLAYING:
			hide()
			_enable_collision(false)


func _enable_collision(enabled: bool) -> void:
	if collision_shape:
		collision_shape.disabled = not enabled

func _process(_delta: float) -> void:
	if visible and ball and collision_shape and not collision_shape.disabled:
		# Check if ball is drifting
		var _distance = ball.global_position.distance_to(hold_position)
		
		ball.global_position = hold_position
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0
		ball.sleeping = false
