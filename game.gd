extends Node2D


# Called when the node enters the scene tree for the first time.
func _bob(node):
	var tween = get_tree().create_tween()
	var start = node.position
	tween.set_trans(tween.TRANS_SINE)
	tween.tween_property(
		node, "position", 
		start + Vector2(0., 20.),
		1
	)
	tween.tween_property(
		node, "position", 
		start,
		1
	)
	
	tween.set_loops(-1)

func _ready():
	_bob($ScoreDisplay)
	_bob($FruitDisplay)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
