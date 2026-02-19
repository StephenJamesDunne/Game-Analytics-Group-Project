extends HBoxContainer
class_name PropertySlider

@export var property_label: String = "Property"
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step_value: float = 0.01

var target_object: Object = null
var property_name: String = ""

var label: Label
var slider: HSlider
var value_label: Label

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	label = $Label
	label.text = property_label
	label.custom_minimum_size = Vector2(80, 0)

	slider = $HSlider
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step_value
	slider.custom_minimum_size = Vector2(150, 0)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	value_label = $ValueLabel
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	slider.value_changed.connect(_on_value_changed)

func configure(target: Object, prop_name: String, label_text: String, min_val: float, max_val: float, step_val: float = 0.01) -> void:
	target_object = target
	property_name = prop_name
	property_label = label_text
	min_value = min_val
	max_value = max_val
	step_value = step_val

	if label:
		label.text = label_text
	if slider:
		slider.min_value = min_val
		slider.max_value = max_val
		slider.step = step_val

	update_from_target()

func update_from_target() -> void:
	if target_object and property_name != "":
		var current_value = target_object.get(property_name)
		if slider:
			slider.value = current_value
			_update_value_display(current_value)

func _on_value_changed(value: float) -> void:
	_update_value_display(value)

func apply_value() -> void:
	if target_object and property_name != "":
		var new_value = slider.value
		var setter_name = "update_value"
		if target_object.has_method(setter_name):
			target_object.call(setter_name, new_value)
		else:
			target_object.set(property_name, new_value)

func _update_value_display(value: float) -> void:
	if value_label:
		value_label.text = "%.2f" % value
