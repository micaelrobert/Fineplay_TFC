extends "res://scripts/ligue_os_pontos/nivel_ligar_base.gd"


func _mensagem_inicio() -> String:
	return "Minigame Ligue os Números iniciado."


func _randomizar_pontos_por_modo(pontos: Array[Node]) -> void:
	_randomizar_lista_de_nodes(pontos)


func _ponto_pode_iniciar(ponto: Node) -> bool:
	return not bool(ponto.get("esta_conectado_saida")) and _existe_sucessor_disponivel(ponto)


func _conexao_valida(origem: Node, destino: Node) -> bool:
	return (
		int(destino.get("valor_numero")) == int(origem.get("valor_numero")) + 1
		and not bool(destino.get("esta_conectado_chegada"))
	)


func _existe_sucessor_disponivel(origem: Node) -> bool:
	var valor_esperado := int(origem.get("valor_numero")) + 1
	for ponto in pegar_pontos_da_fase():
		if (
			int(ponto.get("valor_numero")) == valor_esperado
			and not bool(ponto.get("esta_conectado_chegada"))
		):
			return true
	return false
