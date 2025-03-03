extends Node2D

# Called when the node enters the scene tree for the first time.
@onready var player = get_parent().get_parent().get_parent().get_node("player")
@onready var tm: TileMap = get_parent()

@onready var id = getat(Vector2i(0, 0))
func isset(pos):
  return getat(pos) != id and getat(pos) != -1

func _ready() -> void:
  if !global.hardmode:
    queue_free()
    return
  var color = global.level_colors[int(str(get_parent().name))]
  for c in get_node("sprites").get_children():
    c.visible = false
  if get_node("sprites/" + color):
    get_node("sprites/" + color).visible = true
  else:
    log.err("no spike sprite for color: ", color)
  rotation_degrees = 45

  const down = Vector2i(0, 1)
  const right = Vector2i(1, 0)
  const up = Vector2i(0, -1)
  const left = Vector2i(-1, 0)

  if isset(down):
    rotation_degrees = 0
  elif isset(up):
    rotation_degrees = 180
  elif isset(right):
    rotation_degrees = -90
  elif isset(left):
    rotation_degrees = 90

  $area2D.connect("body_entered", player._on_enter_lava)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func getat(offset: Vector2i):
  return tm.get_cell_source_id(0, tm.local_to_map(position) + offset)
