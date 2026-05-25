extends Sprite2D

# var do robo
var posicao_original_y: float = 0.0

func _ready():
	posicao_original_y = position.y

func comemorar():
	print("Robô: Eba! Acertaste!")
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "position:y", posicao_original_y - 100, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 1.1), 0.2)
	
	tween.tween_property(self, "position:y", posicao_original_y, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
