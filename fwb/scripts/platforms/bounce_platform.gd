extends Node2D
class_name BouncePlatform

var spring := 2
@export var strength := 1

## Emitted when the player taps this platform in EDITING state.
## LevelManager listens for this and opens the shared PlatformSlider.
signal platform_tapped(platform)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.apply_shot(Vector2.UP, spring * 50 * strength)

func update_value(value) -> void:
	strength = value # pls be sure to create a reset function to allow strength revert to 1 on level created/reset
	print_debug("New Value = " + str(strength))

func _on_button_button_up() -> void:
	platform_tapped.emit(self)
