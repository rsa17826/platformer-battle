@tool
extends Node
# tilemap
# file
# arr
# event

#

const filepath = {
}

func same(x, y):
  return typeof(x) == typeof(y) && x == y

func join(joiner="", a="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", s="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", d="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", f="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", g="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", h="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", j="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", k="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", l="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", z="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", x="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", c="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", v="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", b="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", n="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", m="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", q="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", w="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", e="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", r="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", t="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", y="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", u="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", i="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", o="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD", p="HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD"):
  var temparr = [a, s, d, f, g, h, j, k, l, z, x, c, v, b, n, m, q, w, e, r, t, y, u, i, o, p]
  temparr = temparr.filter(func(e):
    return !same(e, "HDSJAKHADSJKASHDHDSJKASDHJDSAKHASJKD")
    )
  return joiner.join(temparr)

func randstr(length=10, fromchars="qwertyuiopasdfghjklzxcvbnm1234567890~!@#$%^&*()_+-={ }[']\\|;:\",.<>/?`"):
  var s = ''
  for i in range(length):
    s += (fromchars[global.randfrom(0, len(fromchars) - 1)])
  return s

var wait_until_wait_list = []
func waituntil(cb):
  var sig = "wait until signal - " + randstr(30)
  add_user_signal(sig)
  wait_until_wait_list.append([sig, cb])
  return Signal(self, sig)

# class link:
#   static var links = []
#   static func create(varname, node, cb=func(a):
#     return a, prop="text"):
#     global.link.links.append({"node": node, "varname": varname, "prop": prop, "val": null, "cb": cb})
#   # s=set because error when name is set
#   static func s(varname, val):
#     for l in global.link.links:
#       if l.node == varname:
#         l.val = val
#         l.node[l.prop] = l.cb(val)

class lableformat:
  static var lableformats = {}
  static func create(name, label, format):
    global.lableformat.lableformats[name] = {"text": format, "node": label}
  static func update(name, newtext: Dictionary):
    var keys = newtext.keys();
    var temp = global.lableformat.lableformats[name]
    var node = temp.node
    var text = temp.text
    for key in keys:
      var val = newtext[key]
      text = text.replace("{" + str(key) + "}", str(val))
    node.text = text

func _process(delta):
  if timer.started:
    timer.time += delta
  for i in wait_until_wait_list:
    if has_user_signal(i[0]) and i[1] && i[1].is_valid() && i[1].call():
      Signal(self, i[0]).emit()
      remove_user_signal(i[0])
  # for link in global.link.links:
  #   if link.node.is_inside_tree() and link.node.is_node_ready():
  #     link.node[link.prop] = link.cb.call(link.val)
class timer:
  static var time: float = 0
  static var started: bool = false
  static func reset():
    timer.time = 0
  static func format(temptime="DJKASDHjkaDHJkashdjkAS") -> String:
    var time: float = timer.time if global.same(temptime, "DJKASDHjkaDHJkashdjkAS") else float(temptime)
    var minutes: float = time / 60
    var seconds: float = fmod(time, 60)
    var milliseconds: float = fmod(time, 1) * 100
    return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
  static func stop():
    timer.started = false
  static func start():
    timer.started = true

func debuguistart():
  event.trigger("debugui start")

func debuguiclear():
  if event.triggers.has("debugui clear"):
    event.trigger("debugui clear")

func debuguiadd(name, val):
  if event.triggers.has("debugui add"):
    event.trigger("debugui add", name, val)

class tilemap:
  static func save(tile_map: TileMap):
    var layers = tile_map.get_layers_count()
    var tile_map_layers = []
    tile_map_layers.resize(layers)
    for layer in layers:
        tile_map_layers[layer] = tile_map.get("layer_%s/tile_data" % layer)
    return tile_map_layers
  static func load(tile_map: TileMap, data: Array) -> void:
    for layer in data.size():
        var tiles = data[layer]
        tile_map.set('layer_%s/tile_data' % layer, tiles)

class file:
  static func write(path, text, asjson=true):
    FileAccess.open(path, FileAccess.WRITE_READ).store_string(JSON.stringify(text) if asjson else text)
  static func read(path, asjson=true, default=''):
      var f = FileAccess.open(path, FileAccess.READ)
      if !f:
        FileAccess.open(path, FileAccess.WRITE_READ).store_string(default)
        return JSON.parse_string(default) if asjson else default
        # return null if asjson else default
      if asjson:
        if JSON.parse_string(f.get_as_text()) != null:
          return JSON.parse_string(f.get_as_text())
        else:
          if JSON.parse_string(default) != null:
            return JSON.parse_string(default)
          else:
            breakpoint
            return default
      else:
        return f.get_as_text()
