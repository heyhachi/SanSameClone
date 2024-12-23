class_name TitleScene
extends Control

@export var lisence_scene: PackedScene = preload("res://Screens/license_screen.tscn")

func _ready() -> void:
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
