class_name PanelItem
extends Area2D

signal get_panel(pos: Vector3)

@onready var skin: Sprite2D = $Skin

var color := Global.PanelColor.RED:
	set = set_color

var grid_position := Vector3.ZERO

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


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		if event is InputEventMouseButton and event.is_action_pressed("panel_decision"):
			print("Node clicked:%s,%d,%s" % [color_name[self.color], shape_idx, self.name])  # このノードがクリックされた
			get_panel.emit(grid_position)
			viewport.set_input_as_handled()
			queue_free()


func _ready() -> void:
	pass


func update_position(tile_size: int, offset: Vector3 = Vector3.ZERO) -> void:
	var pos = Vector2(grid_position.x, grid_position.y)
	var offs = Vector2(offset.x, offset.y)
	position = pos * tile_size + offs


func move_down() -> void:
	grid_position.y += 1
	update_position(Global.PANEL_SIZE, Vector3(-grid_position.z * 8, grid_position.z * 8, grid_position.z))


func set_color(new_color: Global.PanelColor) -> void:
	color = new_color
	skin.texture = textures[new_color]
