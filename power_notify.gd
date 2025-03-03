extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.

@onready var power_notifier_label = $CenterContainer/Label
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if visible:
    # scale = lerp(scale, Vector2(1, 1), 3 * delta)
    var c = power_notifier_label.get("theme_override_colors/font_color")
    var nc = Color(c.r, c.g, c.b, c.a - delta)
    power_notifier_label.set("theme_override_colors/font_color", nc)
    
    position.y = lerp(position.y, -5.0, 1.5 * delta)
  if position.y < 1.1:
    queue_free()