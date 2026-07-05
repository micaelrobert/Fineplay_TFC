# FINEPLAY

Jogo digital educacional desenvolvido para apoiar o exercício do raciocínio lógico-matemático de crianças dos anos iniciais do Ensino Fundamental.

O projeto foi construído como um **Produto Mínimo Viável (MVP)** utilizando a **Godot Engine 4.6.x** e a linguagem **GDScript**.

## Sobre o projeto

O FINEPLAY transforma atividades de classificação, correspondência, sequenciação e seriação em experiências interativas com feedback visual e sonoro.

O jogador percorre três módulos, cada um composto por três níveis de dificuldade:

1. **Formas, cores e categorias**
2. **Ligue os pontos**
3. **Ordenação por tamanho**

O projeto foi desenvolvido como Trabalho de Conclusão de Curso de Engenharia de Software da Universidade de Vassouras — Campus Saquarema.

## Objetivo

Desenvolver um jogo digital lúdico, acessível e tecnicamente estruturado para apoiar o exercício de habilidades relacionadas ao raciocínio lógico-matemático, especialmente:

- classificação por atributos;
- identificação e associação de formas;
- correspondência visual;
- sequenciação numérica;
- comparação e ordenação por tamanho;
- percepção visual;
- atenção e resolução de problemas.

## Público-alvo

Crianças de **7 a 9 anos**, correspondentes aos anos iniciais do Ensino Fundamental.

O jogo também pode ser utilizado como recurso complementar por professores, responsáveis e mediadores, respeitando-se que a versão atual é um MVP e ainda não constitui uma ferramenta de diagnóstico ou avaliação pedagógica.

## Minijogos

### 1. Formas, cores e categorias

Módulo baseado em arrastar e soltar.

- **Nível 1 — Formas:** associação de figuras aos espaços correspondentes.
- **Nível 2 — Cores:** classificação de peças pelo atributo cromático.
- **Nível 3 — Categorias:** agrupamento de elementos por pertencimento semântico.

### 2. Ligue os pontos

Módulo de correspondência e sequenciação por linhas.

- **Nível 1 — Frutas:** ligação de elementos correspondentes.
- **Nível 2 — Animais:** associação visual entre pares.
- **Nível 3 — Números:** ligação dos números em ordem crescente.

A interação pode ser realizada por arraste ou por seleção sequencial dos pontos.

### 3. Ordenação por tamanho

Módulo baseado em comparação e seriação.

- **Nível 1:** ordenação de três elementos.
- **Nível 2:** ordenação de quatro elementos.
- **Nível 3:** ordenação invertida, do maior para o menor.

## Principais funcionalidades

- nove fases jogáveis;
- navegação entre menu, seleção, níveis e tela de vitória;
- suporte a mouse e toque;
- mecânicas de arrastar e soltar;
- conexão de pontos por arraste ou clique;
- validação automática das respostas;
- retorno de peças incorretas por animação;
- bloqueio de ações fora da ordem esperada;
- pistas progressivas;
- feedback sonoro de clique, acerto, erro e vitória;
- feedback visual pelo personagem ProfessorRobo;
- linhas vetoriais com pré-visualização;
- animações e partículas de conclusão;
- interface vertical responsiva;
- componentes reutilizáveis e controladores-base.

## Alinhamento à BNCC

As mecânicas do FINEPLAY dialogam principalmente com habilidades de Matemática dos anos iniciais:

| Código | Relação com o FINEPLAY |
|---|---|
| EF01MA01 | Uso dos números como indicadores de ordem no nível de sequência numérica. |
| EF01MA09 | Organização e ordenação por atributos como cor, forma e medida. |
| EF01MA15 | Comparação de grandezas visuais para ordenar elementos por tamanho. |
| EF02MA09 | Construção de sequência numérica crescente no módulo Ligue os Pontos. |
| EF02MA15 | Reconhecimento e comparação de figuras planas no nível de formas. |

O jogo atua como recurso de exercício e consolidação. A correspondência não significa que cada habilidade seja contemplada integralmente em todos os seus aspectos.

## Tecnologias utilizadas

- **Godot Engine 4.6.x**
- **GDScript**
- sistema de cenas e nós da Godot;
- sinais para comunicação entre componentes;
- `Area2D` para objetos interativos e detecção;
- `Line2D` para conexões;
- `Tween` para animações;
- áudio e vozes em recursos `AudioStream`;
- Git e GitHub para versionamento.

## Arquitetura

O projeto utiliza a arquitetura baseada em cenas e nós da Godot.

A lógica está organizada em:

- cenas de navegação;
- cenas dos minijogos;
- peças, slots e pontos interativos;
- scripts controladores dos níveis;
- controladores-base reutilizáveis;
- sistemas auxiliares de áudio, pistas, linhas e responsividade.

### Componentes principais

- **HintManager:** controla o tempo, os níveis e a apresentação das pistas.
- **FeedbackAudio:** centraliza efeitos sonoros e vozes.
- **LineRenderer:** cria, atualiza e finaliza as linhas dos níveis de ligação.
- **ProfessorRobo:** apresenta reações visuais de repouso, dica, acerto, erro e vitória.
- **NivelLigarBase:** concentra comportamentos compartilhados dos níveis de ligação.
- **NivelOrdenacaoBase:** concentra comportamentos compartilhados dos níveis de ordenação.
- **ResponsividadeUniversal:** adapta a composição visual à resolução disponível.

