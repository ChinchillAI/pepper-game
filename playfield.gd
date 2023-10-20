@tool
extends Node2D
class_name Playfield

signal score_changed(score)
signal best_score_changed(score)
signal next_fruit_changed(fruit_type)
signal set_game_state(state)
signal set_stats(stats)

@export var buffer_top := 30. : set = _set_buffer_top

@export var container_width := 300. : set = _set_container_width
@export var container_height := 600. : set = _set_container_height
@export var container_thickness := 10. : set = _set_container_thickness

@export var dropper_width := 2. : set = _set_dropper_width
@export var player_speed := 200.

@export var player_score := 0 : set = _set_player_score
@export var best_score := 0 : set = _set_best_score
# this should really be playfield input accepted now, but w/e
var game_over := false : set = _set_game_over
var can_drop := true
var last_mouse_position

@export var max_fruit := Fruit.FruitsEnum.TOMATO
@export var current_fruit := Fruit.FruitsEnum.CHERRY
@export var next_fruit := Fruit.FruitsEnum.CHERRY

# this will be set by signal
var debug_enabled := false
var danger_zone := false

# stats stuff
var dropped_fruits = {}
var made_fruits = {}
var time_to_fruits = {}
var start_time = 0


func _set_buffer_top(new_top):
	buffer_top = new_top
	_create_playfield()
	
func _set_game_over(state):
	if game_over != state:
		game_over = state
		if not Engine.is_editor_hint():
			if game_over:
				pass
				#set_game_state.emit(Game.States.GAMEOVER)
			else:
				set_game_state.emit(Game.States.PLAYING)

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

func _reset_stats():
	start_time = Time.get_ticks_msec()
	for fruit in Fruit.FruitsEnum:
		dropped_fruits[fruit] = 0
		made_fruits[fruit] = 0
		time_to_fruits[fruit] = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	_create_playfield()
	_reset_stats()
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
	print("Scored points: {x}".format({"x": points}))

func _handle_made(fruit_type):
	made_fruits[Fruit.FruitsEnum.keys()[fruit_type]] += 1
	if time_to_fruits[Fruit.FruitsEnum.keys()[fruit_type]] == -1:
		time_to_fruits[Fruit.FruitsEnum.keys()[fruit_type]] = floor((Time.get_ticks_msec() - start_time) / 1000)

# See https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func _save_game():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_game.store_line(JSON.stringify({
		"best_score": best_score,
		"music_mute": AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),
		"music_vol": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),
		"sfx_mute": AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),
		"sfx_vol": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")),
		"master_mute": AudioServer.is_bus_mute(AudioServer.get_bus_index("Master")),
		"master_vol": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
		"language": TranslationServer.get_locale()
	}))
	
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
		
		if save_data.has("music_mute"):
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), save_data["music_mute"])
		if save_data.has("music_vol"):
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), save_data["music_vol"])
		if save_data.has("sfx_mute"):
			AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), save_data["sfx_mute"])
		if save_data.has("sfx_vol"):
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), save_data["sfx_vol"])
		if save_data.has("master_mute"):
			AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), save_data["master_mute"])
		if save_data.has("master_vol"):
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), save_data["master_vol"])
		if save_data.has("language"):
			TranslationServer.set_locale(save_data["language"])
	

