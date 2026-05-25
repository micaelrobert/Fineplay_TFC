extends Area2D

#config
@export var id_par: int = 0

@export var valor_numero: int = 0

# tipos: entrada e saida / no modo entrada apenas ignora
enum Tipo { SAIDA, CHEGADA, AMBOS }
@export var tipo: Tipo = Tipo.SAIDA

var esta_conectado_saida = false 
var esta_conectado_chegada = false 

@onready var sprite = $Sprite2D

func _ready():
	if tipo == Tipo.CHEGADA and valor_numero == 0:
		sprite.modulate = Color(0, 0, 0, 0.5)
