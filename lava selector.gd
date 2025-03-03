extends Node2D

func _ready() -> void:
  match global.lavatype:
    1:
      pass
    2:
      get_node("lavalr").queue_free()
    3:
      get_node("lavaud").queue_free()
    4:
      pass
    5:
      get_node("lavalr").queue_free()
      get_node("lavaud").queue_free()