extends CharacterBody2D

var playernumber = 0

@export_category("Necesary Child Nodes")
@export var PlayerSprite: AnimatedSprite2D
@export var PlayerCollider: CollisionShape2D

var time_scale = 1

func _ready():
  if !playernumber:
    set_script.call_deferred(null)
    return
  # await global.wait(1000)
  if global.settings['player count'] == 1:
    global.debuguistart()
  JUMP_SPEED *= global.required_scale / sqrt(2)
  GRAVITY *= global.required_scale / sqrt(2)
  X_MOVE_SPEED *= global.required_scale / sqrt(2)
  MAX_KT *= global.required_scale / sqrt(2)
  DASH_SPEED *= global.required_scale / sqrt(2)
  if $sprites.get_child(playernumber - 1):
    $sprites.get_child(playernumber - 1).visible = true
  else:
    $sprites.get_child(0).visible = true
    
  # if playernumber == 1:
  #   global.debuguistart()

var lastxdir: float = 1
var lastydir: float = 0
var jumpingtime = 0
var tryingtojump: bool = false
var jumping: bool = false

@export_category("base")
@export_range(0, 5000, 10) var GRAVITY = 1120
@export_range(0, 5000, 10) var TERMINAL_VELOCITY = 1120 * 1.5
@export_range(0, 5000, 10) var X_MOVE_SPEED = 180

@export_category("jump")
@export_range(0, 5000, 10) var JUMP_SPEED = 400
@export_range(0, 20, 1) var MAX_JUMPS = 2
@export_range(0, 1000, 1) var MAX_KT = 8000000
@export var CAN_WALL_JUMP := true

@export_category("dash")
@export_range(0, 10, 1) var MAX_DASH_COUNT := 0
@export_range(1, 150, 1) var DASH_FOR_FRAMES = 13
@export_range(0, 5000, 1) var MAX_DASH_CD = 3
@export_range(0, 1000, 10) var DASH_SPEED = 600
@export_range(0, 50, 1) var DASH_FREEZE_FRAMES = 2
@export var allow_dash_jumps := false
@export var WALL_JUMP_FORCE := 500

@export_category("do nothing yet")
@export var DASH_ONLY_ON_RELEASE_OF_DASH_BUTTON := false
@export var refill_dashes_on_ground := true
@export var refill_dashes_on_walls := false

var kt: float = MAX_KT
var current_dash_count := MAX_DASH_COUNT
var dashcd: float = 0
var dashing: float = 0

var inp = global.InputManager.new({
  "left": "",
  "right": "",
  "up": "",
  "down": "",
  "jump": "",
  "dash": "",
  "duck": ""
})

var speed := {
  "user": Vector2.ZERO,
  "dash": Vector2.ZERO,
  "walljump": Vector2.ZERO,
}

var tempstorage = {
  "dashdir": Vector2.ZERO,
}
var current_jump_count = 0
var last_input_dir_x := 1

