extends Node2D

func _ready() -> void:
  $Sprite2D.modulate.a = 0
  $Area2D.collision_mask = 0

func _process(delta: float) -> void:
  if $Sprite2D.modulate.a < .9:
    $Sprite2D.modulate.a += delta
    $Area2D.collision_mask = 0
  else:
    $Sprite2D.modulate.a = 1
    $Area2D.collision_mask = 1
    set_script(null)
