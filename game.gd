extends Node2D
class_name Game

signal state_changed(state)

enum States {
	TITLE_SCREEN,
	PLAYING,
	PAUSED,
	GAMEOVER,
	OPTIONS,
	CREDITS
}

var state := States.TITLE_SCREEN : set = _on_set_game_state

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


func _on_set_game_state(new_state):
	state = new_state
	state_changed.emit(state)
