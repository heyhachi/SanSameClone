class_name PanelItem
extends Area2D

signal get_panel(pos: Vector3)
signal select_panel(pos: Vector3)

## パネルのスプライト
@onready var skin: Sprite2D = $Skin

## パネルの色
var color := Global.PanelColor.RED:
	set = set_color

## 盤面グリッド上の座標
var grid_position := Vector3.ZERO
## 移動アニメーション制御用Tween
var _tween: Tween
## デバッグ用のパネル番号
var index := 0:
	set = set_panel_index


var textures = {
	Global.PanelColor.EMPTY: null,
	Global.PanelColor.RED: preload("res://Assets/Panels/element_red_square_glossy.png"),
	Global.PanelColor.BLUE: preload("res://Assets/Panels/element_blue_square_glossy.png"),
	Global.PanelColor.GREEN: preload("res://Assets/Panels/element_green_square_glossy.png"),
	Global.PanelColor.MAGENTA: preload("res://Assets/Panels/element_purple_cube_glossy.png"),
	Global.PanelColor.WHITE: preload("res://Assets/Panels/element_grey_square_glossy.png"),
}

var color_name = {
	Global.PanelColor.EMPTY: "空",
	Global.PanelColor.RED: "赤",
	Global.PanelColor.BLUE: "青",
	Global.PanelColor.GREEN: "緑",
	Global.PanelColor.MAGENTA: "紫",
	Global.PanelColor.WHITE: "白",
}


#func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	#if event is InputEventMouseMotion or event is InputEventMouseButton:
		#if event is InputEventMouseButton and event.is_action_pressed("panel_decision"):
			#print("Node clicked:%s,(%d,%d,%d),%s" % [color_name[self.color], grid_position.x, grid_position.y, grid_position.z, self.name])
			#get_panel.emit(grid_position)
			#viewport.set_input_as_handled()
			#queue_free()


func _ready() -> void:
	#mouse_entered.connect(
		#func () -> void:
			#select_panel.emit(grid_position)
	#)
	#var shader = ShaderMaterial.new()
	#shader.shader = preload("res://Panels/outline.gdshader")
	#material = shader
	#
	pass


func update_position(tile_size: int, offset: Vector3 = Vector3.ZERO, is_instant: bool = true) -> void:
	var pos = Vector2(grid_position.x, grid_position.y)
	var offs = Vector2(offset.x, offset.y)
	
	if is_instant:
		position = pos * tile_size + offs
	else:
		var desired_pos = pos * tile_size + offs
		if _tween != null and _tween.is_running():
			_tween.stop()
		_tween = create_tween()
		_tween.set_parallel(true)
		_tween.tween_property(self, "position", desired_pos, 0.2)
		_tween.play()


func move_down() -> void:
	grid_position.y += 1
	update_position(Global.PANEL_SIZE, Vector3(-grid_position.z * Global.PANEL_LAYER_OFFSET, grid_position.z * Global.PANEL_LAYER_OFFSET, grid_position.z))


func set_color(new_color: Global.PanelColor) -> void:
	color = new_color
	skin.texture = textures[new_color]
	
	
func get_color_name() -> String:
	return color_name[self.color]


func set_panel_index(new_index: int) -> void:
	index = new_index
	%DebugLabel.text = "%03d"%index
