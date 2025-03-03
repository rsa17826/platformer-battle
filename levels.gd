extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  var levels = get_children()
  var selectedlevel = global.randfrom(0, len(levels)-1)
  if global.settings.map>-1:
    selectedlevel = global.settings['map']
  if global.settings['force same map']:
    if global.same(global.currentmap, -1):
      global.currentmap = selectedlevel
    else:
      selectedlevel=global.currentmap

  for level in levels:
    if level == levels[selectedlevel]:
      level.visible = true
      # log.pp(level, level.get_children())
      # for child in level.get_children():
      #   log.pp(child)
      #   if "setup" in child:
      #     child.setup()
    else:
      level.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
