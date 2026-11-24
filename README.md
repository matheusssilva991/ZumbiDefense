# 🧟 Zumbi Defense: A Última Resistência

<p align="center">
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/LÖVE2D-FF1493?style=for-the-badge&logo=lua&logoColor=white" alt="LÖVE2D">
  <img src="https://img.shields.io/badge/Status-Concluído-success?style=for-the-badge" alt="Status">
</p>

## 📖 Sobre o Projeto

**Zumbi Defense: A Última Resistência** é um jogo de defesa de torres (tower defense) desenvolvido em Lua usando o framework LÖVE2D. Defenda a casa contra ondas intermináveis de zumbis usando torres de tiro, torres de lentidão e bombas.

O jogo foi desenvolvido como projeto da disciplina **TAC1 - Tópicos Avançados em Computação**, com foco em desenvolvimento de jogos.

## 🎮 Características

- **4 tipos diferentes de zumbis** com velocidades, dano e vida variados
- **Ondas progressivas** com intervalos para montar a defesa
- **Sistema de torres automáticas** que detectam e atacam zumbis dentro do raio de alcance
- **Bombas de área** que causam dano explosivo em múltiplos inimigos
- **Recorde local** pela maior onda alcançada, com desempate pelo total de abates
- **Animações suaves** utilizando a biblioteca anim8
- **Ambientação sonora** com efeitos de áudio temáticos
- **Efeito visual noturno** para atmosfera tensa e assustadora

## 🕹️ Como Jogar

### Requisitos

- [LÖVE2D](https://love2d.org/) (versão 11.0 ou superior)

### Instalação

1. Clone o repositório:

```bash
git clone https://github.com/matheusssilva991/ZumbiDefense.git
cd ZumbiDefense
```

2. Execute o jogo:

```bash
love .
```

### Controles

- Use o **clique esquerdo** para selecionar uma defesa na loja e outro clique para colocá-la. O círculo mostra a área de atuação no ponto de instalação.
- Use **Esc** ou **clique direito** para cancelar a seleção.
- Use **P** para pausar ou retomar.
- Após a derrota, pressione **R** ou clique em **Reiniciar**.

### Regras

1. A partida começa com **100 de vida**, **60 moedas** e **12 segundos** para preparar a defesa.
2. Depois que todos os zumbis de uma onda forem eliminados ou invadirem a casa, você tem **10 segundos** para se preparar para a próxima onda.
3. Eliminar zumbis rápidos, médios, resistentes e tanques rende **1, 2, 3 e 4 moedas**, respectivamente. A cada **20 abates**, a casa ganha **10 pontos de vida**.
4. A partida termina quando a casa chega a zero. O jogo salva o recorde local pela maior onda alcançada e usa os abates para desempatar.

### Defesas

| Defesa | Preço | Terreno | Efeito |
|---|---:|---|---|
| Torre de tiro | 20 | Grama | 20 de dano a cada 0,8 s, com alcance de 150 px |
| Bomba | 10 | Areia | Explode na hora e causa 80 de dano em um raio de 150 px |
| Torre de lentidão | 25 | Grama | A cada 1 s, reduz por 2 s a velocidade de um alvo a até 130 px. A redução é de 35%. |

As torres priorizam o zumbi mais avançado no caminho. Use a bomba para finalizar grupos que já sofreram dano das torres.

## 🏗️ Estrutura do Projeto

```
ZumbiDefense/
├── main.lua                    # Controles e renderização no LÖVE
├── conf.lua                    # Configurações do LÖVE2D
├── configuracao.lua            # Mapa e parâmetros de balanceamento
├── partida.lua                 # Simulação de combate e ondas
├── recorde.lua                 # Leitura e gravação do recorde local
├── recursos.lua                # Carregamento de imagens, fontes e áudio
├── classes/
│   ├── classic.lua             # Biblioteca de classes OOP
│   ├── anim8.lua               # Biblioteca de animações
│   ├── vector.lua              # Operações com vetores 2D
│   ├── background/
│   │   ├── cenario.lua         # Renderização do mapa
│   │   ├── gameover.lua        # Tela de fim de jogo
│   │   ├── loja.lua            # Sistema de compra de torres
│   │   └── moeda.lua           # Sistema de moedas
│   ├── personagens/
│   │   ├── inimigo.lua         # Lógica dos zumbis
│   │   └── objetivo.lua        # Casa a ser defendida
│   └── torres/
│       ├── torre.lua           # Torres automáticas
│       └── bomba.lua           # Bombas explosivas
├── audio/                      # Efeitos sonoros e música
├── Sprites/                    # Imagens e sprites
├── tests/                      # Verificações da simulação
└── fontes/                     # Fontes personalizadas
```

## Verificações

Na raiz do repositório, execute a bateria da simulação com um interpretador Lua. Ela testa o combate, as compras, o avanço das ondas e a estabilidade entre taxas de quadros.

```bash
lua tests/partida.lua
```

## 🛠️ Tecnologias Utilizadas

- **Linguagem**: [Lua](https://www.lua.org/)
- **Framework**: [LÖVE2D](https://love2d.org/)
- **Bibliotecas**:
  - [classic](https://github.com/rxi/classic) - Sistema de classes OOP
  - [anim8](https://github.com/kikito/anim8) - Animações em sprite sheets
  - [hump.vector](https://hump.readthedocs.io/) - Operações com vetores

## 🎨 Assets

Os sprites, efeitos sonoros e fontes foram selecionados para criar uma atmosfera de terror e tensão, combinando perfeitamente com o tema zumbi apocalíptico.

## 👥 Integrantes

Projeto desenvolvido por:

- **[Matheus Santos Silva](https://github.com/matheusssilva991)**
- **[Philipe Alexandre Silva Lima](https://github.com/phillxandre)**

## 📝 Licença

Este projeto foi desenvolvido para fins educacionais na disciplina TAC1.

## 🎯 Possíveis Melhorias Futuras

- Mais tipos de torres e upgrades
- Power-ups e habilidades especiais
- Níveis com mapas diferentes
- Menu inicial

---

<p align="center">
  Desenvolvido com 💀 por estudantes apaixonados por jogos
</p>
