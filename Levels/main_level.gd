class_name MainLevel
extends Node2D

@onready var panel_layout_base: Marker2D = $PanelLayoutBase

@export var horizontal_count := 10
@export var vertical_count := 10
@export var z_count := 3

var panel_scene: PackedScene = preload("res://Panels/panel_item.tscn")
var panel_array := []

func _ready() -> void:
	randomize()
	# 3次元配列を初期化
	init_field()
	# フィールドサイズ確認
	print("x,y,z:%d,%d,%d" % [panel_array.size(), panel_array[0].size(), panel_array[0][0].size()])


func init_field() -> void:
	for x in range(horizontal_count):
		var y_array = []
		for y in range(vertical_count):
			var z_array = []
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
			for z in panel_array[0][0].size() - 1:
				#奥方向への移動
				var inside_z = z + 1
				if panel_array[x][y][z] != null and panel_array[x][y][inside_z] == null:
					var panel = panel_array[x][y][z]
					panel.z_index = z_count - inside_z
					panel.grid_position += Vector3(0, 0, 1)
					panel.update_position(Global.PANEL_SIZE, Vector3(-inside_z * Global.PANEL_LAYER_OFFSET, inside_z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][y][inside_z] = panel
					panel_array[x][y][z] = null


## パネルを下方向へスライド
func move_down() -> void:
	for x in panel_array.size():
		for y in panel_array[0].size() - 1:
			for z in panel_array[0][0].size():
				#下方向への移動
				var down_y = y + 1
				if panel_array[x][y][z] != null and panel_array[x][down_y][z] == null:
					var panel = panel_array[x][y][z]
					panel.grid_position += Vector3(0, 1, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][down_y][z] = panel
					panel_array[x][y][z] = null


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
				var right_x = x + 1
				if panel_array[x][y][z] == null and panel_array[right_x][y][z] != null:
					var panel = panel_array[right_x][y][z]
					panel.grid_position += Vector3(-1, 0, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * Global.PANEL_LAYER_OFFSET, z * Global.PANEL_LAYER_OFFSET, 0), false)
					panel_array[x][y][z] = panel
					panel_array[right_x][y][z] = null
