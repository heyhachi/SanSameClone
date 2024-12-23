class_name GameOverScreen
extends Control

func _ready() -> void:
	%ScoreLabel.text = "%8dpts"%Global.total_score
	%RetryButton.pressed.connect(
		func () -> void:
			get_tree().reload_current_scene()
	)
	
	%QuitButton.pressed.connect(
		func() -> void:
			get_tree().quit()
	)
