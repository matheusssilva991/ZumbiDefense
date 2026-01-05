-- ============================================
-- CLASSE BOMBA
-- Bombas explosivas que causam dano em área
-- a todos os inimigos dentro do raio de explosão
-- ============================================

Bomba = Classe:extend()

function Bomba:new(x, y)
    -- Carregar áudio de explosão
    self.audio_explosion = love.audio.newSource("audio/musket-explosion-6383.mp3", "stream")

    -- Carregar e configurar sprite de explosão
    self.img_explosaoBomba = love.graphics.newImage("Sprites/personagens/explosao.png")
    self.larg_explosao = self.img_explosaoBomba:getWidth()
    self.alt_explosao = self.img_explosaoBomba:getHeight()
    self.largF_explosao = self.larg_explosao/3  -- 3 frames por linha
    self.altF_explosao = self.alt_explosao/3    -- 3 linhas

    -- Configurar animação de explosão (9 frames no total)
    local grid_explosao = anim.newGrid(self.largF_explosao, self.altF_explosao, self.larg_explosao, self.alt_explosao)
    self.animation_explosao = anim.newAnimation(grid_explosao('1-3', 1, '1-3', 2, '1-3', 3), 0.1)

    -- Atributos da bomba
    self.posicao = Vector(x, y)  -- Posição onde foi colocada
    self.raio = 150              -- Raio de dano da explosão
    self.dano = 80               -- Dano causado pela explosão
    self.explodiu = 0            -- Flag para controlar se já explodiu
    self.tempo_bomba = 0         -- Timer para controlar duração da animação
end

-- Atualizar bomba (explodir e reproduzir animação)
function Bomba:update(dt)
    self.tempo_bomba = self.tempo_bomba + dt

    -- Explodir apenas uma vez
    if self.explodiu == 0 then
        self:detecta_inimigos()  -- Causar dano em todos os inimigos no raio
        self.explodiu = 1
    end

    -- Atualizar animação de explosão
    self.animation_explosao:update(dt)
    self.audio_explosion:play()
end

-- Desenhar animação de explosão
function Bomba:draw()
    self.animation_explosao:draw(self.img_explosaoBomba, self.posicao.x, self.posicao.y+15)
end

-- Detectar e causar dano a todos os inimigos no raio de explosão
function Bomba:detecta_inimigos()
    -- Percorrer todos os inimigos
    for i=1, #enemys do
        -- Calcular distância entre bomba e inimigo
        local dist = self.posicao.dist(enemys[i].posicao + Vector(-50, 50), self.posicao + Vector(50, 50))

        -- Se inimigo está dentro do raio de explosão
        if  dist <= self.raio then
            -- Aplicar dano
            enemys[i].vida =  enemys[i].vida - self.dano
            -- Atualizar barra de vida proporcional
            enemys[i].barra_vida = enemys[i].barra_vida * (enemys[i].vida/enemys[i].temp_vida)
        end
    end
end