func _physics_process(delta):
	if not Engine.is_editor_hint() and not game_over:
		var current_fruit_radius = $Player/Fruit.fruits_dict[$Player/Fruit.fruit_type].radius
		var mouse_pos = get_local_mouse_position()
		if (
			mouse_pos != last_mouse_position
		):
			$Player.position.x = clamp(
				mouse_pos.x,
				container_thickness + current_fruit_radius,
				container_thickness + container_width - current_fruit_radius
			)
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
			if event.is_action_pressed("drop") and can_drop:
				
				# cooldown for drop
				can_drop = false
				$DropTimer.start()
				
				# stats
				dropped_fruits[Fruit.FruitsEnum.keys()[current_fruit]] += 1
				
				# drop the fruit
				var dropped_fruit = load("res://fruit.tscn").instantiate()
				dropped_fruit.position = $Player.position
				dropped_fruit.fruit_type = current_fruit
				dropped_fruit._create_fruit()
				dropped_fruit.score.connect(_handle_score)
				dropped_fruit.made.connect(_handle_made)
				if time_to_fruits[Fruit.FruitsEnum.keys()[current_fruit]] == -1:
					time_to_fruits[Fruit.FruitsEnum.keys()[current_fruit]] = floor((Time.get_ticks_msec() - start_time) / 1000)
				add_child(dropped_fruit)
				dropped_fruit._on_debug_changed(debug_enabled)
				$DropSoundPlayer.play()
				
				if not danger_zone:
					if _calc_area() > .60:
						$NatsumiDangerPlayer.play()
						danger_zone = true
				else:
					if _calc_area() < .45:
						danger_zone = false
					else:
						var rand_num = randf()
						if rand_num > .6:
							$NatsumiGrunt1Player.play()
						elif rand_num > .3:
							$NatsumiGrunt2Player.play()
				
				# setup next fruit
				current_fruit = next_fruit
				$Player.set_fruit(current_fruit)
				
				# make sure player isn't out of bounds given new radius
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
			if event.is_action_pressed("ui_cancel"):
				game_over = true
				set_game_state.emit(Game.States.PAUSED)
	if event.is_action_pressed("reset"):
		reset()
	if event.is_action_pressed("debug_game_over"):
		set_stats.emit({
			"dropped_fruits": dropped_fruits,
			"made_fruits": made_fruits,
			"time_to_fruits": time_to_fruits,
			"elapsed_time": floor((Time.get_ticks_msec() - start_time) / 1000),
			"score": player_score,
			"best_score": best_score,
			"playfield_coverage": _calc_area()
		})
		set_game_state.emit(Game.States.GAMEOVER)
		if player_score > best_score:
			best_score = player_score
		_game_over()
		#pass

func _game_over():
	game_over = true
	for c in get_children():
		if c.is_in_group("fruits"):
			c.freeze_fruit()
	_save_game() 
			
func _calc_area():
	var max_area = container_height * container_width
	var used_area = 0
	for c in get_children():
		if c.is_in_group("fruits"):
			used_area += PI * pow(c.fruits_dict[c.fruit_type]["radius"],2)
	return used_area / max_area

func reset():
	for c in get_children():
		if c.is_in_group("fruits"):
			c.queue_free()
	_reset_playfield()
	_reset_stats()
	$ResetGameSoundPlayer.play()
	game_over = false
	danger_zone = false

func _on_area_2d_body_exited(body):
	if body.is_in_group("fruits"):
		body.in_play = true

func _on_area_2d_body_entered(body):
	if body.is_in_group("fruits"):
		if body.in_play:
			print("lost game")
			set_stats.emit({
				"dropped_fruits": dropped_fruits,
				"made_fruits": made_fruits,
				"time_to_fruits": time_to_fruits,
				"elapsed_time": floor((Time.get_ticks_msec() - start_time) / 1000),
				"score": player_score,
				"best_score": best_score,
				"playfield_coverage": _calc_area()
			})
			set_game_state.emit(Game.States.GAMEOVER)
			if player_score > best_score:
				best_score = player_score
			_game_over()

func _on_game_state_changed(state):
	if state == Game.States.PLAYING:
		game_over = false
	else:
		game_over = true

func _on_drop_timer_timeout():
	can_drop = true

func _on_options_screen_request_save():
	_save_game()

func _on_game_debug_changed(new_debug):
	debug_enabled = new_debug
	$Container._on_debug_changed(debug_enabled)
	$Player._on_debug_changed(debug_enabled)
	for f in get_children():
		if f.is_in_group("fruits"):
			f._on_debug_changed(debug_enabled)

func _on_options_screen_request_clear_data():
	best_score = 0
	_save_game()
