extends Control

@export var game_manager: GameManager
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_manager_toggle_game_paused(is_paused: bool):
	if is_paused:
		show()
	else:
		hide()

## ---

func _on_resume_button_pressed():
	$Audio/sfx_ui_pausemenu_resume.play()
	## Wait for the sound to finish playing before unloading the scene: 

func _on_sfx_ui_pausemenu_resume_finished():
	game_manager.game_paused = false

### ---

func _on_quit_button_pressed():
	$Audio/sfx_ui_pausemenu_quit.play()
	## Wait for the sound to finish playing before unloading the scene: 

func _on_sfx_ui_pausemenu_quit_finished():
	get_tree().quit()

## ---

func _on_main_menu_button_pressed():
	$Audio/sfx_mainmenu_buttonclick.play()
	## Wait for the sound to finish playing before unloading this scene

func _on_sfx_mainmenu_buttonclick_finished():
	game_manager.game_paused = false
	SceneManager.SwitchScene("MainMenu")

## ---

func sfx_play_hover_sound():
	$Audio/sfx_mainmenu_buttonhover.play()

func _on_resume_button_mouse_entered():
	sfx_play_hover_sound()

func _on_main_menu_button_mouse_entered():
	sfx_play_hover_sound()

func _on_quit_button_mouse_entered():
	sfx_play_hover_sound()





