extends Node

@onready var click_ui = $SomClickUI

func play_click_ui():
	# variação de pitch para não ficar robótico
	click_ui.pitch_scale = randf_range(0.9, 1.1)
	click_ui.play()
