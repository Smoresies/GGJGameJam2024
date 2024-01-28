extends Control


# Called when the node enters the scene tree for the first time.
func _on_button_pressed():
	SceneManager.SwitchScene("TutorialLevel")


func _on_quit_pressed():
	get_tree().quit()


func _on_main_menu_pressed():
	SceneManager.SwitchScene("MainMenu")


func _on_credits_pressed():
	SceneManager.SwitchScene("Credits")
