extends Node2D

var rot_target = 0
const rot_speed = 100
var power_send_event: Dictionary
var dead_event: Dictionary
var game_end_timer_event: Dictionary

@onready var player_node = get_node("n/player")
@onready var this_player_number = player_node.playernumber
func _ready():
  $n/spawner/Timer.wait_time = float(global.settings['power spawn delay'])
  $n/spawner/Timer.start()
  scale = Vector2(global.required_scale, global.required_scale)
  # global.player = []
  global.timer.reset()
  if !this_player_number:
    return
  rotation_degrees = rot_target
  power_send_event = global.event.on("power send", on_power_send)
  dead_event = global.event.on("dead", on_dead)
  game_end_timer_event = global.event.on("game end timer", on_game_end_timer_start)
  player_node.inp.key_names.left = "p" + str(this_player_number) + "left"
  player_node.inp.key_names.right = "p" + str(this_player_number) + "right"
  player_node.inp.key_names.up = "p" + str(this_player_number) + "up"
  player_node.inp.key_names.down = "p" + str(this_player_number) + "down"
  player_node.inp.key_names.jump = "p" + str(this_player_number) + "jump"
  player_node.inp.key_names.dash = "p" + str(this_player_number) + "dash"
  # global.player.push_back(1)
  global.player[this_player_number - 1] = player_node

@onready var t = get_node("ui/ui2/game end timer/CenterContainer")
var game_end_timer: float = 5
var game_end_timer_started: bool = false
func on_game_end_timer_start():
  game_end_timer_started = true
  t.get_node("countdown").visible = true

func on_dead(playernum):
  if global.settings.no_die:
    return
  if playernum == this_player_number:
    game_end_timer_started = false
    global.event.off(power_send_event)
    global.event.off(dead_event)
    global.event.off(game_end_timer_event)
    var gameover = preload("res://scenes/gameover.tscn").instantiate()
    rotation_degrees = 0
    rot_target = 0
    gameover.get_node("GridContainer/survival time").text = \
    global.join(
      " ",
      "survived for",
      str(global.timer.format()),
    )
    add_child(gameover)
    # await global.wait(1000)
    get_node("n").queue_free.call_deferred()

func on_power_send(type, ignore_player, data=[]):
  if this_player_number == ignore_player:
    # log.pp("not rotating", this_player_number)
    return
  # log.pp("Started rotating", this_player_number)
  if !global.settings.no_power_notify:
    showpower(type, data, ignore_player)

  if type in ["90", "180", "-90", "-180", "45", "-45", "360", "-360"]:
    rot_target += int(type)
  else:
    match type:
      "randrot":
        rot_target += data
      "saw":
        var saw = preload("res://scenes/saw.tscn").instantiate()
        saw.position = data
        saw.get_node("Area2D").body_entered.connect(player_node._on_enter_lava)
        get_node("n").add_child.call_deferred(saw)
      _:
        log.err("Invalid power type", type)
func _process(delta):
  if game_end_timer_started:
    game_end_timer -= delta / Engine.time_scale
    t.get_node("countdown").text = str(ceil(game_end_timer))
    if game_end_timer <= 0:
      global.scores[get_node("n/player").playernumber - 1] += 1
      global.reset_game()

  if abs(rot_target - rotation_degrees) < 5:
    rotation_degrees = rot_target
  else:
    # log.pp("continues rotating", rot_target, rotation_degrees)
    var extra = (abs(rot_target - rotation_degrees) / 3000)
    if extra < 1:
      extra = 1
    if extra > 4:
      extra = 4
    if rot_target > rotation_degrees:
      rotation_degrees += rot_speed * delta * extra
    else:
      rotation_degrees -= rot_speed * delta * extra
  get_node("ui").rotation_degrees = -rotation_degrees

func showpower(type, data, sender):
  var power_notifier = $ui/ui2/power_notify.duplicate()
  var power_notifier_label = power_notifier.get_node("CenterContainer/Label")
  power_notifier_label.text = "Power " + str(type) + " received from " + str(sender)
  var rot_intencity = global.randfrom(7, 10) * 1
  var color = Color(0, 0, 0)
  power_notifier.rotation_degrees = ((rot_intencity * (1 if global.randfrom(0, 1) else -1)) + global.randfrom(-5, 5)) / 3
  match sender:
    1:
      color = Color(0, 0, 0)
    2:
      color = Color(0, 1, 0)
    3:
      color = Color(164 / 255.0, 0, 134 / 255.0)

  power_notifier_label.set("theme_override_colors/font_color", color)
  power_notifier.position.y = 200
  power_notifier.visible = true
  $ui/ui2.add_child(power_notifier)
  # make power combo decay/fix