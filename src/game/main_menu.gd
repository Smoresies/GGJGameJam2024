extends Control

func _on_button_pressed():
	$Audio/music_mainmenu.stop()
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

## --- 

func _on_main_menu_pressed():
	$Audio/sfx_ui_mainmenu_buttonclick.play()
	## Wait for the  journal pages to turn:

func _on_sfx_ui_mainmenu_buttonclick_finished():
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

func sfx_play_hover_sound():
	$Audio/sfx_ui_mainmenu_buttonhover.play()

