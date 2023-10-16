extends Node2D

var stats

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_playfield_score_changed(score):
	$CenterContainer/HBoxContainer/VBoxContainer/Score.text = tr("SCORE") + ": %s" % score 


func _on_game_state_changed(state):
	if state == Game.States.GAMEOVER:
		visible = true
	else:
		visible = false # Replace with function body.


func _on_playfield_set_stats(new_stats):
	stats = new_stats
	
	for c in $CenterContainer/HBoxContainer/GridContainer.get_children():
		c.free()
	
	for fruit_type in Fruit.FruitsEnum:
		var icon_control = Control.new()
		icon_control.custom_minimum_size = Vector2(20.,20.)
		var fruit = load("res://fruit.tscn").instantiate()
		fruit.position = Vector2(10.,10.)
		fruit.fruit_type = Fruit.FruitsEnum[fruit_type]
		fruit.display_size = Fruit.SizesEnum.LEGEND
		fruit.freeze = true
		icon_control.add_child(fruit)
		# this next line generates a shit ton of errors but still seems to work
		$CenterContainer/HBoxContainer/GridContainer.add_child(icon_control)
		var dropped_label = Label.new()
		dropped_label.text = "%s" % stats["dropped_fruits"][fruit_type]
		$CenterContainer/HBoxContainer/GridContainer.add_child(dropped_label)
		var made_label = Label.new()
		made_label.text = "%s" % stats["made_fruits"][fruit_type]
		$CenterContainer/HBoxContainer/GridContainer.add_child(made_label)
		var time_label = Label.new()
		time_label.text = "%s" % stats["time_to_fruits"][fruit_type]
		$CenterContainer/HBoxContainer/GridContainer.add_child(time_label)
