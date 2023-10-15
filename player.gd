@tool
extends Node2D

@export var dropper_width := 3 : set = _set_dropper_width
@export var dropper_height := 100 : set = _set_dropper_height
@export var dropper_color := Color.AQUA : set = _set_dropper_color

@export var sprite_size : Vector2
@export var sprite_offset := Vector2.ZERO : set = _set_sprite_offset

func _set_sprite_offset(new_offset):
	sprite_offset = new_offset
	_create_dropper()

func _set_dropper_width(new_width):
	dropper_width = new_width
	_create_dropper()
	
func _set_dropper_height(new_height):
	dropper_height = new_height
	_create_dropper()
	
func _set_dropper_color(new_color):
	dropper_color = new_color
	_create_dropper()

func _create_dropper():
	var dropper = PackedVector2Array([
		Vector2(-dropper_width/2., 0.),
		Vector2(-dropper_width/2., dropper_height),
		Vector2(dropper_width/2., dropper_height),
		Vector2(dropper_width/2., 0)
	])
	
	if get_node_or_null("Polygon2D") and get_node_or_null("Sprite2D"):
		$Polygon2D.polygon = dropper
		$Polygon2D.color = dropper_color
		
		var compressed = load("res://images/makoto.png")
		var image = compressed.get_image()
		var texture = ImageTexture.create_from_image(image)
		
		$Sprite2D.texture = texture
		$Sprite2D.offset = sprite_offset

func set_fruit(fruit_type):
	$Fruit.fruit_type = fruit_type

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_dropper()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
