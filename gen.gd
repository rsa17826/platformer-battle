extends Node2D

var window = preload("res://real_window.tscn")
var playercount = 0
var score_display_size_y = 60

func get_factors(num):
  var factors = []
  for i in range(1, num + 1):
    if num % i == 0:
      factors.append([i, floor(num / i)])
  factors.sort_custom(func(a, s):
      return a[1] - s[1] > 0)
  return factors

func is_prime(n):
  if n < 2:
    return false
  for i in range(2, int(sqrt(n)) + 1):
    if n % i == 0:
      return false
  return true

var yy = 0
func newwin():
  playercount += 1
  var win = window.instantiate()

  var screen_size = (DisplayServer.screen_get_size())
  screen_size.y -= 50
  var num = int(global.settings['player count'])
  var arr
  if num == 3:
    arr = [[3, 1]]
  else:
    if num > 2:
      while is_prime(num):
        num += 1

    arr = get_factors(num)
  var arr_width = arr[ceil(len(arr) / 2)][0]
  var arr_height = arr[ceil(len(arr) / 2)][1]
  win.position.x = (playercount - 1) % arr_width
  win.position.y = yy
  if win.position.x == arr_width - 1:
    yy += 1

  # log.pp(num, playercount, win.position, arr_height,arr_width)

  var min_size = min(screen_size.x / arr_width, screen_size.y / arr_height)
  screen_size = Vector2(min_size * arr_width, min_size * arr_height)
  win.size = Vector2i(min_size, min_size)
  win.position.x *= screen_size.x / arr_width
  win.position.y *= screen_size.y / arr_height
  global.required_scale = min_size / 480.0
  win.get_node("window").position -= Vector2((480 - min_size) / 2, (480 - min_size) / 2)
  # log.pp()
  win.position.y += (DisplayServer.screen_get_size().y - (min_size * arr_height)) / 2
  win.position.x += (DisplayServer.screen_get_size().x - (min_size * arr_width)) / 2
  # win.position.y += 50
  # screen_size.y-=score_display_size_y
  # DisplayServer.get_primary_screen()
  # var small_size = screen_size[1]
  # var large_size = screen_size[0]
  # win.size[0] = small_size / 2
  # win.size[1] = small_size / 2
  # # win.position.x+=large_size/2
  # if global.settings['player count'] <= 2:
  #   var s = min(large_size, small_size * 2)
  #   win.size = Vector2(s / 2, s / 2)
  #   win.position *= win.size.x
  #   win.position.y = (screen_size.y - win.size.y) / 2
  #   win.get_node("window").position += Vector2(win.size.x / 4, win.size.x / 4)
  # else:
  #   var s = (min(large_size, small_size * 2)/2)
  #   log.pp(1, s)
  #   win.get_node("window").position.x+=(small_size-s)/4
  #   win.get_node("window").position.y+=(small_size-s)/4
  #   win.get_node("window").scale=Vector2(1,10)
  #   s+=small_size-s
  #   log.pp(s, small_size, small_size-(s))
  #   win.size = Vector2(s / 2, s / 2)
  #   win.position *= win.size.x

  #   win.position+=Vector2i(win.size.x, 0)
    # win.get_node("window").position += Vector2(win.size.x / 4, win.size.x / 4)/4
    # win.size = Vector2(small_size, small_size)/2
    # win.position *= win.size.x
    # win.position.y+=score_display_size_y
    # win.position.x+=small_size/4
  # win.get_node("window").scale*=2 # breaks player speed and jump height currently
  # win.position += Vector2i(0, 30) # titlebar is too high
  global.windows.push_back([win, playercount, win.get_node("window").position])
  add_child(win)

func _init() -> void:
  global.event.on("update_scores", update_scores)

func _ready():

  global.currentmap = -1
  yy = 0
  for i in range(global.settings['player count']):
    global.player.push_back(1)
    global.scores.push_back(0)
    newwin()
  global.reset_game()

  # get_window().size = Vector2(100*global.settings['player count'], 20)
  # get_window().position = Vector2(DisplayServer.screen_get_size().x / 2 - (get_window().size.x/2), 0)
  get_window().size = Vector2(DisplayServer.screen_get_size() - Vector2i(0, 0))
  # get_window().size = Vector2(DisplayServer.screen_get_size() - Vector2i(0, 25))
  get_window().position = Vector2(0, 0)
  # get_window().position = Vector2(0,25)
func update_scores():
  var scoreboard = $Control/HBoxContainer
  var i = 0
  for score in global.scores:
    scoreboard.get_child(i).get_node("name").text = "player " + str(i + 1)
    scoreboard.get_child(i).get_node("score").text = str(score)
    i += 1
  # global.lableformat.create("p1", get_node("Control/HBoxContainer/1/name"), "{name}\n{score}")
  # global.lableformat.update("p1", {"name": "player 1", "score": 0})
