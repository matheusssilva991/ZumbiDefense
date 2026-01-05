# 🧟 Zumbi Defense: A Última Resistência

<p align="center">
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white" alt="Lua">
  <img src="https://img.shields.io/badge/LÖVE2D-FF1493?style=for-the-badge&logo=lua&logoColor=white" alt="LÖVE2D">
  <img src="https://img.shields.io/badge/Status-Concluído-success?style=for-the-badge" alt="Status">
</p>

## 📖 Sobre o Projeto

**Zumbi Defense: A Última Resistência** é um jogo de defesa de torres (tower defense) desenvolvido em Lua usando o framework LÖVE2D. O jogador precisa defender sua casa contra ondas intermináveis de zumbis, posicionando estrategicamente torres de tiro e bombas para impedir que os mortos-vivos cheguem ao objetivo.

O jogo foi desenvolvido como projeto da disciplina **TAC1 - Tópicos Avançados em Computação**, com foco em desenvolvimento de jogos.

## 🎮 Características

- **4 tipos diferentes de zumbis** com velocidades, dano e vida variados
- **Sistema de torres automáticas** que detectam e atacam zumbis dentro do raio de alcance
- **Bombas de área** que causam dano explosivo em múltiplos inimigos
- **Sistema de economia** baseado em moedas obtidas ao eliminar zumbis
- **Sistema de vida regenerativa** - ganhe vida bônus a cada 20 zumbis eliminados
- **Animações suaves** utilizando a biblioteca anim8
- **Ambientação sonora** com efeitos de áudio temáticos
- **Efeito visual noturno** para atmosfera tensa e assustadora

## 🕹️ Como Jogar

### Requisitos

- [LÖVE2D](https://love2d.org/) (versão 11.0 ou superior)

### Instalação

1. Clone o repositório:

```bash
git clone https://github.com/matheusssilva991/projeto-tower-defense.git
cd projeto-tower-defense
```

1. Execute o jogo:

```bash
love .
```

### Controles

- **Mouse (Clique Esquerdo)**: Comprar e posicionar torres/bombas
- **Interface da Loja**: Clique nos ícones na parte inferior para selecionar:
  - **Torre Automática** ($20): Ataca zumbis automaticamente em um raio de 150px
  - **Bomba Explosiva** ($10): Causa dano em área ao explodir

### Regras

1. **Objetivo**: Impedir que os zumbis cheguem à sua casa
2. **Moedas**: Ganhe moedas ao eliminar zumbis (quantidade varia por tipo)
3. **Posicionamento**:
   - Torres podem ser colocadas apenas em **blocos de grama** (áreas azuis)
   - Bombas podem ser colocadas em **blocos de areia** (o caminho dos zumbis)
4. **Vida**: Sua casa começa com 100 pontos de vida
5. **Bônus**: A cada 20 zumbis eliminados, ganhe +10 de vida
6. **Game Over**: O jogo termina quando a vida da casa chega a zero

## 🏗️ Estrutura do Projeto

```
projeto-tower-defense/
├── main.lua                    # Loop principal do jogo
├── conf.lua                    # Configurações do LÖVE2D
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
└── fontes/                     # Fontes personalizadas
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

- Sistema de ondas progressivas com dificuldade crescente
- Mais tipos de torres e upgrades
- Power-ups e habilidades especiais
- Sistema de pontuação e ranking
- Níveis com mapas diferentes
- Menu inicial e sistema de pause

---

<p align="center">
  Desenvolvido com 💀 por estudantes apaixonados por jogos
</p>
