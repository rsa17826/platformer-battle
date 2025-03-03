extends Control

func _ready() -> void:
  # log.pp(Menu)
  var game_menu = Menu.new(self)
  # game_menu.clear()
  game_menu.add_named_range("hardmode", {
    -1:"off",
    1:"on",
    0:"random",
  }, 0)
  game_menu.add_multi_select("spawnable_powers", global.spawnable_powers, global.spawnable_powers)
  game_menu.add_bool("force same map", true)
  game_menu.add_range("player count", 1, 10, 1, 2)
  game_menu.add_range("map", -1, 10, 1, -1)
  game_menu.add_range("power spawn at start count", 0, 15, 1,0, false, true)
  game_menu.add_range("power spawn delay", 0.1, 30, 0.1,5, false, true)
  game_menu.add_bool("no_power_notify", false)
  game_menu.add_bool("no_die", false)
  game_menu.add_bool("secret_powers", false)
  # game_menu.debug()
  game_menu.show_menu()
  # get_child(0).get_child(1).focus()
  global.settings = game_menu.get_all_data()
  game_menu.onchanged.connect(func():
    global.settings = game_menu.get_all_data())
  
