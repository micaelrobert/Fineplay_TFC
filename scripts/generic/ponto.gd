extends Area2D

@export var id_par: int = 0
@export var valor_numero: int = 0

enum Tipo { SAIDA, CHEGADA, AMBOS }
@export var tipo: Tipo = Tipo.SAIDA

var esta_conectado_saida := false
var esta_conectado_chegada := false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
var modulate_original := Color.WHITE


func _ready() -> void:
	input_pickable = true
	if sprite:
		modulate_original = sprite.modulate
		_atualizar_visual_inicial()


func _atualizar_visual_inicial() -> void:
	if not sprite:
		return

	if tipo == Tipo.CHEGADA and valor_numero == 0:
		sprite.modulate = Color(0, 0, 0, 0.5)
	else:
		sprite.modulate = modulate_original


func resetar_conexoes() -> void:
	esta_conectado_saida = false
	esta_conectado_chegada = false
	_atualizar_visual_inicial()


func esta_disponivel_para_pista() -> bool:
	if tipo == Tipo.CHEGADA:
		return not esta_conectado_chegada
	return not esta_conectado_saida
