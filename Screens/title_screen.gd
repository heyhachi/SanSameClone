class_name TitleScene
extends Control

func _ready() -> void:
	%StartButton.focus_mode = FOCUS_ALL
	%StartButton.grab_focus()
	%StartButton.pressed.connect(
		func () -> void:
			get_tree().change_scene_to_file("res://Levels/main_level.tscn")
	)
