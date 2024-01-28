extends Control

func _ready():
	## Play the opening audio cue:
	$Audio/sfx_ui_mainmenu_opening.play()
	## Reveal the team logo
	## Journal comes into frame, opens and we see the menu

func _on_sfx_ui_mainmenu_opening_finished():
	## Now we play the main menu theme
	$Audio/music_mainmenu.play()

## ---

func _on_button_pressed():
	$Audio/sfx_ui_mainmenu_play.play() 
	## Wait for sound to finish...

func _on_sfx_ui_mainmenu_play_finished():
	SceneManager.SwitchScene("TutorialLevel")

## ---

func _on_quit_pressed():
	$Audio/sfx_ui_mainmenu_quit.play()
	##  Wait for the journal to shut before quitting. See func below
	## get_tree().quit()

func _on_sfx_ui_mainmenu_quit_finished():
	get_tree().quit()

func _on_main_menu_pressed():
	sfx_play_click_sound()
	## Wait for the  journal pages to turn:
	SceneManager.SwitchScene("MainMenu")

## ---

func _on_credits_pressed():
	$Audio/sfx_ui_mainmenu_credits.play()
	## Wat for the sound to finish before changing scenes: 
	
func _on_sfx_ui_mainmenu_credits_finished():
	SceneManager.SwitchScene("Credits")

## ---

func _on_button_mouse_entered():
	sfx_play_hover_sound()

func _on_credits_mouse_entered():
	sfx_play_hover_sound()

func _on_quit_mouse_entered():
	sfx_play_hover_sound()

## Custom functions for audio:
func sfx_play_click_sound():
	$Audio/sfx_ui_mainmenu_buttonclick.play()

func sfx_play_hover_sound():
	$Audio/sfx_ui_mainmenu_buttonhover.play()




