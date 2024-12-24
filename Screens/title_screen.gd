class_name TitleScene
extends Control

@export var lisence_scene: PackedScene = preload("res://Screens/license_screen.tscn")

func _ready() -> void:
	%CheckBoxEasy.toggled.connect(
		func(toggled_on: bool) -> void:
			if toggled_on:
				Global.difficulty = Global.Difficulty.EASY
	)
	%CheckBoxNormal.toggled.connect(
		func(toggled_on: bool) -> void:
			if toggled_on:
				Global.difficulty = Global.Difficulty.NORMAL
	)
	
	if Global.difficulty == Global.Difficulty.EASY:
		%CheckBoxEasy.button_pressed = true
	else:
		%CheckBoxNormal.button_pressed = true
	
	%StartButton.focus_mode = FOCUS_ALL
	%StartButton.grab_focus()
	%StartButton.pressed.connect(
		func () -> void:
			get_tree().change_scene_to_file("res://Levels/main_level.tscn")
	)
	
	%LisenceButton.focus_mode = FOCUS_ALL
	%LisenceButton.pressed.connect(
		func () -> void:
			var ins = lisence_scene.instantiate() as LicenseScreen
			$LisenceLayer.add_child(ins)
	)