## Estrutura geral do repositório

```text
Fineplay_TFC/
├── assets/                 # Imagens, áudios, fontes e demais recursos
├── scenes/                 # Menus, níveis, objetos e telas
├── scripts/                # Lógica em GDScript
│   ├── ligue_os_pontos/
│   └── ordenacao/
├── project.godot           # Configuração principal do projeto
└── README.md
```

A estrutura interna pode conter outras subpastas de acordo com a organização dos módulos e dos recursos.

## Requisitos para desenvolvimento

- Godot Engine **4.6.2** ou versão 4.6.x compatível;
- sistema operacional compatível com a Godot;
- Git, opcionalmente, para clonar e versionar o projeto.

## Como executar

### 1. Clonar o repositório

```bash
git clone https://github.com/micaelrobert/Fineplay_TFC.git
cd Fineplay_TFC
```

### 2. Abrir na Godot

1. Abra a Godot Engine.
2. Selecione **Importar**.
3. Escolha o arquivo `project.godot`.
4. Aguarde a importação dos assets.
5. Execute o projeto com `F6` ou `F5`.

### 3. Conferir os recursos

Na primeira abertura, aguarde a conclusão da importação. Caso a Godot indique algum recurso ausente, confirme se os arquivos de áudio, imagens e fontes estão nos caminhos esperados.

## Controles

### Computador

- clique para selecionar botões e pontos;
- clique e arraste para movimentar peças;
- clique no ponto de origem e depois no destino como alternativa à ligação por arraste.

### Dispositivo com tela sensível ao toque

- toque para selecionar;
- toque e arraste para mover peças;
- toque sequencialmente nos pontos para realizar conexões.

## Exportação

O projeto pode ser exportado para:

- Windows;
- Android.

Antes de gerar uma build:

1. execute todas as fases no editor;
2. confirme os caminhos dos recursos;
3. verifique se o depurador não apresenta erros;
4. teste mouse e toque;
5. confira a responsividade;
6. valide sons, pistas e tela de vitória.

## Testes recomendados

Para cada uma das nove fases, verificar:

- entrada e saída da cena;
- interação por mouse;
- interação por toque;
- resposta correta;
- resposta incorreta;
- funcionamento da pista;
- reação do ProfessorRobo;
- reprodução dos áudios;
- condição de vitória;
- avanço, repetição e retorno ao menu.

## Avaliação realizada

Foi conduzida uma avaliação preliminar de usabilidade com **10 usuários adultos voluntários**, voltada à clareza da interface, navegação, compreensão das mecânicas e funcionamento geral do protótipo.

Essa avaliação não constitui validação pedagógica com crianças e não comprova impacto sobre a aprendizagem.

## Limitações atuais

- ausência de cadastro e autenticação;
- ausência de banco de dados;
- ausência de histórico individual;
- ausência de relatórios para professores ou responsáveis;
- conteúdo pedagógico limitado ao escopo inicial do MVP;
- necessidade de avaliação com crianças do público-alvo;
- recursos de acessibilidade ainda passíveis de ampliação.

## Trabalhos futuros

- testes supervisionados com crianças de 7 a 9 anos;
- painel de acompanhamento de desempenho;
- registro de erros, tentativas, tempo e uso de pistas;
- novos módulos de matemática;
- opções de contraste e redução de estímulos;
- legendas e leitura de instruções;
- ajustes de volume;
- expansão da compatibilidade entre plataformas;
- validação pedagógica em ambiente escolar.

## Demonstração e build

- **Build para Windows:**  
  https://drive.google.com/drive/folders/1OI9vCwz-fY74SXnBGur1i4IFB72X1nGM?usp=sharing

- **Vídeo demonstrativo:**  
  https://drive.google.com/drive/u/1/folders/16HNlJEN2hBca3NHy-aLfmy6sE2JIkvyP

## Contexto acadêmico

**Título:** FINEPLAY: Desenvolvimento de Jogo Digital para o Raciocínio Lógico nos Anos Iniciais do Ensino Fundamental

**Curso:** Engenharia de Software  
**Instituição:** Universidade de Vassouras — Campus Saquarema  
**Autor:** Micael Robert Andrade Lima  
**Orientador:** Prof. Sergio de Olivera Santtos
**Ano:** 2026

## Direitos autorais e utilização

Copyright © 2026 Micael Robert Andrade Lima. Todos os direitos reservados.

Este repositório é disponibilizado exclusivamente para apresentação,
avaliação e consulta acadêmica.

Não é permitida a cópia, reutilização, modificação, redistribuição,
publicação de versões derivadas ou utilização comercial do código, das
cenas, dos scripts, dos assets ou da estrutura do projeto sem autorização
prévia e expressa do autor.

A disponibilização pública do repositório não constitui concessão de
licença para reutilização.

Consulte o arquivo [COPYRIGHT.md](COPYRIGHT.md) para conhecer as condições
de utilização.
