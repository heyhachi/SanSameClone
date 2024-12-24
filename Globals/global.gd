extends Node

##パネルの色
enum PanelColor {
	EMPTY,
	RED,
	GREEN,
	BLUE,
	WHITE,
	MAGENTA,
}

##グリッドのセルのサイズ
const PANEL_SIZE := 56
##パネルを重ねる際のオフセット
const PANEL_LAYER_OFFSET := 12

##ハイスコア
var hi_score: int = 0
##スコア
var total_score: int = 0

func initialize() -> void:
	hi_score = 0
	total_score = 0
	
func clear() -> void:
	total_score = 0
