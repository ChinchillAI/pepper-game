@tool
extends StaticBody2D

@export var width := 670. : set = _set_width
@export var height := 755. : set = _set_height
@export var thickness := 10. : set = _set_thickness


func _set_width(new_width):
	width = new_width
	_create_container()

func _set_height(new_height):
	height = new_height
	_create_container()
	
func _set_thickness(new_thickness):
	thickness = new_thickness
	_create_container()

func _create_container():
	var new_container = PackedVector2Array()
	new_container.append(Vector2(0., 0.))
	new_container.append(Vector2(thickness, 0))
	new_container.append(Vector2(thickness, height))
	new_container.append(Vector2(thickness+width, height))
	new_container.append(Vector2(thickness+width, 0.))
	new_container.append(Vector2(2*thickness+width, 0.))
	new_container.append(Vector2(2*thickness+width, height+thickness))
	new_container.append(Vector2(0., height+thickness))
	
	if is_instance_valid($CollisionPolygon2D) and is_instance_valid($Polygon2D):
		$CollisionPolygon2D.polygon = new_container
		$Polygon2D.polygon = new_container

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_container()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
