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
const PANEL_SIZE := 56
##パネルを重ねる際のオフセット
const PANEL_LAYER_OFFSET := 12

var _hi_score: Array[int] = [0, 0]
##ハイスコア
var hi_score: int:
	get = get_hi_score,
	set = set_hi_score
	
##スコア
var total_score: int = 0

##難易度
var difficulty := Difficulty.NORMAL
	

##初期化
func initialize() -> void:
	_hi_score[Global.Difficulty.EASY] = 0
	_hi_score[Global.Difficulty.NORMAL] = 0
	total_score = 0
	#difficulty = Difficulty.NORMAL


##ハイスコアを格納。[br]
##難易度ごとに保持している。
func set_hi_score(new_score: int) -> void:
	_hi_score[difficulty] = new_score


##ハイスコアを取得。[br]
##難易度ごとに保持している。
func get_hi_score() -> int:
	return _hi_score[difficulty]


##引き継がないプロパティをクリア
##対象はスコア
func clear() -> void:
	total_score = 0


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	properties.append({
		"hi_score": _hi_score,
	})
	return properties


func save_game() -> void:
	var save_file := FileAccess.open("user://sansame.save", FileAccess.WRITE)
	var save_data := _get_property_list()
	var json := JSON.stringify(save_data)
	save_file.store_line(json)


func load_game() -> void:
	if not FileAccess.file_exists("user://sansame.save"):
		return
		
	var save_file := FileAccess.open("user://sansame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string := save_file.get_line()
		var json = JSON.new()
		var parse_result := json.parse(json_string)
		
		if not parse_result == OK:
			continue
			
		var node_data = json.get_data()
		var dic = node_data[0]
		_hi_score[0] = dic["hi_score"][0] as int
		_hi_score[1] = dic["hi_score"][1] as int
		
		print("loaded hiscore %d:%d"%[_hi_score[0], _hi_score[1]])
