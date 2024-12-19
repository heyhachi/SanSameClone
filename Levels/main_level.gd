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
						item.update_position(Global.PANEL_SIZE, Vector3(-z * 8, z * 8, z))
						item.z_index = -z
						item.get_panel.connect(func(pos: Vector3) -> void: panel_array[pos.x][pos.y][pos.z] = null)
				z_array.append(item)
			y_array.append(z_array)
		panel_array.append(y_array)

	# フィールドサイズ確認
	print(panel_array.size())
	print(panel_array[0].size())
	print(panel_array[0][0].size())


# 	panel_array[1][2][0] = PanelColor.RED
# 	print(panel_array[1][2][0]) # 出力: 0 (RED)


func _process(_delta: float) -> void:
	apply_gravity()


func get_random_color() -> Global.PanelColor:
	return randi_range(1, Global.PanelColor.size() - 1) as Global.PanelColor


func is_cell_occupied(x: int, y: int, z: int) -> bool:
	if x < 0 or x >= horizontal_count or y < 0 or y >= vertical_count or z < 0 or z >= z_count:
		return true
	return panel_array[x][y][z] != null


func move_inside() -> void:
	for x in panel_array.size():
		for y in panel_array[0].size():
			for z in panel_array[0][0].size() - 1:
				#下方向への移動
				if panel_array[x][y][z] != null and panel_array[x][y][z + 1] == null:
					var panel = panel_array[x][y][z]
					panel_array[x][y][z] = null
					panel_array[x][y][z + 1] = panel
					panel.grid_position += Vector3(0, 1, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * 8, z * 8, z))


func apply_gravity() -> void:
	for x in panel_array.size():
		for y in panel_array[0].size() - 1:
			for z in panel_array[0][0].size():
				#下方向への移動
				if panel_array[x][y][z] != null and panel_array[x][y + 1][z] == null:
					var panel = panel_array[x][y][z]
					panel_array[x][y][z] = null
					panel_array[x][y + 1][z] = panel
					panel.grid_position += Vector3(0, 1, 0)
					panel.update_position(Global.PANEL_SIZE, Vector3(-z * 8, z * 8, z))
