extends Node2D

var point1 : Vector2 = Vector2(-50, 70)
var width : int = 125
var color : Color = Color.DARK_GREEN

@export var _point2 : Vector2
@export var _point3 : Vector2
@export var _point4 : Vector2
@export var _point5 : Vector2

signal animation_complete

func _ready() -> void:
	_point2 = point1
	_point3 = point1
	_point4 = point1 
	_point5 = point1
	
func play_fade():
	$AnimationPlayer.play("fade")

func play_complete():
	$AnimationPlayer.play("complete")

func _process(_delta):
	#var mouse_position = get_viewport().get_mouse_position()
	#if mouse_position != _point2:
	#	_point2 = mouse_position
	queue_redraw()

func _draw():
	#draw_polyline([point1, _point2, _point3, _point4, _point5], color, width, true)
	draw_line(point1, _point2, color, width, true)
	draw_line(_point2, _point3, color, width, true)
	draw_line(_point3, _point4, color, width, true)
	draw_line(_point4, _point5, color, width, true)
	
func animation_finished():
	animation_complete.emit()
