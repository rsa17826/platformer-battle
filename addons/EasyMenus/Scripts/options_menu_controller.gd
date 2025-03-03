extends Control
signal close

const HSliderWLabel = preload("res://addons/EasyMenus/Scripts/slider_w_labels.gd")

# Emits close signal and saves the options
func go_back():
  # save_options()
  emit_signal("close")

# Called from outside initializes the options menu
func on_open():
  $MarginContainer/ScrollContainer/VBoxContainer/BackButton.grab_focus()

func _input(event):
  if event.is_action_pressed("ui_cancel") && visible:
    accept_event()
    go_back()
