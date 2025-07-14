class_name Piece extends Node2D

const brick_scene = preload("res://scenes/brick.tscn")

@export var shape: int
@export var board: Board
@export var start_scale: Vector2 = Vector2(0.5,0.5)
@export var scale_up_time: float = 0.1
@export var go_back_time: float = 0.05
@export var hitbox_padding: Vector2 = Vector2(100.0, 400.0)

var color: Color = Color.WHITE:
	set(value):
		color = value
		for i in bricks:
			i.modulate = color
var bricks: Array[Node2D] = []
var dragging = false
var drag_start = Vector2()
var tween_up: Tween
var tween_down: Tween

@onready var hitbox: CollisionShape2D = %CollisionShape2D

func scale_up():
	if tween_up:
		tween_up.kill()
	tween_up = get_tree().create_tween().bind_node(self)
	tween_up.tween_property(self,"scale", Vector2.ONE, scale_up_time)

func go_back():
	if tween_down:
		tween_down.kill()
	tween_down = get_tree().create_tween().bind_node(self)
	tween_down.tween_property(self,"global_position", drag_start, go_back_time)
	tween_down.parallel().tween_property(self,"scale", start_scale, go_back_time)

func _ready():
	scale = start_scale
	for x in 8:
		for y in 8:
			if shape & (1 << (y*8+x)):
				var brick = brick_scene.instantiate()
				brick.modulate = color
				brick.position += Vector2(x,y)*Constants.BRICK_SIZE+Constants.BRICK_OFFSET
				add_child(brick)
				bricks.append(brick)
	var rect := get_rect()
	hitbox.shape = RectangleShape2D.new()
	hitbox.shape.size = rect.size*Constants.BRICK_SIZE+2*hitbox_padding
	hitbox.position += rect.size*Constants.BRICK_SIZE/2
	translate((-rect.get_center()*Constants.BRICK_SIZE-Constants.BRICK_OFFSET)*scale)

func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	if dragging:
		return
	
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = global_position
				scale_up()

func _input(event):
	if not dragging:
		return
	
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			global_position += event.relative
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				dragging = false
				if tween_up: tween_up.kill()
				scale = Vector2.ONE
				if not board.try_place(self):
					go_back()

func get_rect() -> Rect2i:
	var minx := 7
	var miny := 7
	var maxx := 0
	var maxy := 0
	for x in 8:
		for y in 8:
			if shape & (1 << (y*8+x)):
				minx = min(minx, x)
				miny = min(miny, y)
				maxx = max(maxx, x)
				maxy = max(maxy, y)
	return Rect2i(minx, miny, maxx-minx+1, maxy-miny+1)
