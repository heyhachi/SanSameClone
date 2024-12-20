class_name MainLevel
extends Node2D

@onready var panel_layout_base: Marker2D = $PanelLayoutBase

@export var horizontal_count := 10
@export var vertical_count := 10
@export var z_count := 3

var panel_scene: PackedScene = preload("res://Panels/panel_item.tscn")
var panel_array := []
var mouse_position := Vector2.ZERO


func _ready() -> void:
	randomize()
	# 3次元配列を初期化
	init_field()
	# フィールドサイズ確認
	print("x,y,z:%d,%d,%d" % [panel_array.size(), panel_array[0].size(), panel_array[0][0].size()])
	
	#var arr = [3,4,1,5,9]
	#arr.sort_custom(
		#func(a: int, b: int) -> bool:
			#if a < b:
				#return true
			#return false
	#)
	#print(arr)
	


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
						item.get_panel.connect(func(pos: Vector3) -> void: panel_array[pos.x][pos.y][pos.z] = null)
				z_array.append(item)
			y_array.append(z_array)
		panel_array.append(y_array)


func _process(_delta: float) -> void:
	move_inside()
	move_down()
	move_left()
	#mouse_position = get_global_mouse_position()
	mouse_position = get_viewport().get_mouse_position()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("panel_decision"):
		on_panel_clicked()


func on_panel_clicked() -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = mouse_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 0x1
	query.exclude = [self]

	#検出したノード
	var result := space_state.intersect_point(query)
	if result:
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
		
		#Z座標上の一番上のパネルのみ取り除く
		var panel := colliders[0]
		if panel:
			panel_array[panel.grid_position.x][panel.grid_position.y][panel.grid_position.z] = null
			panel.queue_free()
			
		#for item in result:
			#var panel := item.collider as PanelItem
			#print("(%d:%d:%d)=%s" % [panel.grid_position.x, panel.grid_position.y, panel.grid_position.z, panel.get_color_name()])
		#print("")


func get_random_color() -> Global.PanelColor:
	return randi_range(1, Global.PanelColor.size() - 1) as Global.PanelColor


func is_cell_occupied(x: int, y: int, z: int) -> bool:
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return true
	return panel_array[x][y][z] != null


## パネルを奥方向へスライド
func move_inside() -> void:
	for x in panel_array.size():
		for y in panel_array[0].size():
			for z in range(panel_array[0][0].size() - 1, 0, -1):
				#奥方向への移動
				var upper_z = z - 1
				if panel_array[x][y][z] == null and panel_array[x][y][upper_z] != null:
					var panel = panel_array[x][y][upper_z]
					panel.z_index -= 1
					panel.grid_position += Vector3(0, 0, 1)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][y][z] = panel
					panel_array[x][y][upper_z] = null


## パネルを下方向へスライド
func move_down() -> void:
	for x in panel_array.size():
		for y in range(panel_array[0].size() - 1, 0, -1):
			for z in panel_array[0][0].size():
				#下方向への移動
				var up_y = y - 1
				if panel_array[x][y][z] == null and panel_array[x][up_y][z] != null:
					var panel = panel_array[x][up_y][z]
					panel.grid_position += Vector3(0, 1, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][y][z] = panel
					panel_array[x][up_y][z] = null


## 任意の列が空どうか
func is_empty_column(index: int) -> bool:
	for y in panel_array[0].size():
		for z in panel_array[0][0].size():
			if panel_array[index][y][z] != null:
				return false

	return true


## パネルを左方向へスライド
func move_left() -> void:
	for x in panel_array.size() - 1:
		#一列丸ごと空なら左スライド
		if not is_empty_column(x):
			continue
		for y in panel_array[0].size():
			for z in panel_array[0][0].size():
				#左方向への移動
				var right_x := x + 1
				if panel_array[x][y][z] == null and panel_array[right_x][y][z] != null:
					var panel = panel_array[right_x][y][z]
					panel.grid_position += Vector3(-1, 0, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][y][z] = panel
					panel_array[right_x][y][z] = null


func is_same_color_adjacent(x: int, y: int, z: int) -> bool:
	# 配列の範囲外チェック
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return false

	# 現在のパネルを取得
	var current_panel = panel_array[x][y][z]
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
		var adjacent_panel = panel_array[nx][ny][nz]
		if adjacent_panel != null and adjacent_panel.color == current_color:
			return true  # 隣接パネルと同じ色の場合

	return false  # 隣接する同じ色のパネルがない場合


func check_adjacent_chain(x: int, y: int, z: int, visited: Dictionary = {}) -> Array:
	# 配列範囲外チェック、または訪問済みの座標はスキップ
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return []

	var key := "%d,%d,%d" % [x, y, z]
	if visited.has(key):
		return []  # すでに訪問済みならスキップ

	# 現在のパネルを取得
	var current_panel = panel_array[x][y][z]
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
		var adjacent_panel = panel_array[nx][ny][nz]
		if adjacent_panel != null and adjacent_panel.color == current_color:
			# 再帰的にチェーンを探索
			connected_panels += check_adjacent_chain(nx, ny, nz, visited)

	return connected_panels
