-- ============================================
-- CONSTANTES E CONFIGURAÇÕES GLOBAIS
-- ============================================

-- Dimensões da tela do jogo
LARGURA_TELA, ALTURA_TELA = love.graphics.getDimensions()
TAM_BLOCO = 400  -- Tamanho de cada bloco do mapa (antes de escalar)

-- Mapa do jogo (6 linhas x 8 colunas)
-- 1 = Grama (onde torres podem ser colocadas)
-- 2 = Areia/Caminho (onde zumbis andam e bombas podem ser colocadas)
-- 3 = Madeira (área decorativa)
-- 4 = Espaço da loja para torre
-- 5 = Espaço da loja para bomba
mapa = {
    {1,1,1,1,1,1,1,1},
    {1,1,2,2,2,1,2,2},
    {1,1,2,1,2,1,2,1},
    {1,1,2,1,2,1,2,1},
    {3,2,2,1,2,2,2,1},
    {3,3,3,3,4,5,3,3}
}

-- Tipos de inimigos com suas características
-- velocidade: pixels por segundo
-- dano: pontos de dano ao objetivo
-- vida: pontos de vida do inimigo
-- qtd_moeda_gerada: quantidade de moedas ao eliminar
-- op: linha da sprite sheet do inimigo
tipos_inimigos = {
    {velocidade=80, dano=5, vida=100, qtd_moeda_gerada=2, op=1},   -- Zumbi rápido e fraco
    {velocidade=15, dano=20, vida=400, qtd_moeda_gerada=8, op=2},  -- Zumbi lento e forte
    {velocidade=40, dano=10, vida=200, qtd_moeda_gerada=4, op=3},  -- Zumbi médio
    {velocidade=25, dano=15, vida=300, qtd_moeda_gerada=6, op=4}   -- Zumbi resistente
}

-- ============================================
-- FUNÇÃO DE INICIALIZAÇÃO DO JOGO
-- ============================================
function love.load()
    -- Carregar bibliotecas externas
    Classe = require "classes/classic"          -- Sistema de classes OOP
    Vector = require "classes/vector"          -- Manipulação de vetores 2D
    anim = require "classes/anim8"             -- Sistema de animações

    -- Carregar módulos do jogo
    moeda = require "classes/background/moeda"
    cenario = require "classes/background/cenario"
    objetivo = require "classes/personagens/objetivo"
    inimigo = require "classes/personagens/inimigo"
    gameover = require "classes/background/gameover"
    torre = require "classes/torres/torre"
    bomba = require "classes/torres/bomba"
    loja = require "classes/background/loja"
    conf = require "/conf"

    -- Configurar áudios do jogo
    music_ambience = love.audio.newSource("audio/terror-ambience-7003.mp3", "stream")
    audio_zumbi = love.audio.newSource("audio/zombie-growl-3-6863.mp3", "stream")
    audio_morte = love.audio.newSource("audio/goresplat-7088.mp3", "static")

    music_ambience:setVolume(0.01)
    music_ambience:play()  -- Iniciar música de fundo

    -- Instanciar objetos do jogo
    gameover = Gameover()
    moeda = Moeda()
    fundo = Cenario()
    casa = Objetivo()
    loja = Loja()

    -- Inicializar listas de entidades
    enemys = {}          -- Lista de inimigos ativos
    tempo_gerar = 0      -- Timer para geração de novos inimigos
    torres = {}          -- Lista de torres colocadas
    bombas = {}          -- Lista de bombas ativas

    -- Gerar primeiro inimigo aleatório
    zumbi_sorteado = love.math.random(1, 4)
    table.insert(enemys, Inimigo("inimigos", tipos_inimigos[zumbi_sorteado]))

    -- Estatísticas do jogo
    zumbisMortos = 0     -- Contador de zumbis eliminados
    zumbisEntrou = 0     -- Contador de zumbis que chegaram à casa
    vida_bonus = 0       -- Contador para bônus de vida

    -- Variáveis de controle do mouse
    pontos = 0
    posicao_mouse = Vector(0, 0)   -- Posição do mouse na tela
    pos_matriz = Vector(1, 1)      -- Posição no mapa (grid)
    tempo_mouse = 0                -- Timer para detectar cliques

    mouse = {}
    pegouTorre = false             -- Flag para indicar se pegou uma torre da loja

    -- Configurar fonte do jogo
    fonte = love.graphics.setNewFont("fontes/Pixeled.ttf", 20)
end

