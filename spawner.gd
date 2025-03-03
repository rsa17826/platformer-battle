extends Node2D

const size = 64
func _on_timer_timeout():
  var r = preload("res://powers/power.tscn").instantiate()
  r.type = global.settings.spawnable_powers.pick_random()
  r.position = Vector2(global.randfrom(size, 480-size), global.randfrom(size, 480-size))
  r.body_entered.connect(get_parent().get_node("player")._on_power_collide.bind(r))
  get_parent().add_child(r)
