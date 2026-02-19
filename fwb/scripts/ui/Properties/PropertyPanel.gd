extends PanelContainer
class_name PropertyPanel

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var slider_container: VBoxContainer = $VBoxContainer/SliderContainer
@onready var apply_button: Button = $VBoxContainer/ApplyButton

const PROPERTY_SLIDER_SCENE = preload("res://scenes/ui/Properties/PropertySlider.tscn")

var current_target: Object = null

func _ready() -> void:
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
	add_to_group("property_panel")
	hide()

func setup(target_object: Object) -> void:
	if not target_object is BouncePlatform:
		push_warning("PropertyPanel only supports BouncePlatform objects")
		return

	current_target = target_object
	clear_sliders()

	if title_label:
		title_label.text = target_object.name + " Properties"

	_setup_bounce_platform_sliders(target_object)
	show()

func _setup_bounce_platform_sliders(platform: BouncePlatform) -> void:
	add_property_slider(platform, "strength", "Bounce Strength", 1.0, 10.0, 1)

func add_property_slider(target: Object, prop_name: String, label: String, min_val: float, max_val: float, step_val: float = 0.01) -> void:
	var slider_instance = PROPERTY_SLIDER_SCENE.instantiate()
	slider_container.add_child(slider_instance)
	slider_instance.configure(target, prop_name, label, min_val, max_val, step_val)

func clear_sliders() -> void:
	for child in slider_container.get_children():
		child.queue_free()

func _on_apply_pressed() -> void:
	# Apply ALL sliders
	for child in slider_container.get_children():
		if child.has_method("apply_value"):
			child.apply_value()

	hide()
	get_tree().paused = false
	current_target = null
