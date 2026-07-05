# Checklist funcional após atualização

## Preparação

- [ ] Projeto abre sem erros vermelhos no painel Output.
- [ ] Godot reconhece os dois scripts-base novos.
- [ ] Nenhuma cena perdeu o script anexado.
- [ ] Campo `Slot Pequeno Path` da cena invertida foi corrigido no Inspector.

## Classificação — três fases

Para cada fase:

- [ ] peças são randomizadas;
- [ ] escala original permanece correta antes e depois do arraste;
- [ ] mouse funciona;
- [ ] toque funciona;
- [ ] slot correto encaixa e trava;
- [ ] slot incorreto retorna com feedback;
- [ ] soltura fora de slot retorna sem voz de erro;
- [ ] pista 1 destaca a peça;
- [ ] pista 2 destaca o destino;
- [ ] pista 3 desenha a linha;
- [ ] vitória ocorre somente após todas as peças.

## Ligue os Pontos — frutas e animais

- [ ] pontos são randomizados sem trocar lado de origem/destino;
- [ ] primeiro clique abre a linha;
- [ ] segundo clique conclui a ligação;
- [ ] arrastar também conclui a ligação;
- [ ] toque e arraste por toque funcionam;
- [ ] par incorreto apaga a linha e toca erro;
- [ ] soltura fora dos pontos apenas cancela;
- [ ] linha correta permanece visível;
- [ ] quantidade de acertos corresponde ao total configurado.

## Ligue os Números

- [ ] os dez pontos são randomizados;
- [ ] 1→2 é aceito;
- [ ] 1→3 é rejeitado;
- [ ] um ponto que recebeu uma linha ainda pode iniciar a próxima;
- [ ] a fase termina somente após nove conexões;
- [ ] ligação por clique, arraste e toque funciona.

## Ordenação — três fases

- [ ] apenas a peça correta da vez pode ser movimentada;
- [ ] tentativa fora da ordem toca erro e mostra pista;
- [ ] slot errado retorna a peça;
- [ ] slot ocupado é rejeitado;
- [ ] encaixe respeita a altura configurada no slot;
- [ ] fase de três peças segue pequena→média→grande;
- [ ] fase de quatro peças segue pequena→média→grande→gigante;
- [ ] fase invertida segue gigante→grande→média→pequena;
- [ ] pista da peça pequena na fase invertida aponta para `Slot_1`.

## ProfessorRobo

- [ ] idle funciona sem travar;
- [ ] acerto usa comemoração;
- [ ] erro usa reação negativa;
- [ ] pista 1 usa dica/pensamento, não comemoração;
- [ ] pistas 2 e 3 usam gesto de apontar;
- [ ] vitória não é interrompida por animação antiga.

## Áudio

- [ ] sons de clique, acerto, erro e vitória funcionam;
- [ ] vozes não ficam sobrepostas;
- [ ] repetição rápida de erro não dispara várias vozes simultâneas;
- [ ] players sem stream são recuperados quando os arquivos existem;
- [ ] não aparecem erros de recurso ausente no Output.

## Navegação

- [ ] botão voltar funciona em todas as fases;
- [ ] tela de vitória abre uma única vez;
- [ ] próximo nível segue o caminho configurado;
- [ ] reiniciar recarrega corretamente a fase;
- [ ] menu retorna para a seleção esperada.