-- ============================================
-- FUNÇÃO DE ATUALIZAÇÃO DO JOGO (LOOP PRINCIPAL)
-- ============================================
function love.update(dt)
    -- Atualizar elementos visuais e do cenário
    fundo:update(dt)
    moeda:update(dt)
    casa:update(dt)
    loja:update(dt)

    -- Habilitar áudio dos zumbis quando houver inimigos em jogo
    if #enemys >= 1 then
        audio_zumbi:setVolume(0.02)
        audio_zumbi:play()
    end

    -- Atualizar posição do mouse
    mouse.x = love.mouse.getX()
    mouse.y = love.mouse.getY()

    -- Sistema de colocação de torres e bombas
    if love.mouse.isDown(1) and tempo_mouse == 1 and pegouTorre == true then
        -- Converter posição do mouse para coordenadas da matriz do mapa
        pos_matriz.x, pos_matriz.y = math.floor(posicao_mouse.y/100)+1, math.floor(posicao_mouse.x/100)+1

        -- Definir validação e preço baseado no tipo de torre
        local pos_valida
        local preco
        if loja.tipo_torre == 1 then
            pos_valida = 1  -- Torre só pode ser colocada em grama
            preco = 20
        else
            pos_valida = 2  -- Bomba só pode ser colocada em areia
            preco = 10
        end

        -- Validar se a posição é válida, há dinheiro suficiente e espaço livre
        if mapa[pos_matriz.x][pos_matriz.y] == pos_valida and moeda.quantidade >= preco and checa_espaco_livre() then
            -- Alinhar posição ao grid
            posicao_mouse.x = math.floor(posicao_mouse.x / 100) * 100
            posicao_mouse.y = math.floor(posicao_mouse.y / 100) * 100 - 20

            -- Criar torre ou bomba
            if loja.tipo_torre == 1 then
                table.insert(torres, Torre(posicao_mouse.x, posicao_mouse.y))
            else
                table.insert(bombas, Bomba(posicao_mouse.x, posicao_mouse.y))
            end

            -- Deduzir custo e resetar seleção
            moeda.quantidade = moeda.quantidade - preco
            pegouTorre = false
        end
        tempo_mouse = 0
    end

    -- Atualizar todas as torres
    for i=#torres, 1, -1 do
        torres[i]:update(dt)
    end

    -- Atualizar todas as bombas e remover as que já explodiram
    for i=#bombas, 1, -1 do
        bombas[i]:update(dt)

        if bombas[i].tempo_bomba > 0.9 then
            table.remove(bombas, i)  -- Remove bomba após animação
        end
    end

    -- Sistema de geração de inimigos (enquanto a casa tiver vida)
    if casa.vida > 0 then
        if tempo_gerar > 0.8 then
            tempo_gerar = 0

            -- 25% de chance de gerar um novo inimigo
            local gera = love.math.random(0, 3)

            if gera == 1 then
                zumbi_sorteado = love.math.random(1, 4)  -- Escolher tipo aleatório
                local enemy = Inimigo("inimigos", tipos_inimigos[zumbi_sorteado])

                table.insert(enemys, enemy)
            end
        else
            tempo_gerar = tempo_gerar + dt
        end

        -- Atualizar movimento e vida dos zumbis
        atualiza_zumbi_casa(dt)
    end

end

-- ============================================
-- FUNÇÃO DE RENDERIZAÇÃO
-- ============================================
function love.draw()
    -- Desenhar cenário de fundo
    fundo:draw()
    moeda:draw()
    casa:draw()

    -- Aplicar filtro escuro (efeito noturno)
    love.graphics.setColor(0, 0, 0.2, 0.6)
    love.graphics.rectangle("fill", 0, 0, 800, 500)
    love.graphics.setColor(1, 1, 1)

    -- Desenhar todas as torres
    for i=#torres, 1, -1 do
        torres[i]:draw()
    end

    -- Desenhar todos os inimigos
    for i=#enemys, 1, -1 do
        enemys[i]:draw()
    end

    -- Desenhar todas as bombas
    for i=#bombas, 1, -1 do
        bombas[i]:draw()
    end

    -- Desenhar contador de zumbis mortos com efeito de sombra
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Zumbis mortos: "..zumbisMortos, 12, 0)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("Zumbis mortos: "..zumbisMortos, 10, -2)
    love.graphics.setColor(1, 1, 1)

    -- Desenhar interface da loja
    loja:draw()

    -- Verificar game over
    if casa.vida <=0 then
        -- Limpar todos os inimigos
        for k in pairs(enemys) do
            enemys[k]=nil
        end
        gameover:draw()
    end

end

-- ============================================
-- FUNÇÃO DE ATUALIZAÇÃO DE INIMIGOS E CASA
-- ============================================
function atualiza_zumbi_casa(dt)
    -- Atualizar movimento dos inimigos e verificar se chegaram à casa
    for i=#enemys, 1, -1 do
        enemys[i]:update(dt)

        -- Verificar se o zumbi chegou na casa (posição x < 150)
        if enemys[i].posicao.x < 150 then
            casa.vida = casa.vida - enemys[i].dano  -- Aplicar dano à casa
            table.remove(enemys, i)                 -- Remover zumbi
            zumbisEntrou = zumbisEntrou + 1         -- Incrementar contador
        end
    end

    -- Verificar se algum zumbi foi eliminado
    for i=#enemys, 1, -1 do
        if enemys[i].vida <= 0 then
            -- 50% de chance de gerar moedas ao eliminar zumbi
            local sortea_gera_moeda = love.math.random(0, 1)

            if sortea_gera_moeda == 1 then
                moeda.quantidade = moeda.quantidade + enemys[i].qtd_moeda_gerada
            end

            -- Tocar som de morte
            audio_morte:setVolume(0.05)
            audio_morte:play()

            -- Remover zumbi e atualizar contadores
            table.remove(enemys, i)
            zumbisMortos = zumbisMortos + 1
            vida_bonus = vida_bonus + 1  -- Acumular para bônus de vida
        end
    end
end

-- ============================================
-- FUNÇÃO DE CAPTURA DE CLIQUE DO MOUSE
-- ============================================
function love.mousepressed(x, y, button)
    -- Detectar clique esquerdo do mouse
    if button == 1 then
        posicao_mouse.x, posicao_mouse.y = x, y
        tempo_mouse = 1  -- Ativar flag de clique
    end
end

-- ============================================
-- FUNÇÃO AUXILIAR: VERIFICAR ESPAÇO LIVRE
-- ============================================
function checa_espaco_livre()
    -- Verifica se não existe uma torre na posição desejada

    -- Alinhar posição ao grid
    local tmp_x = math.floor(posicao_mouse.x / 100) * 100
    local tmp_y = math.floor(posicao_mouse.y / 100) * 100 - 20
    local tmp_vector = Vector(tmp_x, tmp_y)

    -- Percorrer todas as torres existentes
    for i=#torres, 1, -1 do
        if torres[i].posicao == tmp_vector then
            return false  -- Espaço ocupado
        end
    end

    return true  -- Espaço livre
end