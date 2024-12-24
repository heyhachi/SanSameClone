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

##難易度
enum Difficulty {
	EASY,
	NORMAL,
}

##グリッドのセルのサイズ
const PANEL_SIZE := 64
##パネルを重ねる際のオフセット
const PANEL_LAYER_OFFSET := 12

##ハイスコア
var hi_score: int = 0
##スコア
var total_score: int = 0

##難易度
var difficulty := Difficulty.NORMAL

func initialize() -> void:
	hi_score = 0
	total_score = 0
	difficulty = Difficulty.NORMAL


func clear() -> void:
	total_score = 0
