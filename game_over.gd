extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_playfield_score_changed(score):
	$CenterContainer/VBoxContainer/Score.text = tr("SCORE") + ":%s" % score 


func _on_game_state_changed(state):
	if state == Game.States.GAMEOVER:
		visible = true
	else:
		visible = false # Replace with function body.
