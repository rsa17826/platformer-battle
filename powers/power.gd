extends Area2D

var type = 0
func _ready():
  if global.settings.secret_powers:
    $Sprite2D.texture = load("res://powers/" + "hidden" + ".png")
  else:
    $Sprite2D.texture = load("res://powers/" + str(type) + ".png")