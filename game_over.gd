extends Node2D

var stats

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer.custom_minimum_size = Vector2(855.,0.)
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2.custom_minimum_size = Vector2(855.,0.)
	$GPUParticles2D.emitting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_playfield_score_changed(score):
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/Score.text = "%s" % score 


func _on_game_state_changed(state):
	if state == Game.States.GAMEOVER:
		visible = true
		$GPUParticles2D.emitting = true
		$GPUParticles2D2.emitting = true
		$GPUParticles2D3.emitting = true
		var tween = get_tree().create_tween()
		
		tween.tween_property($CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer, "custom_minimum_size", Vector2(0.,0.), 0.5)
		tween.parallel().tween_property($CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2, "custom_minimum_size", Vector2(0.,0.), 0.5)
	else:
		visible = false # Replace with function body.
		$GPUParticles2D.emitting = false
		$GPUParticles2D.restart()
		$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer.custom_minimum_size = Vector2(855.,0.)
		$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2.custom_minimum_size = Vector2(855.,0.)


func _on_playfield_set_stats(new_stats):
	stats = new_stats
	
	for c in $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/GridContainer.get_children():
		c.free()
	
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/Score.text = "%s" % stats["score"] 
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/Time.text = "%s" % stats["elapsed_time"]
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/Coverage.text = "%.1f%%" % (stats["playfield_coverage"] * 100)
	
	var best_fruit = Fruit.FruitsEnum.CHERRY
	for fruit_type in stats["time_to_fruits"].keys():
		if stats["time_to_fruits"][fruit_type] >= 0:
			if Fruit.FruitsEnum[fruit_type] > best_fruit:
				best_fruit = Fruit.FruitsEnum[fruit_type]
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/GridContainer/Control/Fruit.fruit_type = best_fruit
	
	for fruit_type in Fruit.FruitsEnum:
		if stats["dropped_fruits"][fruit_type] > 0 or stats["made_fruits"][fruit_type] > 0 or stats["time_to_fruits"][fruit_type] >= 0:
			var icon_control = Control.new()
			icon_control.custom_minimum_size = Vector2(20.,20.)
			var fruit = load("res://fruit.tscn").instantiate()
			fruit.position = Vector2(10.,10.)
			fruit.fruit_type = Fruit.FruitsEnum[fruit_type]
			fruit.display_size = Fruit.SizesEnum.LEGEND
			fruit.freeze = true
			icon_control.add_child(fruit)
			# this next line generates a shit ton of errors but still seems to work
			$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/GridContainer.add_child(icon_control)
			var dropped_label = Label.new()
			dropped_label.text = "%s" % stats["dropped_fruits"][fruit_type]
			$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/GridContainer.add_child(dropped_label)
			var made_label = Label.new()
			made_label.text = "%s" % stats["made_fruits"][fruit_type]
			$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/GridContainer.add_child(made_label)
			var time_label = Label.new()
			time_label.text = "%s" % stats["time_to_fruits"][fruit_type]
			$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/GridContainer.add_child(time_label)
