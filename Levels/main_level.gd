class_name MainLevel
extends Node2D

##パネルを並べる際の原点となる座標
@onready var panel_layout_base: Marker2D = $FieldLayer/PanelLayoutBase
##入力受付無効期間用タイマー
@onready var ignore_input_timer: Timer = $IgnoreInputTimer
##トータルスコア表示用ラベル
@onready var total_score_label: Label = %TotalScoreLabel
##各種スクリーン表示用レイヤー
@onready var screen_layer: CanvasLayer = $ScreenLayer

##グリッドの横幅
@export var horizontal_count := 10
##グリッドの縦幅
@export var vertical_count := 10
##グリッドの奥行き
@export var z_count := 3

##パネル用シーン
var panel_scene: PackedScene = preload("res://Panels/panel_item.tscn")
##フィールド内のパネル管理用配列、グリッド(3次元配列で順序は[x][y][z])
var panel_grid := []
##マウスの座標記憶用
var mouse_position := Vector2.ZERO
##選択中のパネルの配列
var selected_panels: Array[PanelItem] = []
##入力可能かどうか
var can_input := true
##ゲームオーバーかどうか
var is_game_over := false
##ゲームオーバースクリーン
var game_over_screen: PackedScene = preload("res://Screens/gameover_screen.tscn")
##獲得スコア表示用スクリーン
var score_popup_screen: PackedScene = preload("res://Screens/score_display.tscn")


func _ready() -> void:
	randomize()
	total_score_label.text = "%8dpts"%Global.total_score
	# 3次元配列を初期化
	init_field()
	Global.initialize()
	# フィールドサイズ確認
	print("x,y,z:%d,%d,%d" % [panel_grid.size(), panel_grid[0].size(), panel_grid[0][0].size()])
	
	#var arr = [3,4,1,5,9]
	#arr.sort_custom(
		#func(a: int, b: int) -> bool:
			#if a < b:
				#return true
			#return false
	#)
	#print(arr)
	


##フィールドの初期化を行う
##全消し可能化どうかは考慮しない
func init_field() -> void:
	for x in range(horizontal_count):
		var y_array := []
		for y in range(vertical_count):
			var z_array := []
			for z in range(z_count):
				var color := get_random_color()
				var item = null
				if color != Global.PanelColor.EMPTY:
					item = panel_scene.instantiate() as PanelItem
					if item != null:
						panel_layout_base.add_child(item)
						item.color = color
						item.grid_position += Vector3(x, y, z)
						item.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0))
						item.z_index = z_count - z
						item.get_panel.connect(func(pos: Vector3) -> void: panel_grid[pos.x][pos.y][pos.z] = null)
				z_array.append(item)
			y_array.append(z_array)
		panel_grid.append(y_array)


func _process(_delta: float) -> void:
	if is_game_over:
		return
	move_inside()
	move_down()
	move_left()
	#mouse_position = get_global_mouse_position()
	mouse_position = get_viewport().get_mouse_position()
	if !can_continue_game():
		is_game_over = true
		print("もう消せるパネルはありません")
		set_process(false)
		set_physics_process(false)
		var gos = game_over_screen.instantiate() as GameOverScreen
		if gos != null:
			screen_layer.add_child(gos)


##ゲームが継続可能かどうか判定する
##trueならば継続可能
func can_continue_game() -> bool:
	#消せるパネル現存チェック
	for x in range(horizontal_count):
		for y in range(vertical_count):
			for z in range(z_count):
				if is_same_color_adjacent(x,y,z):
					return true
	return false


func _physics_process(_delta: float) -> void:
	if is_game_over:
		return
		
	hilight_panel()
	
	if Input.is_action_just_pressed("panel_decision"):
		on_panel_clicked()


##カーソル下のパネルと、それと一緒に消せるパネルをハイライトする
func hilight_panel() -> void:
	selected_panels.clear()
	#if !can_input: return
	
	#ハイライトクリア
	for x in horizontal_count:
		for y in vertical_count:
			for z in z_count:
				var panel = panel_grid[x][y][z]
				if panel != null:
					panel.modulate = 0xFFFFFFFF
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 0x1
	query.canvas_instance_id = $FieldLayer.get_instance_id()
	query.exclude = [self]

	#検出したノード
	var result := space_state.intersect_point(query)
	if result == null or result.size() == 0: return
	
	var colliders: Array[PanelItem] = []
	for i in result:
		if i.collider is PanelItem:
			colliders.append(i.collider)
				
	#grid_positionのZ座標でソートする
	colliders.sort_custom(
		func(a:PanelItem, b:PanelItem) -> bool:
			if a.grid_position.z < b.grid_position.z:
				return true
			return false
	)
	var visited := {}
	var chained := check_adjacent_chain(
		colliders[0].grid_position.x as int, 
		colliders[0].grid_position.y as int, 
		colliders[0].grid_position.z as int,
		visited)
	
	for v in chained:
		panel_grid[v.x][v.y][v.z].modulate = Color(0.5,0.5,0.5)
		selected_panels.append(panel_grid[v.x][v.y][v.z])


##パネルをクリックした際の処理
func on_panel_clicked() -> void:
	if can_input == false:
		return
	
	#同色2個以上で消去可能
	if selected_panels.size() <= 1:
		return
		
	calcurate_score(selected_panels.size())
	for i in selected_panels:
		i.queue_free()
	
	can_input = false
	set_process_input(false)
	ignore_input_timer.wait_time = 1.0
	ignore_input_timer.start()
	ignore_input_timer.timeout.connect(
		func() -> void:
			can_input = true
			set_process_input(true)
	)


