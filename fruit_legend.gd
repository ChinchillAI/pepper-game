@tool
extends Node2D

@export var radius := 70 : set = _set_radius

func _set_radius(new_radius):
	radius = new_radius
	_create_legend()

func _create_legend():
	for c in get_children():
		if c.is_in_group("fruits"):
			remove_child(c)
	
	for i in range(Fruit.FruitsEnum.size()):
		var angle = (i + 1) * 2*PI / (Fruit.FruitsEnum.size() + 1) - PI/2
		var fruit = load("res://fruit.tscn").instantiate()
		fruit.freeze = true
		fruit.display_size = Fruit.SizesEnum.LEGEND
		fruit.fruit_type = i as Fruit.FruitsEnum
		fruit.position = Vector2(
			cos(angle) * radius,
			sin(angle) * radius
		)
		add_child(fruit)

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_legend()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
