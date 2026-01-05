-- ============================================
-- CLASSE TORRE
-- Torres automáticas que detectam e atacam
-- inimigos dentro do seu raio de ação
-- ============================================

Torre = Classe:extend()

function Torre:new(x, y)
    -- Carregar áudio de disparo
    self.audio_shots = love.audio.newSource("audio/shotgun-firing-3-14483.mp3", "stream")

    -- Carregar e configurar sprites da torre
    self.img_torre = love.graphics.newImage("Sprites/personagens/torre1.png")
    self.larg_torre = self.img_torre:getWidth()
    self.alt_torre = self.img_torre:getHeight()
    self.largF_torre = self.larg_torre/8   -- Largura de cada frame
    self.altF_torre = self.alt_torre/5     -- Altura de cada frame

    -- Configurar grid de animações
    local grid = anim.newGrid(self.largF_torre, self.altF_torre, self.larg_torre, self.alt_torre)

    -- Animação de patrulha (5 frames na linha 1)
    self.animation_patrulhando = anim.newAnimation(grid('1-5', 1), 0.1)

    -- Animação de ataque (frames 6-8 da linha 1 + linha 2 completa)
    self.animation_atacando = anim.newAnimation(grid('6-8', 1, '1-8', 2), 0.1)

    -- Atributos da torre
    self.posicao = Vector(x, y)       -- Posição no mapa
    self.raio = 150                   -- Raio de detecção de inimigos
    self.estado = "patrulhando"       -- Estado atual (patrulhando/atacando)
    self.dano = 20                    -- Dano por disparo

    self.delay = 0.21                 -- Tempo entre disparos
end

-- Atualizar estado e comportamento da torre
function Torre:update(dt)
    -- Atualizar animação baseada no estado
    if self.estado == "patrulhando" then
        self.animation_patrulhando:update(dt)
    else
        -- Estado de ataque: atualizar animação e tocar som
        self.animation_atacando:update(dt)
        self.audio_shots:setVolume(0.1)
        self.audio_shots:setPitch(2)  -- Acelerar áudio
        self.audio_shots:play()
    end

    -- Detectar inimigos no raio de alcance
    local i = self:detecta_inimigos()

    -- Se está atacando, aplicar dano com delay
    if self.estado == 'atacando' then
        self.delay = self.delay + dt

        -- Disparar a cada 0.80 segundos
        if self.delay > 0.80 then
            enemys[i].vida = enemys[i].vida - self.dano
            -- Atualizar barra de vida proporcional
            enemys[i].barra_vida = enemys[i].barra_vida * (enemys[i].vida/enemys[i].temp_vida)
            self.delay = 0  -- Resetar delay
        end
    end
end

-- Desenhar a torre com a animação apropriada
function Torre:draw()
    if self.estado == "patrulhando" then
        self.animation_patrulhando:draw(self.img_torre, self.posicao.x, self.posicao.y)
    else
        self.animation_atacando:draw(self.img_torre, self.posicao.x, self.posicao.y)
    end
end

-- Detectar e retornar o índice do primeiro inimigo no raio de alcance
function Torre:detecta_inimigos()
    -- Percorrer todos os inimigos
    for i=1, #enemys do
        -- Calcular distância entre torre e inimigo
        -- Ajusta posições para o centro dos sprites
        local dist = self.posicao.dist(enemys[i].posicao + Vector(-50, 50), self.posicao + Vector(50, 50))

        -- Se inimigo está dentro do raio
        if  dist <= self.raio then
            self.estado = "atacando"
            return i  -- Retornar índice do inimigo
        end
    end

    -- Nenhum inimigo detectado, voltar a patrulhar
    self.estado = "patrulhando"
    return -1
end