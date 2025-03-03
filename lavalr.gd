extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var time = 0
func _process(delta):
  time += delta
  position.x = 480 + (sin((time if global.lavatype == 4 else -time) / 2) * 90)
  position.y = cos(time / 5) * 90