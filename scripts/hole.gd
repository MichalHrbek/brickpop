class_name Hole extends Node

var brick: Node2D = null
@onready
var highlight: Node2D = %BrickHighlight

func fill(_brick: Node2D):
	brick = _brick
	brick.reparent(self)
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