func _physics_process(delta: float) -> void:
  # delta *= 2
  global.debuguiclear()
  var tm: TileMap = get_parent().get_node("levels").get_child(0)
  var ppp = position
  var ltm = tm.local_to_map(ppp)# - Vector2i(21, 15)
  if tm.get_cell_source_id(0, ltm) > -1:
    log.err(ppp, ltm, tm.get_cell_source_id(0, ltm))
  log.pp(ppp, ltm)
  inp._update_key_press_states()
  speed.walljump.x *= .8
  if is_on_ceiling() and speed.user.y < 0:
    speed.user.y = 0
  if CAN_WALL_JUMP and is_on_wall_only():
    if inp.just_pressed("jump"):
      speed.user.y = -JUMP_SPEED
      if last_input_dir_x == 1:
        speed.walljump.x -= WALL_JUMP_FORCE
      elif last_input_dir_x == -1:
        speed.walljump.x += WALL_JUMP_FORCE
      # else:
      #   log.err(last_input_dir_x)
      # log.pp(last_input_dir_x)

  if is_on_floor():
    if refill_dashes_on_ground and !dashing and !dashcd:
      current_dash_count = MAX_DASH_COUNT
    kt = MAX_KT
    current_jump_count = MAX_JUMPS
    speed.user.y = 0
  else:
    if !dashing:
      speed.user.y += GRAVITY * delta
    if current_jump_count == MAX_JUMPS && kt <= 0:
      current_jump_count = MAX_JUMPS - 1
  if dashcd > 0:
    if (dashcd > 1 || is_on_floor()) || current_dash_count:
      dashcd = lower_counter(dashcd, delta)
  if allow_dash_jumps || !dashing:
    if inp.just_pressed("jump") and current_jump_count > 0:
      speed.user.y = -JUMP_SPEED
      inp.unpress("jump")
      current_jump_count -= 1
      kt = 0
  if inp.compare("left", "right"):
    last_input_dir_x = inp.compare("left", "right")
  var input_dir_y := inp.compare("down", "up")

  speed.user.x = inp.compare("left", "right") * X_MOVE_SPEED

  if inp.just_pressed("dash") && dashcd == 0 and current_dash_count:
    dashing = DASH_FOR_FRAMES + DASH_FREEZE_FRAMES
    dashcd = MAX_DASH_CD
    tempstorage.dashdir = Vector2(last_input_dir_x if !input_dir_y else inp.compare("left", "right"), -input_dir_y).normalized()
    current_dash_count -= 1
  if dashing:
    inp.unpress("dash")
    if dashing > DASH_FOR_FRAMES:
      speed.dash = Vector2.ZERO
      speed.user = Vector2.ZERO
      tempstorage.dashdir = Vector2(last_input_dir_x if !input_dir_y else inp.compare("left", "right"), -input_dir_y).normalized()
    else:
      # speed.user = Vector2.ZERO
      speed.dash = (tempstorage.dashdir * DASH_SPEED)
    if on_last_frame(dashing, delta):
      speed.user.x = clamp(speed.dash.x, -X_MOVE_SPEED, X_MOVE_SPEED)
      speed.user.y = clamp(speed.dash.y, -JUMP_SPEED, GRAVITY) / 2
      speed.dash = Vector2.ZERO
    dashing = lower_counter(dashing, delta)

  if speed.user.y > TERMINAL_VELOCITY:
    speed.user.y = TERMINAL_VELOCITY
  # log.pp(speed.user.y, TERMINAL_VELOCITY)
  velocity = Vector2.ZERO
  for thisspeed in speed.keys():
    velocity += speed[thisspeed]
    global.debuguiadd("speed." + thisspeed, speed[thisspeed])

  # dashcd = clamp(dashcd, 0, INF)
  current_dash_count = clamp(current_dash_count, 0, INF)
  # velocity *= 15
  # global.debuguiadd("inp.trypress", inp.trypress)

  kt = lower_counter(kt, delta)

  global.debuguiadd("dashing", dashing)
  global.debuguiadd("current_dash_count", current_dash_count)
  global.debuguiadd("dashcd", dashcd)
  global.debuguiadd("kt", kt)
  global.debuguiadd("current_jump_count", current_jump_count)
  global.debuguiadd("inp.just_pressed(\"jump\")", inp.just_pressed("jump"))
  move_and_slide()

func lower_counter(num, delta):
  return clamp(num - 60 * delta, 0, INF)

func on_last_frame(num, delta):
  if num <= 0:
    return false
  if num - delta <= 1:
    return true
  return false

func _on_enter_lava(body: Node2D):
  if body == self:
    if global.settings.no_die:
      return
    global.player[playernumber - 1] = 0
    global.event.trigger("dead", playernumber)
    global.checkForWinner()

func _on_power_collide(body: Node2D, power_item):
  if body == self:
    if power_item.type == "random enabled power":
      power_item.type = global.settings.spawnable_powers.filter(func(x):
        return x != power_item.type).pick_random()
    # log.pp(power_item.type, typeof(power_item.type))
    match power_item.type:
      "saw":
        global.event.trigger("power send", power_item.type, playernumber, power_item.position)
      "randrot":
        global.event.trigger("power send", power_item.type, playernumber, global.randfrom(-360, 360))
      _:
        global.event.trigger("power send", power_item.type, playernumber)
    power_item.queue_free()
