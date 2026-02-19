@tool
extends RigidBody2D
class_name Ball

@export var ball_radius: float = 16.0 : set = _set_ball_radius
@export var ball_color: Color = Color(0.2, 0.7, 1.0, 1.0) : set = _set_ball_color
@export var ball_mass: float = 1.0           # Mass of the ball.
@export var ball_bounce: float = 0.8         # Bounciness (restitution).
@export var ball_friction: float = 0.2       # Friction (how much it slides).

var _phys_mat: PhysicsMaterial
var _collision_shape: CollisionShape2D
var _circle_shape: CircleShape2D
var _sprite: Sprite2D

func _ready() -> void:
	if Engine.is_editor_hint():
		# Editor: setup visuals/collision only (no freeze/mass)
		_setup_ball()
		return
	# Runtime: full physics setup + freeze
	mass = ball_mass
	_setup_ball()
	linear_velocity = Vector2.ZERO
	freeze = false
	add_to_group("ball")

func _setup_ball() -> void:
	if _collision_shape == null:
		_collision_shape = CollisionShape2D.new()
		_circle_shape = CircleShape2D.new()
		_collision_shape.shape = _circle_shape
		add_child(_collision_shape)
	
	_circle_shape.radius = ball_radius
	
	if _phys_mat == null:
		_phys_mat = PhysicsMaterial.new()
		physics_material_override = _phys_mat
	_phys_mat.bounce = ball_bounce
	_phys_mat.friction = ball_friction
	
	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.centered = true
		add_child(_sprite)
	_sprite.texture = _generate_ball_texture(ball_radius, ball_color)

func _set_ball_radius(value: float) -> void:
	ball_radius = value
	if _circle_shape != null:
		_circle_shape.radius = value
	if Engine.is_editor_hint():
		_setup_ball()

func _set_ball_color(value: Color) -> void:
	ball_color = value
	if Engine.is_editor_hint() and _sprite != null:
		_sprite.texture = _generate_ball_texture(ball_radius, value)

func unfreeze() -> void:
	"""Unfreeze the ball to enable physics simulation."""
	freeze = false

func freeze_ball() -> void:
	"""Freeze the ball to disable physics simulation."""
	freeze = true

func apply_shot(direction: Vector2, strength: float) -> void:
	linear_velocity += direction.normalized() * strength

func set_ball_friction(value: float) -> void:
	ball_friction = value
	if _phys_mat != null:
		_phys_mat.friction = ball_friction

func set_ball_bounce(value: float) -> void:
	ball_bounce = value
	if _phys_mat != null:
		_phys_mat.bounce = ball_bounce

func set_ball_mass(value: float) -> void:
	ball_mass = value
	mass = ball_mass

func _generate_ball_texture(radius: float, color: Color) -> Texture2D:
	var size := int(radius * 2.0)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)

	var center := Vector2(radius, radius)
	var r_sq := radius * radius

	for y in range(size):
		for x in range(size):
			var pos := Vector2(x, y)
			var dist_sq := center.distance_squared_to(pos)
			if dist_sq <= r_sq:
				img.set_pixel(x, y, color)
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0)) 

	var tex := ImageTexture.create_from_image(img)
	return tex
