@tool
extends Node2D
class_name Playfield

signal score_changed(score)
signal best_score_changed(score)
signal next_fruit_changed(fruit_type)
signal game_state_changed(state)

@export var buffer_top := 30. : set = _set_buffer_top

@export var container_width := 300. : set = _set_container_width
@export var container_height := 600. : set = _set_container_height
@export var container_thickness := 10. : set = _set_container_thickness

@export var dropper_width := 2. : set = _set_dropper_width
@export var player_speed := 200.

@export var player_score := 0 : set = _set_player_score
@export var best_score := 0 : set = _set_best_score
var game_over := false : set = _set_game_over
var last_mouse_position

@export var max_fruit := Fruit.FruitsEnum.TOMATO
@export var current_fruit := Fruit.FruitsEnum.CHERRY
@export var next_fruit := Fruit.FruitsEnum.CHERRY

func _set_buffer_top(new_top):
	buffer_top = new_top
	_create_playfield()
	
func _set_game_over(state):
	game_over = state
	if not Engine.is_editor_hint():
		game_state_changed.emit(game_over)

func _set_container_width(new_width):
	container_width = new_width
	_create_playfield()
	
func _set_container_height(new_height):
	container_height = new_height
	_create_playfield()
	
func _set_container_thickness(new_thickness):
	container_thickness = new_thickness
	_create_playfield()
	
func _set_dropper_width(new_width):
	dropper_width = new_width
	_create_playfield()
	
func _set_player_score(new_score):
	player_score = new_score
	if not Engine.is_editor_hint():
		score_changed.emit(player_score)

func _set_best_score(new_score):
	best_score = new_score
	if not Engine.is_editor_hint():
		best_score_changed.emit(best_score)

func _create_playfield():
	if get_node_or_null("Container") and get_node_or_null("Player"):
		$Container.position.y = buffer_top + $Player/Sprite2D.texture.get_height()
		$Container.width = container_width
		$Container.height = container_height
		$Container.thickness = container_thickness
		
		$Player.position.y = + $Player/Sprite2D.texture.get_height()
		$Player.position.x = container_thickness + container_width / 2
		$Player.dropper_height = container_height + buffer_top
		$Player.dropper_width = dropper_width
		
		var out_polygon = PackedVector2Array([
			Vector2(0., 0.),
			Vector2(0., buffer_top + $Player/Sprite2D.texture.get_height()),
			Vector2(container_width + container_thickness*2, buffer_top + $Player/Sprite2D.texture.get_height()),
			Vector2(container_width + container_thickness*2, 0.),
		])
		$Area2D/CollisionPolygon2D.polygon = out_polygon
		
		_reset_playfield()

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_playfield()
	_load_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _reset_playfield():
	player_score = 0
	current_fruit = randi() % max_fruit as Fruit.FruitsEnum
	$Player.set_fruit(current_fruit)
	next_fruit = randi() % max_fruit as Fruit.FruitsEnum
	if not Engine.is_editor_hint():
		next_fruit_changed.emit(next_fruit)

func _handle_score(points):
	player_score += points
	$MergeSoundPlayer.play()
	if player_score > best_score:
		best_score = player_score
	print("Scored points: {x}".format({"x": points}))

# See https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func _save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_game.store_line(JSON.stringify({"best_score": best_score}))
	
func _load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("Error parsing json savegame")
			continue
		
		var save_data = json.get_data()
		
		best_score = save_data["best_score"]
	

func _physics_process(delta):
	if not Engine.is_editor_hint() and not game_over:
		var current_fruit_radius = $Player/Fruit.fruits_dict[$Player/Fruit.fruit_type].radius
		var mouse_pos = get_local_mouse_position()
		if (
			mouse_pos != last_mouse_position
			and mouse_pos.x > container_thickness + current_fruit_radius 
			and mouse_pos.x < container_thickness + container_width - current_fruit_radius
		):
			$Player.position.x = mouse_pos.x
		last_mouse_position = mouse_pos
		if Input.is_action_pressed("move_left"):
			$Player.position.x = max(
				$Player.position.x - delta * player_speed, 
				container_thickness + current_fruit_radius
			)
		elif  Input.is_action_pressed("move_right"):
			$Player.position.x = min(
				$Player.position.x + delta * player_speed, 
				container_thickness + container_width - current_fruit_radius
			)

func _input(event):
	if not Engine.is_editor_hint():
		if not game_over:
			if event.is_action_pressed("drop"):
				var dropped_fruit = load("res://fruit.tscn").instantiate()
				dropped_fruit.position = $Player.position
				dropped_fruit.fruit_type = current_fruit
				dropped_fruit._create_fruit()
				dropped_fruit.score.connect(_handle_score)
				add_child(dropped_fruit)
				$DropSoundPlayer.play()
				current_fruit = next_fruit
				$Player.set_fruit(current_fruit)
				$Player.position.x = max(
					$Player.position.x, 
					container_thickness + $Player/Fruit.fruits_dict[$Player/Fruit.fruit_type].radius
				)
				$Player.position.x = min(
					$Player.position.x, 
					container_thickness + container_width - $Player/Fruit.fruits_dict[$Player/Fruit.fruit_type].radius
				)
				next_fruit = randi() % max_fruit as Fruit.FruitsEnum
				next_fruit_changed.emit(next_fruit)
		else:
			if event.is_action_pressed("drop"):
				reset()
	if event.is_action_pressed("reset"):
		reset()

func _game_over():
	game_over = true
	$GameOverSoundPlayer.play()
	for c in get_children():
		if c.is_in_group("fruits"):
			c.freeze_fruit()
	_save_game() 
			
func reset():
	for c in get_children():
		if c.is_in_group("fruits"):
			c.queue_free()
	_reset_playfield()
	$ResetGameSoundPlayer.play()
	game_over = false

func _on_area_2d_body_exited(body):
	if body.is_in_group("fruits"):
		body.in_play = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("fruits"):
		if body.in_play:
			print("lost game")
			_game_over()