class arr:
  static func getcount(array, count):
    var newarr = []
    for i in range(count):
      if array.size() == 0:
        return null
      newarr.append(array[0])
      array.remove_at(0)
    return newarr
class event:
  static var triggers: Dictionary = {}
  static func trigger(msg: String, data1="AHDSJKHDASJK", data2="AHDSJKHDASJK", data3="AHDSJKHDASJK") -> void:
    if !msg in triggers:
      log.error('no triggers set for call', msg)
      return
    for cb in triggers[msg]:
      if cb != null and cb.is_valid():
        var default = "AHDSJKHDASJK"
        if global.same(data3, default):
          if global.same(data2, default):
            if global.same(data1, default):
              cb.call()
            else:
              cb.call(data1)
          else:
            cb.call(data1, data2)
        else:
          cb.call(data1, data2, data3)
  static func off(obj: Dictionary) -> void:
      var msg: String = obj.msg
      var i: int = obj.index
      if !msg in triggers:
        log.error(triggers, 'cant remove ' + str(i) + ' from ' + msg + ' because ' + msg + ' doesnt exist')
        return
      if len(triggers[msg]) <= i:
        log.error(triggers[msg], 'cant remove ' + str(i) + ' from ' + msg + ' because ' + str(i) + ' doesnt exist in ' + msg)
        return
      triggers[msg][i] = null
  static func on(msg: String, cb: Callable) -> Dictionary:
    if !msg in triggers:
      triggers[msg] = []
    triggers[msg].append(cb)
    return {'msg': msg, 'index': len(triggers[msg]) - 1}

class InputManager:
  func _init(_init_key_names):
    self.key_names = _init_key_names
    for key in self.key_names.keys():
      self.unpress(key)

    _update_key_press_states()
  var trypress = {}
  var key_names = {}
  var KEY_MAX_BUFFER: int = 15

  func pressed(key) -> int:
    return !!trypress[key].pressed

  func just_pressed(key) -> int:
    var ret = !!trypress[key].just_pressed
    if ret:
      trypress[key].just_pressed = 0
    return ret

  func just_released(key) -> int:
    return Input.is_action_just_released(key_names[key])
  func compare(neg, pos) -> int:
    var input_dir = 0
    if self.pressed(neg) == self.pressed(pos):
      input_dir = 0
    elif self.pressed(neg) and not self.pressed(pos):
      input_dir = -1
    elif self.pressed(pos):
      input_dir = 1
    return input_dir
  func unpress(key):
    trypress[key] = {
      "pressed": 0,
      "just_pressed": 0,
    }
  func press(key) -> void:
    trypress[key] = {
      "pressed": KEY_MAX_BUFFER,
      "just_pressed": KEY_MAX_BUFFER,
    }
  func _update_key_press_states() -> void:
    for key in self.key_names.keys():
      if !key_names[key]:
        continue

      if Input.is_action_just_pressed(key_names[key]):
        trypress[key].just_pressed = KEY_MAX_BUFFER
      elif trypress[key].just_pressed:
        trypress[key].just_pressed -= 1

      if Input.is_action_pressed(key_names[key]):
        trypress[key].pressed = 1
      else:
        unpress(key)

func wait(time):
  return await get_tree().create_timer(time / 1000).timeout

func starts_with(x, y):
  return x.substr(0, len(y)) == y
func ends_with(x, y):
  return x.substr(len(x) - len(y)) == y

func randfrom(min, max="unset"):
  # if global.same(max, "unset"):
  #   return min[randfrom(0, len(min) - 1)]
  return int(randf() * (max - min + 1) + min)

# local game only data
var player = []
var windows = []

func reset_game():
  match int(global.settings.hardmode):
    -1:
      global.hardmode = false
    0:
      global.hardmode = !!global.randfrom(0,1)
    1:
      global.hardmode = true
  global.event.trigger("update_scores")
  global.lavatype = global.randfrom(1, 5) if global.hardmode else global.randfrom(1, 4)
  global.timer.start()
  global.currentmap = -1

  for temp in windows:
    var win = temp[0]
    var pnum = temp[1]
    var fakewinpos = temp[2]
    var newwin = preload("res://window.tscn").instantiate()

    newwin.position = fakewinpos
    newwin.get_node("n/player").playernumber = pnum
    global.player[pnum - 1] = newwin.get_node("n/player")
    for child in win.get_children():
      child.queue_free()
    win.add_child(newwin)

