extends Area2D

# Aqui nós vamos dizer qual é o slot correto para esta peça específica
@export var nome_do_slot_correto: String = "" 

var arrastando = false
var posicao_inicial : Vector2
var slot_atual = null
var travado = false # Impede a criança de arrastar a peça depois que já acertou

func _ready():
	posicao_inicial = global_position

func _process(_delta):
	if arrastando and not travado:
		global_position = get_global_mouse_position()

func _input_event(_viewport, event, _shape_idx):
	if travado: 
		return # Se já acertou e travou, ignora os cliques
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				arrastando = true
				z_index = 10
				if owner.has_method("tocar_som_clique"):
					owner.tocar_som_clique()
			else:
				arrastando = false
				z_index = 0
				verificar_soltura()

func verificar_soltura():
	var areas = get_overlapping_areas()
	var soltou_no_slot = false
	
	slot_atual = null 
	
	for area in areas:
		if area.name.begins_with("Slot"):
			soltou_no_slot = true
			
			# VERIFICAÇÃO LÓGICA: É o slot certo para esta peça?
			if area.name == nome_do_slot_correto:
				# ACERTOU!
				slot_atual = area
				travado = true # Trava a peça
				
				# === A SUA IMPLEMENTAÇÃO AQUI ===
				var posicao_final = area.global_position
				
				# Puxa a altura personalizada do slot (se ela existir no script do slot)
				if "altura_da_peca" in area:
					posicao_final.y -= area.altura_da_peca
				else:
					# Valor padrão de segurança caso o script do slot falte
					posicao_final.y -= 40.0 
					
				var tween = create_tween()
				tween.tween_property(self, "global_position", posicao_final, 0.1)
				# ================================
				
				if owner.has_method("tocar_som_acerto"):
					owner.tocar_som_acerto()
					
				owner.verificar_vitoria()
			else:
				# ERROU O TAMANHO! (Ex: Peça grande no slot pequeno)
				voltar_para_inicio()
				
			break # Para de procurar outras áreas e encerra o loop
			
	if not soltou_no_slot:
		voltar_para_inicio() # Soltou no vazio

func voltar_para_inicio():
	slot_atual = null
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicao_inicial, 0.2)
	
	if owner.has_method("tocar_som_erro"):
		owner.tocar_som_erro()
