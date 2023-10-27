@tool
extends Node2D

const num_items = 7

var reported_scores = []
var current_score = [0, "CHERRY", "CURRENT_GAME"]
var current_natsumi = [0, "CHERRY", "NATSUMI"]


# Called when the node enters the scene tree for the first time.
func _ready():
	reported_scores = load_scores()
	update_scoreboard()

# This entire method is jank af, should probably rework to reserve
# items for current and natsumi instead so we can animate
func update_scoreboard():
	var item_height = $VBoxContainer/Control/LeaderboardItem1.size.y
	$VBoxContainer/Control.custom_minimum_size.y = item_height * num_items
	
	var scoreboard = reported_scores.duplicate()
	scoreboard.append(current_score)
	scoreboard.sort_custom(sort_games)
	var current_index = scoreboard.find(current_score)
	var natsumi_index = scoreboard.find(current_natsumi)

	var num_reported
	if current_index < num_items and natsumi_index < num_items:
		num_reported = num_items
	elif current_index >= num_items and natsumi_index < num_items - 1:
		num_reported = num_items - 1
	elif natsumi_index >= num_items and current_index < num_items - 1:
		num_reported = num_items - 1
	else:
		num_reported = num_items - 2
	
	var pinned = []
	for i in range(num_reported):
		if i < scoreboard.size():
			pinned.append([i+1] + scoreboard[i])
		else:
			pinned.append([99, 0, "CHERRY", "UNKNOWN"])
	if current_index >= num_reported:
		pinned.append([current_index+1] + current_score)
	if natsumi_index >= num_reported:
		pinned.append([natsumi_index+1] + current_natsumi)
	pinned.sort_custom(sort_games)
	pinned.reverse()
	
	var max_item_width = 0
	for i in range(num_items):
		var item = get_node("./VBoxContainer/Control/LeaderboardItem%s" % (i+1))
		item.get_node("./Place").text = "%s" % pinned[i][0]
		item.get_node("./Score").text = "%s" % pinned[i][1]
		item.get_node("./Username").text = "%s" % pinned[i][3]
		item.get_node("./Control/Fruit").fruit_type = Fruit.FruitsEnum[pinned[i][2]]
		
		item.position.y = item_height * i
		max_item_width = max(max_item_width, item.size.x)
		
	$VBoxContainer/Control.custom_minimum_size.x = max_item_width
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func sort_games(a, b):
	if a[0] > b[0]:
		return true
	return false

func load_scores():
	var scores_file = FileAccess.open("res://scores.json", FileAccess.READ)
	var json_string = scores_file.get_as_text()
	var json = JSON.new()
		
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("Error parsing json savegame")
		return
		
	var scores = json.get_data()
	
	var username_count = 0
	var games_count = 0
	var scoreboard = []
	for username in scores.keys():
		username_count += 1
		games_count += scores[username].size()
		scores[username].sort_custom(sort_games)
		var scoreboard_row = scores[username][0] + [username]
		scoreboard.append(scoreboard_row)
		if username == "NATSUMI":
			current_natsumi = scoreboard_row
	scoreboard.sort_custom(sort_games)
	#print( "%s games from %s users loaded." % [games_count, username_count] )
	#print(scoreboard)
	return scoreboard


func _on_playfield_best_fruit_changed(fruit_type):
	if Fruit.FruitsEnum[fruit_type] > Fruit.FruitsEnum[current_score[1]]:
		current_score[1] = fruit_type
	update_scoreboard()


func _on_playfield_score_changed(score):
	current_score[0] = score
	if score == 0:
		current_score[1] = "CHERRY"
	update_scoreboard()
