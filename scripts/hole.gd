class_name Hole extends Node2D

var brick: Node2D = null
@onready
var highlight: Node2D = %BrickHighlight

func fill(_brick: Node2D):
	brick = _brick
	if brick.is_inside_tree():
		brick.reparent(self)
	else:
		add_child(brick)
	brick.position = Vector2.ZERO

func clear():
	brick.queue_free()
	brick = null

func show_highlight(color: Color):
	color.a = 0.2
	highlight.modulate = color
	highlight.visible = true

func hide_highlight():
	highlight.visible = false
