extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_game_state_changed(state):
	if state == Game.States.TITLE_SCREEN:
		visible = true
	else:
		visible = false
