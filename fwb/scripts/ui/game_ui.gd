extends CanvasLayer

# Export for integration
@export var platform: StaticBody2D

# Slider configuration
const SLIDER_MIN_X = 250.0
const SLIDER_MAX_X = 850.0  # 250 + 600 width
const SLIDER_Y = 450.0
const SLIDER_HEIGHT = 50.0

# Current bounciness value (0.0 to 1.0)
var bounciness: float = 0.5
var dragging: bool = false

# UI references
@onready var slider_fill = $Control/SliderFill
@onready var slider_handle = $Control/SliderHandle

func _ready():
	# Initialize slider position
	update_slider_visual()
	print("Visual slider ready!")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if clicked on handle or slider area
				var mouse_pos = get_viewport().get_mouse_position()
				if is_mouse_over_slider(mouse_pos):
					dragging = true
					update_bounciness_from_mouse(mouse_pos)
			else:
				dragging = false
	
	elif event is InputEventMouseMotion:
		if dragging:
			var mouse_pos = event.position
			update_bounciness_from_mouse(mouse_pos)

func is_mouse_over_slider(pos: Vector2) -> bool:
	# Check if mouse is over the slider area
	return pos.y >= SLIDER_Y and pos.y <= SLIDER_Y + SLIDER_HEIGHT and \
		   pos.x >= SLIDER_MIN_X and pos.x <= SLIDER_MAX_X

func update_bounciness_from_mouse(mouse_pos: Vector2):
	# Convert mouse X position to bounciness value (0.0 to 1.0)
	var slider_width = SLIDER_MAX_X - SLIDER_MIN_X
	var relative_x = clamp(mouse_pos.x - SLIDER_MIN_X, 0, slider_width)
	bounciness = relative_x / slider_width
	
	# Update visual
	update_slider_visual()
	
	# Update platform if connected
	if platform:
		platform.bounciness = bounciness
		print("Platform bounciness: %.2f" % bounciness)

func update_slider_visual():
	# Update fill width
	var slider_width = SLIDER_MAX_X - SLIDER_MIN_X
	var fill_width = bounciness * slider_width
	slider_fill.size.x = fill_width
	
	# Update handle position (at the edge of fill)
	slider_handle.position.x = SLIDER_MIN_X + fill_width - 5  # -5 to center the 10px handle

func _process(_delta):
	# Optional: Show visual feedback when hovering
	if is_mouse_over_slider(get_viewport().get_mouse_position()) and not dragging:
		slider_handle.modulate = Color(1.2, 1.2, 1.2)  # Slightly brighter
	else:
		slider_handle.modulate = Color.WHITE
