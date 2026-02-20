extends Control
class_name PlatformSlider

@onready var fill_bar:     ColorRect = $Container2/Layout/ScrubArea/Fill
@onready var scrub_area:   Control   = $Container2/Layout/ScrubArea
@onready var apply_button: Button    = $Container2/Layout/ApplyButton

const PANEL_HEIGHT    := 100.0
const HIDDEN_Y_OFFSET := 120.0
const SLIDE_SPEED     := 0.22

var current_platform = null
var _min_val: float     = 1.0
var _max_val: float     = 10.0
var _current_val: float = 1.0
var _tween: Tween       = null


func _ready() -> void:
	apply_button.pressed.connect(_on_apply_pressed)
	_set_hidden_position()
	hide()


func open(platform: Node) -> void:
	current_platform = platform
	_min_val     = 1.0
	_max_val     = 10.0
	_current_val = float(platform.strength)

	var color_rect = platform.get_node_or_null("StaticBody2D/ColorRect")
	var col: Color = color_rect.color if color_rect else Color(0, 0.6, 1.0)
	fill_bar.color = col

	show()
	_animate_in()
	await get_tree().process_frame  # let layout resolve before sizing fill
	_update_fill()


func close() -> void:
	_animate_out()


func _input(event: InputEvent) -> void:
	if not visible or not current_platform:
		return

	var local_pos: Vector2
	var is_drag := false

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		local_pos = scrub_area.get_local_mouse_position()
		is_drag = true
	elif event is InputEventScreenDrag:
		local_pos = scrub_area.get_global_transform().affine_inverse() * event.position
		is_drag = true

	if is_drag:
		var ratio = clamp(local_pos.x / scrub_area.size.x, 0.0, 1.0)
		_current_val = _min_val + ratio * (_max_val - _min_val)
		_update_fill()
		if current_platform:
			current_platform.update_value(_current_val)


func _update_fill() -> void:
	if scrub_area.size.x <= 0:
		return
	var ratio = (_current_val - _min_val) / (_max_val - _min_val)
	fill_bar.size.x = scrub_area.size.x * ratio


func _animate_in() -> void:
	_kill_tween()
	_set_hidden_position()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "offset_top", -PANEL_HEIGHT - 20.0, SLIDE_SPEED)
	_tween.parallel().tween_property(self, "offset_bottom", -20.0, SLIDE_SPEED)


func _animate_out() -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(self, "offset_top", HIDDEN_Y_OFFSET, SLIDE_SPEED)
	_tween.parallel().tween_property(self, "offset_bottom", HIDDEN_Y_OFFSET + PANEL_HEIGHT, SLIDE_SPEED)
	await _tween.finished
	hide()
	current_platform = null


func _set_hidden_position() -> void:
	offset_top    =  HIDDEN_Y_OFFSET
	offset_bottom =  HIDDEN_Y_OFFSET + PANEL_HEIGHT


func _shown_y() -> float:
	return -PANEL_HEIGHT - 20.0   # offset from the bottom anchor


func _hidden_y() -> float:
	return HIDDEN_Y_OFFSET        # positive = below the bottom anchor


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()


func _on_apply_pressed() -> void:
	_animate_out()
