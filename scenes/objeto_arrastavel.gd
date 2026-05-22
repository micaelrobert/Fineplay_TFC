extends Area2D

# sinais
signal peca_encaixada
signal peca_clicada
signal peca_errou

# config
@export var slot_correto_nome: String = ""

# var de roisto
@export var textura_brava: Texture2D
@export var textura_feliz: Texture2D

# refs
var sprite_rosto: Sprite2D = null

# var internas
var sendo_arrastado = false
var posicao_inicial = Vector2.ZERO
var esta_travado = false

func _ready():
	await get_tree().process_frame
	posicao_inicial = global_position
	
	if has_node("Rosto"):
		sprite_rosto = get_node("Rosto")
		
		if textura_brava:
			sprite_rosto.texture = textura_brava

func _process(delta):
	if sendo_arrastado:
		global_position = get_global_mouse_position()

func _on_input_event(viewport, event, shape_idx):
	if not esta_travado:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					sendo_arrastado = true
					z_index = 10
					scale = Vector2(1.2, 1.2)
					emit_signal("peca_clicada")
				else:
					sendo_arrastado = false
					verificar_encaixe()

func verificar_encaixe():
	var areas = get_overlapping_areas()
	var encaixou = false
	
	for area in areas:
		if area.is_in_group("slots"):
			if area.name == slot_correto_nome:
				encaixar(area.global_position)
				encaixou = true
				break 
	
	if not encaixou:
		emit_signal("peca_errou")
		voltar_ao_inicio()

func encaixar(posicao_alvo):
	esta_travado = true
	scale = Vector2(1.0, 1.0)
	z_index = 0
	
	if sprite_rosto and textura_feliz:
		sprite_rosto.texture = textura_feliz
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", posicao_alvo, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	emit_signal("peca_encaixada")

func voltar_ao_inicio():
	scale = Vector2(1.0, 1.0)
	z_index = 0
	
	if sprite_rosto and textura_brava:
		sprite_rosto.texture = textura_brava
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", posicao_inicial, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
