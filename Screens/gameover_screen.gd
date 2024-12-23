class_name GameOverScreen
extends Control

func _ready() -> void:
	%ScoreLabel.text = "%8dpts"%Global.total_score
	%RetryButton.focus_mode = FOCUS_ALL
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(
		func () -> void:
			Global.clear()
			get_tree().reload_current_scene()
	)
	%QuitButton.focus_mode = FOCUS_ALL
	%QuitButton.pressed.connect(
		func() -> void:
			get_tree().quit()
	)
