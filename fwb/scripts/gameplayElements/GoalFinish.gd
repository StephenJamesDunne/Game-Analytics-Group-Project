extends Area2D
class_name GoalFinish

@export var finish_text: String = "LEVEL COMPLETE!"
@export var ball_group: String = "ball"
@export var trigger_once: bool = true
@export var play_sound: bool = true
@export var spawn_particles: bool = true
@export var next_scene_path: String = ""
@export var use_button: bool = true
@export var switch_delay: float = 2.0
@export var button_text: String = "NEXT LEVEL"

signal level_complete(body: Node2D)
signal switch_scene(path: String)

var isCompleted: bool = false
var canvas_layer: CanvasLayer
var next_button: Button

func complete():
	if isCompleted:
		return
	isCompleted = true
	level_complete.emit(get_tree().get_first_node_in_group(ball_group))
	_trigger_effects()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if spawn_particles and $FinishParticles:
		$FinishParticles.one_shot = true
		$FinishParticles.emitting = false
	
	await get_tree().process_frame  # Wait 1 frame for viewport
	_create_win_ui()

func _create_win_ui():
	canvas_layer = CanvasLayer.new()
	canvas_layer.name = "WinCanvas"
	canvas_layer.layer = 10  # High layer to render on top[web:42]
	get_tree().root.add_child(canvas_layer)
	
	var backdrop = ColorRect.new()
	backdrop.name = "Backdrop"
	backdrop.color = Color(0, 0, 0, 0.7)
	backdrop.size = get_viewport().get_visible_rect().size  # Full screen size[web:42]
	canvas_layer.add_child(backdrop)
	
	next_button = Button.new()
	next_button.name = "NextButton"
	next_button.text = button_text
	next_button.custom_minimum_size = Vector2(240, 80)
	next_button.process_mode = Node.PROCESS_MODE_ALWAYS
	next_button.pressed.connect(_on_next_pressed)
	canvas_layer.add_child(next_button)
	
	_center_button()
	canvas_layer.visible = false

func _center_button():
	if next_button and canvas_layer:
		var rect = get_viewport().get_visible_rect()
		next_button.position = rect.size / 2 - next_button.size / 2
		# Resize backdrop too
		if canvas_layer.get_node_or_null("Backdrop"):
			canvas_layer.get_node("Backdrop").size = rect.size

func _on_body_entered(body: RigidBody2D) -> void:
	if isCompleted and trigger_once:
		return
	if not body.is_in_group(ball_group):
		return
	
	body.linear_velocity = Vector2.ZERO
	body.angular_velocity = 0.0
	body.sleeping = true
	body.freeze = true
	
	complete()

func _trigger_effects() -> void:
	Global.send_analytics_data(1, 100)
	
	if play_sound and $Audio.stream:
		$Audio.play()
	
	if spawn_particles and $FinishParticles:
		$FinishParticles.restart()
	
	if $FinishLabel:
		$FinishLabel.text = finish_text
		$FinishLabel.visible = true
		$FinishLabel.modulate.a = 1.0
		
		var tween = create_tween()
		await tween.tween_callback(func(): await get_tree().create_timer(3.0).timeout).finished
		tween.tween_property($FinishLabel, "modulate:a", 0.0, 1.0)
		await tween.finished
		$FinishLabel.visible = false
	
	if use_button:
		_show_win_button()
	else:
		await get_tree().create_timer(switch_delay).timeout
		_go_to_next_scene()

func _show_win_button():
	get_tree().paused = true
	_center_button()
	canvas_layer.visible = true

func _on_next_pressed():
	get_tree().paused = false
	canvas_layer.visible = false
	_go_to_next_scene()

func _go_to_next_scene():
	if next_scene_path.is_empty():
		switch_scene.emit(next_scene_path)
		return
	get_tree().change_scene_to_file(next_scene_path)

func _exit_tree():
	if canvas_layer:
		canvas_layer.queue_free()
