class_name ScoreDisplay
extends Control

func _ready() -> void:
	pass

func set_scores(count: int, score: int) -> void:
	%PanelCount.text = "x%d"%count
	%ScoreLabel.text = "+%dpts"%score
	
	var tw := create_tween()
	tw.set_parallel(false)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "position", position + Vector2(50, -25), 0.7).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(self, "modulate:a", 0, 0.2).set_trans(Tween.TRANS_LINEAR)
	tw.finished.connect(
		func() -> void: 
			queue_free()
	)
	tw.play()
