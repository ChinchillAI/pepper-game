extends Node2D

signal set_game_state(state)
signal request_save

var game_state

enum Options {
	SFX,
	MUSIC,
	MASTER,
	LANGUAGE,
	TITLE
}

var selected_option := Options.SFX
var selected_style : LabelSettings
var unselected_style : LabelSettings

var options_labels
var music_id : int
var master_id : int
var sfx_id : int

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	unselected_style = LabelSettings.new()
	
	selected_style = LabelSettings.new()
	selected_style.font_color = Color.YELLOW
	
	options_labels = {
		Options.SFX: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/SFX,
		Options.MUSIC: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Music,
		Options.MASTER: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Master,
		Options.LANGUAGE: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Language,
		Options.TITLE: $CenterContainer/VBoxContainer/Title
	}
	
	options_labels[selected_option].label_settings = selected_style
	
	sfx_id = AudioServer.get_bus_index("SFX")
	master_id = AudioServer.get_bus_index("Master")
	music_id = AudioServer.get_bus_index("Music")
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id) if not AudioServer.is_bus_mute(music_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id) if not AudioServer.is_bus_mute(master_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id) if not AudioServer.is_bus_mute(sfx_id) else "MUTED"
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(event):
	if visible:
		if event.is_action_pressed("ui_down"):
			options_labels[selected_option].label_settings = unselected_style
			selected_option = (selected_option + 1 if selected_option < Options.size() - 1 else 0) as Options
			options_labels[selected_option].label_settings = selected_style
		if event.is_action_pressed("ui_up"):
			options_labels[selected_option].label_settings = unselected_style
			selected_option = (selected_option - 1 if selected_option > 0 else Options.size() - 1) as Options
			options_labels[selected_option].label_settings = selected_style
		if event.is_action_pressed("ui_left"):
			match selected_option:
				Options.MUSIC:
					AudioServer.set_bus_mute(music_id, false)
					AudioServer.set_bus_volume_db(music_id, AudioServer.get_bus_volume_db(music_id) - 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id)
				Options.MASTER:
					AudioServer.set_bus_mute(master_id, false)
					AudioServer.set_bus_volume_db(master_id, AudioServer.get_bus_volume_db(master_id) - 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id)
				Options.SFX:
					AudioServer.set_bus_mute(sfx_id, false)
					AudioServer.set_bus_volume_db(sfx_id, AudioServer.get_bus_volume_db(sfx_id) - 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id)
				Options.LANGUAGE:
					var locales = TranslationServer.get_loaded_locales()
					var locale_id = locales.find(TranslationServer.get_locale())
					var next_id = locale_id-1 if locale_id > 0 else locales.size() - 1
					TranslationServer.set_locale(locales[next_id])
				_:
					pass
			request_save.emit()
		if event.is_action_pressed("ui_right"):
			match selected_option:
				Options.MUSIC:
					AudioServer.set_bus_mute(music_id, false)
					AudioServer.set_bus_volume_db(music_id, AudioServer.get_bus_volume_db(music_id) + 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id)
				Options.MASTER:
					AudioServer.set_bus_mute(master_id, false)
					AudioServer.set_bus_volume_db(master_id, AudioServer.get_bus_volume_db(master_id) + 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id)
				Options.SFX:
					AudioServer.set_bus_mute(sfx_id, false)
					AudioServer.set_bus_volume_db(sfx_id, AudioServer.get_bus_volume_db(sfx_id) + 1)
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id)
				Options.LANGUAGE:
					var locales = TranslationServer.get_loaded_locales()
					var locale_id = locales.find(TranslationServer.get_locale())
					var next_id = locale_id+1 if locale_id < locales.size() - 1 else 0
					# ugly hack to get around en_US not being en etc
					if TranslationServer.get_locale().find(locales[next_id]) != -1:
						next_id += 1
					TranslationServer.set_locale(locales[next_id])
				_:
					pass
			request_save.emit()
		if event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			match selected_option:
				Options.TITLE:
					var new_state = Game.States.TITLE_SCREEN if game_state == Game.States.OPTIONS else Game.States.PLAYING
					set_game_state.emit(new_state)
				Options.MUSIC:
					AudioServer.set_bus_mute(music_id, not AudioServer.is_bus_mute(music_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id) if not AudioServer.is_bus_mute(music_id) else "MUTED"
				Options.MASTER:
					AudioServer.set_bus_mute(master_id, not AudioServer.is_bus_mute(master_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id) if not AudioServer.is_bus_mute(master_id) else "MUTED"
				Options.SFX:
					AudioServer.set_bus_mute(sfx_id, not AudioServer.is_bus_mute(sfx_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id) if not AudioServer.is_bus_mute(sfx_id) else "MUTED"
				_:
					pass
			request_save.emit()
		if event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			var new_state = Game.States.TITLE_SCREEN if game_state == Game.States.OPTIONS else Game.States.PLAYING
			set_game_state.emit(new_state)


func _on_game_state_changed(state):
	if state == Game.States.OPTIONS or state == Game.States.PAUSED:
		visible = true
	else:
		visible = false