func checkForWinner():
  log.pp(player)
  var alive_player_count := len(player) - player.count(0)
  if alive_player_count == 0:
    log.pp('no one is alive')
    await global.wait(1000)
    reset_game()
    return
  if alive_player_count == 1:
    for p in player:
      if p:
        log.pp('winner is player #' + str(p.playernumber))
        global.event.trigger("game end timer")
        return
    return

var lavatype = 0
var hardmode = false
var currentmap = -1

var settings = {
  # "hardmode": 0,
  # "force same map": true,
  # "map": - 1,
  # "player count": 3,
  # "spawnable_powers":[],
  # "power spawn delay":5,
  # "power spawn at start count":0,
  # "no_power_notify":false
}
var required_scale=1
var spawnable_powers = [
  # "90",
  # "-90",
  "45",
  "-45",
  "360",
  "-360",
  "180",
  "-180",
  "randrot",
  "saw",
  "random enabled power"
  # "0.5x speed",
  # "2x speed",
]
var scores = []


# make powers not spawn in blocks or player??
# make powers not spawn to close to player??
# make powers not spawn to far from player??
# add power that changes power spawn time???
# enable certan lava modes like done with powers
# add way to change player sprite/color
# add change lava mode power???
# add power spawn time setting as random range
# add start with x powers setting
# death effect
# all new icons - later
# lazer power
# attack trail particles??!

# make main window cover taskbar while playing?!?

# show lava height indicators
  # at begining until move or just fade out?

# only no lava option
# only no lava unless not hardmode option

# add silent powers mode, is currently default - dont show other players the powers effect


# add option to exit game!!
# make scoreboard display better and not be under gameplay!

# one map??
# moving playforms??
# swap map corners??


# ui menu:
  # add reset to default value button to all options!
  # make options look better, eg: replace _ with space!
  # make select button not go behind aot window???
  # make select button wait until controller button is released - @maaks menus only

# add weights for spawnable_powers
  # add setting for changing weigths


# func bind(func1, args1="ahdashjasdsdhakjkasdhdsajhasd", args2="ahdashjasdsdhakjkasdhdsajhasd", args3="ahdashjasdsdhakjkasdhdsajhasd", args4="ahdashjasdsdhakjkasdhdsajhasd", args5="ahdashjasdsdhakjkasdhdsajhasd", args6="ahdashjasdsdhakjkasdhdsajhasd", args7="ahdashjasdsdhakjkasdhdsajhasd", args8="ahdashjasdsdhakjkasdhdsajhasd", args9="ahdashjasdsdhakjkasdhdsajhasd", args10="ahdashjasdsdhakjkasdhdsajhasd", args11="ahdashjasdsdhakjkasdhdsajhasd", args12="ahdashjasdsdhakjkasdhdsajhasd", args13="ahdashjasdsdhakjkasdhdsajhasd", args14="ahdashjasdsdhakjkasdhdsajhasd", args15="ahdashjasdsdhakjkasdhdsajhasd", args16="ahdashjasdsdhakjkasdhdsajhasd"):
#   var newfunc = func(args1="ahdashjasdsdhakjkasdhdsajhasd", args2="ahdashjasdsdhakjkasdhdsajhasd", args3="ahdashjasdsdhakjkasdhdsajhasd", args4="ahdashjasdsdhakjkasdhdsajhasd", args5="ahdashjasdsdhakjkasdhdsajhasd", args6="ahdashjasdsdhakjkasdhdsajhasd", args7="ahdashjasdsdhakjkasdhdsajhasd", args8="ahdashjasdsdhakjkasdhdsajhasd", args9="ahdashjasdsdhakjkasdhdsajhasd", args10="ahdashjasdsdhakjkasdhdsajhasd", args11="ahdashjasdsdhakjkasdhdsajhasd", args12="ahdashjasdsdhakjkasdhdsajhasd", args13="ahdashjasdsdhakjkasdhdsajhasd", args14="ahdashjasdsdhakjkasdhdsajhasd", args15="ahdashjasdsdhakjkasdhdsajhasd", args16="ahdashjasdsdhakjkasdhdsajhasd", oldfunc=0):
#     var args = [args1, args2, args3, args4, args5, args6, args7, args8, args9, args10, args11, args12, args13, args14, args15, args16].filter(func(x):
#       return !global.same(x, "ahdashjasdsdhakjkasdhdsajhasd")
#       )
#     return oldfunc.call()
    
#   newfunc.name = func1.name
#   return newfunc

# func test(a, s, d):
#   should be [1, 2, 3]
#   log.pp("from test", a, s, d) 

# func _init() -> void:
#   var n = bind(test, 1)
#   log.pp(n.call(2, 3))

var level_colors = [
  "green",
  "orange",
  "yellow",
  "blue",
  "red",
  "dark orange",
  "dark green"
]