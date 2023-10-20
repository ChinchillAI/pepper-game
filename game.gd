extends Node2D
class_name Game

signal state_changed(state)
signal debug_changed(debug_enabled)

enum States {
	TITLE_SCREEN,
	PLAYING,
	PAUSED,
	GAMEOVER,
	OPTIONS,
	CREDITS
}

var state := States.TITLE_SCREEN : set = _on_set_game_state
var debug_enabled := false : set = _on_set_debug_enabled

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

func _on_set_debug_enabled(new_debug):
	debug_enabled = new_debug
	debug_changed.emit(debug_enabled)

func _on_set_game_state(new_state):
	state = new_state
	$Label.visible = true if new_state == Game.States.PLAYING else false
	state_changed.emit(state)


func _on_options_screen_set_debug(new_debug):
	debug_enabled = new_debug
