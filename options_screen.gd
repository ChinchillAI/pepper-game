extends Node2D

signal set_game_state(state)
signal set_debug(new_debug)
signal request_save
signal request_clear_data

var game_state

enum Options {
	NATSUMI,
	SFX,
	MUSIC,
	MASTER,
	LANGUAGE,
	DEBUG,
	CLEAR_DATA,
	TITLE
}

var selected_option := Options.SFX
var selected_style : LabelSettings
var unselected_style : LabelSettings

var options_labels
var natsumi_id : int
var music_id : int
var master_id : int
var sfx_id : int
var debug_enabled := false # this will be set by signal

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	
	unselected_style = load("res://standard_font.tres")
	
	selected_style = load("res://standard_font.tres").duplicate()
	selected_style.font_color = Color.YELLOW
	
	options_labels = {
		Options.NATSUMI: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Natsumi,
		Options.SFX: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/SFX,
		Options.MUSIC: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Music,
		Options.MASTER: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Master,
		Options.LANGUAGE: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Language,
		Options.DEBUG: $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/Debug,
		Options.CLEAR_DATA: $CenterContainer/VBoxContainer/ClearData,
		Options.TITLE: $CenterContainer/VBoxContainer/Title
	}
	
	options_labels[selected_option].label_settings = selected_style
	
	sfx_id = AudioServer.get_bus_index("SFX")
	master_id = AudioServer.get_bus_index("Master")
	music_id = AudioServer.get_bus_index("Music")
	natsumi_id = AudioServer.get_bus_index("Natsumi")
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Natsumi.text = "%+.0f db" % AudioServer.get_bus_volume_db(natsumi_id) if not AudioServer.is_bus_mute(natsumi_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id) if not AudioServer.is_bus_mute(music_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id) if not AudioServer.is_bus_mute(master_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id) if not AudioServer.is_bus_mute(sfx_id) else "MUTED"
	$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Debug.text = "ENABLED" if debug_enabled else "DISABLED"
	

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
				Options.NATSUMI:
					AudioServer.set_bus_mute(natsumi_id, false)
					AudioServer.set_bus_volume_db(natsumi_id, AudioServer.get_bus_volume_db(natsumi_id) - 1)
					$NatsumiOhPlayer.play()
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Natsumi.text = "%+.0f db" % AudioServer.get_bus_volume_db(natsumi_id)
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
					$MergeSoundPlayer.play()
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id)
				Options.LANGUAGE:
					var locales = TranslationServer.get_loaded_locales()
					var locale_id = locales.find(TranslationServer.get_locale())
					var next_id = locale_id-1 if locale_id > 0 else locales.size() - 1
					TranslationServer.set_locale(locales[next_id])
				Options.DEBUG:
					debug_enabled = not debug_enabled
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Debug.text = "ENABLED" if debug_enabled else "DISABLED"
					set_debug.emit(debug_enabled)
				_:
					pass
			request_save.emit()
		if event.is_action_pressed("ui_right"):
			match selected_option:
				Options.NATSUMI:
					AudioServer.set_bus_mute(natsumi_id, false)
					AudioServer.set_bus_volume_db(natsumi_id, AudioServer.get_bus_volume_db(natsumi_id) + 1)
					$NatsumiOhPlayer.play()
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Natsumi.text = "%+.0f db" % AudioServer.get_bus_volume_db(natsumi_id)
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
					$MergeSoundPlayer.play()
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id)
				Options.LANGUAGE:
					var locales = TranslationServer.get_loaded_locales()
					var locale_id = locales.find(TranslationServer.get_locale())
					var next_id = locale_id+1 if locale_id < locales.size() - 1 else 0
					# ugly hack to get around en_US not being en etc
					if TranslationServer.get_locale().find(locales[next_id]) != -1:
						next_id += 1
					TranslationServer.set_locale(locales[next_id])
				Options.DEBUG:
					debug_enabled = not debug_enabled
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Debug.text = "ENABLED" if debug_enabled else "DISABLED"
					set_debug.emit(debug_enabled)
				_:
					pass
			request_save.emit()
		if event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			match selected_option:
				Options.TITLE:
					var new_state = Game.States.TITLE_SCREEN if game_state == Game.States.OPTIONS else Game.States.PLAYING
					set_game_state.emit(new_state)
				Options.NATSUMI:
					AudioServer.set_bus_mute(natsumi_id, not AudioServer.is_bus_mute(natsumi_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Natsumi.text = "%+.0f db" % AudioServer.get_bus_volume_db(natsumi_id) if not AudioServer.is_bus_mute(natsumi_id) else "MUTED"
				Options.MUSIC:
					AudioServer.set_bus_mute(music_id, not AudioServer.is_bus_mute(music_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Music.text = "%+.0f db" % AudioServer.get_bus_volume_db(music_id) if not AudioServer.is_bus_mute(music_id) else "MUTED"
				Options.MASTER:
					AudioServer.set_bus_mute(master_id, not AudioServer.is_bus_mute(master_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Master.text = "%+.0f db" % AudioServer.get_bus_volume_db(master_id) if not AudioServer.is_bus_mute(master_id) else "MUTED"
				Options.SFX:
					AudioServer.set_bus_mute(sfx_id, not AudioServer.is_bus_mute(sfx_id))
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/SFX.text = "%+.0f db" % AudioServer.get_bus_volume_db(sfx_id) if not AudioServer.is_bus_mute(sfx_id) else "MUTED"
				Options.DEBUG:
					debug_enabled = not debug_enabled
					$CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Debug.text = "ENABLED" if debug_enabled else "DISABLED"
					set_debug.emit(debug_enabled)
				Options.CLEAR_DATA:
					request_clear_data.emit()
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