func calcurate_score(count: int) -> void:
	var score = (count -1 ) ** 2
	Global.total_score += score
	total_score_label.text = "%8d"%Global.total_score
	
	var ins := score_popup_screen.instantiate() as ScoreDisplay
	$PopupLayer.add_child(ins)
	ins.global_position = mouse_position - Vector2(20, 50)
	ins.set_scores(count, score)
	#print("%d:%d"%[score, Global.total_score])


##ランダムなパネルの色を取得する
func get_random_color() -> Global.PanelColor:
	return randi_range(1, Global.PanelColor.size() - 1) as Global.PanelColor


##任意のセルにパネルが存在するかどうか
func is_cell_occupied(x: int, y: int, z: int) -> bool:
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return true
	return panel_grid[x][y][z] != null


## パネルを奥方向へスライド
func move_inside() -> void:
	for x in panel_grid.size():
		for y in panel_grid[0].size():
			for z in range(panel_grid[0][0].size() - 1, 0, -1):
				#奥方向への移動
				var upper_z = z - 1
				if panel_grid[x][y][z] == null and panel_grid[x][y][upper_z] != null:
					var panel = panel_grid[x][y][upper_z]
					panel.z_index -= 1
					panel.grid_position += Vector3(0, 0, 1)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_grid[x][y][z] = panel
					panel_grid[x][y][upper_z] = null


## パネルを下方向へスライド
func move_down() -> void:
	for x in panel_grid.size():
		for y in range(panel_grid[0].size() - 1, 0, -1):
			for z in panel_grid[0][0].size():
				#下方向への移動
				var up_y = y - 1
				if panel_grid[x][y][z] == null and panel_grid[x][up_y][z] != null:
					var panel = panel_grid[x][up_y][z]
					panel.grid_position += Vector3(0, 1, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_grid[x][y][z] = panel
					panel_grid[x][up_y][z] = null


## 任意の列が空どうか
func is_empty_column(index: int) -> bool:
	for y in panel_grid[0].size():
		for z in panel_grid[0][0].size():
			if panel_grid[index][y][z] != null:
				return false

	return true


## パネルを左方向へスライド
func move_left() -> void:
	for x in panel_grid.size() - 1:
		#一列丸ごと空なら左スライド
		if not is_empty_column(x):
			continue
		for y in panel_grid[0].size():
			for z in panel_grid[0][0].size():
				#左方向への移動
				var right_x := x + 1
				if panel_grid[x][y][z] == null and panel_grid[right_x][y][z] != null:
					var panel = panel_grid[right_x][y][z]
					panel.grid_position += Vector3(-1, 0, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_grid[x][y][z] = panel
					panel_grid[right_x][y][z] = null


##隣接する同色パネルがあるかどうか
func is_same_color_adjacent(x: int, y: int, z: int) -> bool:
	# 配列の範囲外チェック
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return false

	# 現在のパネルを取得
	var current_panel = panel_grid[x][y][z]
	if current_panel == null:
		return false  # パネルが存在しない場合は終了

	# 現在のパネルの色を取得
	var current_color = current_panel.color

	# 隣接するパネルをチェック
	var directions := [
		Vector3(1, 0, 0),  # 右
		Vector3(-1, 0, 0),  # 左
		Vector3(0, 1, 0),  # 下
		Vector3(0, -1, 0),  # 上
		Vector3(0, 0, 1),  # 奥
		Vector3(0, 0, -1),  # 手前
	]

	for direction in directions:
		var nx = x + direction.x
		var ny = y + direction.y
		var nz = z + direction.z

		# 範囲外の場合はスキップ
		if nx < 0 or nx >= horizontal_count or ny < 0 or ny >= vertical_count or nz < 0 or nz >= z_count:
			continue

		# 隣接パネルを取得
		var adjacent_panel = panel_grid[nx][ny][nz]
		if adjacent_panel != null and adjacent_panel.color == current_color:
			return true  # 隣接パネルと同じ色の場合

	return false  # 隣接する同じ色のパネルがない場合


## 隣接するパネルを再帰的に収集する
func check_adjacent_chain(x: int, y: int, z: int, visited: Dictionary = {}) -> Array:
	# 配列範囲外チェック、または訪問済みの座標はスキップ
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return []

	var key := "%d,%d,%d" % [x, y, z]
	if visited.has(key):
		return []  # すでに訪問済みならスキップ

	# 現在のパネルを取得
	var current_panel = panel_grid[x][y][z]
	if current_panel == null:
		return []  # パネルが存在しない場合は終了

	# 現在のパネルの色を取得
	var current_color = current_panel.color

	# 現在の座標を訪問済みに追加
	visited[key] = true

	# 隣接する方向
	var directions := [
		Vector3(1, 0, 0),  # 右
		Vector3(-1, 0, 0),  # 左
		Vector3(0, 1, 0),  # 下
		Vector3(0, -1, 0),  # 上
		Vector3(0, 0, 1),  # 奥
		Vector3(0, 0, -1),  # 手前
	]

	# 現在のパネルを結果に追加
	var connected_panels := [Vector3(x, y, z)]

	# 隣接方向を探索
	for direction in directions:
		var nx = x + direction.x
		var ny = y + direction.y
		var nz = z + direction.z

		# 範囲外はスキップ
		if nx < 0 or nx >= horizontal_count or ny < 0 or ny >= vertical_count or nz < 0 or nz >= z_count:
			continue

		# 隣接するパネルを取得
		var adjacent_panel = panel_grid[nx][ny][nz]
		if adjacent_panel != null and adjacent_panel.color == current_color:
			# 再帰的にチェーンを探索
			connected_panels += check_adjacent_chain(nx, ny, nz, visited)

	return connected_panels
