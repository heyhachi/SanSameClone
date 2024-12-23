class_name GameOverScreen
extends Control

func _ready() -> void:
	%ScoreLabel.text = "%4d"%Global.total_score
	%RetryButton.pressed.connect(
		func () -> void:
			get_tree().reload_current_scene()
	)
	
	%QuitButton.pressed.connect(
		func() -> void:
			get_tree().quit()
	)
