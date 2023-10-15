extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_playfield_score_changed(score):
	$VBoxContainer/CurrentScore.text = str(score)

func _on_playfield_best_score_changed(score):
	$VBoxContainer/BestScore.text = str(score)
