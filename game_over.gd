extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_playfield_score_changed(score):
	$CenterContainer/VBoxContainer/Score.text = "Score: " + str(score) # Replace with function body.


func _on_playfield_game_state_changed(state):
	if state:
		visible = true
	else:
		visible = false # Replace with function body.
