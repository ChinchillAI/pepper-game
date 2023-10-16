@tool
class_name Fruit
extends RigidBody2D

signal score(points)
signal made(fruit_type)

enum FruitsEnum {
	CHERRY,
	STRAWBERRY,
	GRAPE,
	ORANGE,
	TOMATO,
	APPLE,
	CANTELOPE,
	PEACH,
	PINEAPPLE,
	MELON,
	WATERMELON
}
@export var fruit_type := FruitsEnum.CHERRY : set = _set_fruit_type

enum SizesEnum {
	FULL,
	SMALL,
	LEGEND
}
@export var display_size := SizesEnum.FULL : set = _set_display_size

var polygon_points := 32

var in_play := false
var freeze_me := false

func _create_texture(path):
	#var image = Image.load_from_file(path)
	#var texture = ImageTexture.create_from_image(image)
	var compressed = load(path)
	var image = compressed.get_image()
	var texture = ImageTexture.create_from_image(image)
	return texture

var screen_height = 480.

var fruits_dict = {
	FruitsEnum.CHERRY:     { 
		"radius": 20./480./2.*screen_height,  
		"color": Color.DARK_RED,
		"texture": _create_texture("res://images/month_new.png")
	},
	FruitsEnum.STRAWBERRY: { 
		"radius": 30./480./2.*screen_height,  
		"color": Color.INDIAN_RED,
		"texture": _create_texture("res://images/month_1.png")
	},
	FruitsEnum.GRAPE:      { 
		"radius": 40./480./2.*screen_height,  
		"color": Color.PURPLE,
		"texture": _create_texture("res://images/month_2.png")
	},
	FruitsEnum.ORANGE:     { 
		"radius": 45./480./2.*screen_height,  
		"color": Color.ORANGE,
		"texture": _create_texture("res://images/month_6.png")
	},
	FruitsEnum.TOMATO:     { 
		"radius": 60./480./2.*screen_height,  
		"color": Color.ORANGE_RED,
		"texture": _create_texture("res://images/month_12.png")
	},
	FruitsEnum.APPLE:      { 
		"radius": 75./480./2.*screen_height,  
		"color": Color.RED,
		"texture": _create_texture("res://images/month_24.png")
	},
	FruitsEnum.CANTELOPE:  { 
		"radius": 85./480./2.*screen_height,  
		"color": Color.YELLOW,
		"texture": _create_texture("res://images/month_36.png")
	},
	FruitsEnum.PEACH:      { 
		"radius": 105./480./2.*screen_height,  
		"color": Color.PINK,
		"texture": _create_texture("res://images/month_48.png")
	},
	FruitsEnum.PINEAPPLE:  { 
		"radius": 120./480./2.*screen_height,  
		"color": Color.GOLD,
		"texture": _create_texture("res://images/red_pepper.png")
	},
	FruitsEnum.MELON:      { 
		"radius": 145./480./2.*screen_height, 
		"color": Color.GREEN_YELLOW,
		"texture": _create_texture("res://images/yellow_pepper.png")
	},
	FruitsEnum.WATERMELON: { 
		"radius": 160./480./2.*screen_height, 
		"color": Color.GREEN,
		"texture": _create_texture("res://images/green_pepper.png")
	},
}

func _set_display_size(new_size):
	display_size = new_size
	_create_fruit()

func _set_fruit_type(new_fruit_type):
	fruit_type = new_fruit_type
	_create_fruit()

func _promote_fruit():
	fruit_type = fruit_type + 1 as FruitsEnum

func _create_fruit():
	var new_collidor = CircleShape2D.new()
	
	var fruit_radius
	match display_size:
		SizesEnum.FULL:
			fruit_radius = fruits_dict[fruit_type].radius
		SizesEnum.LEGEND:
			fruit_radius = fruits_dict[0].radius
	
	new_collidor.radius = fruit_radius
	
	var debug_polygon = PackedVector2Array()
	for i in range(polygon_points):
		var angle = i * 2*PI / polygon_points
				
		debug_polygon.append(Vector2(
			cos(angle) * fruit_radius,
			sin(angle) * fruit_radius
		))
	
	if get_node_or_null("CollisionShape2D") and get_node_or_null("Polygon2D") and get_node_or_null("Sprite2D"):
		$CollisionShape2D.shape = new_collidor
		$Polygon2D.polygon = debug_polygon
		$Polygon2D.color = fruits_dict[fruit_type].color
		$Sprite2D.texture = fruits_dict[fruit_type].texture
		$Sprite2D.texture.set_size_override(Vector2(fruit_radius*2, fruit_radius*2))

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_fruit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func freeze_fruit():
	freeze_me = true

func _physics_process(_delta):
	if freeze_me:
		freeze = true
		linear_velocity = Vector2.ZERO
		angular_velocity = 0
	else:
		for body in get_colliding_bodies():
			_on_body_entered(body)

func _on_body_entered(body):
	if body.is_in_group("fruits"):
		if body.fruit_type == fruit_type:
#			print("{a} collided with {b}".format({"a": body.fruit_type, "b": fruit_type}))
			body.free()
			call_deferred("_promote_fruit")
			score.emit(pow(2,fruit_type + 1) - 1)
			made.emit(fruit_type + 1)
		else:
			if not freeze:
				var overlap = position.distance_to(body.position) - body.fruits_dict[body.fruit_type].radius - fruits_dict[fruit_type].radius
				body.apply_impulse(overlap*5000 * position.direction_to(body.position))	
#		else:
#			print("{a} collided with {b}".format({"a": body.fruit_type, "b": fruit_type}))
#	else:
#		print("collided with floor")
