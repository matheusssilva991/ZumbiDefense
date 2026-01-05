-- ============================================
-- CLASSE INIMIGO (ZUMBI)
-- Representa os inimigos que seguem um caminho
-- predefinido tentando chegar à casa do jogador
-- ============================================

Inimigo = Classe:extend()

function Inimigo:new(nome_inimigo, tipos_inimigos)
    -- Carregar e configurar sprite do inimigo
    self.img = love.graphics.newImage("/Sprites/personagens/" .. nome_inimigo .. ".png")
    self.largura = self.img:getWidth()
    self.altura = self.img:getHeight()

    -- Configurar animação (4 frames por linha, cada frame 100x100)
    local g_inimigos = anim.newGrid(100, 100, self.largura, self.altura)
    self.anim_inimigos = anim.newAnimation(g_inimigos('1-4', tipos_inimigos.op), 0.15)

    -- Atributos do inimigo (baseados no tipo)
    self.posicao = Vector(LARGURA_TELA + 100, 80)  -- Começa fora da tela à direita
    self.velocidade = tipos_inimigos.velocidade     -- Velocidade de movimento
    self.dano = tipos_inimigos.dano                 -- Dano causado ao objetivo
    self.vida = tipos_inimigos.vida                 -- Vida atual
    self.temp_vida = tipos_inimigos.vida            -- Vida máxima (para calcular barra)

    self.barra_vida = 56  -- Largura da barra de vida em pixels

    self.qtd_moeda_gerada = tipos_inimigos.qtd_moeda_gerada  -- Recompensa ao eliminar

    -- Sistema de navegação pelo mapa
    -- Define as direções que o zumbi deve seguir em sequência
    self.direcao = {"esq","esq", "baixo", "baixo", "baixo", "esq", "esq", "cima", "cima", "cima",
                    "esq", "esq", "baixo", "baixo", "baixo", "esq", "esq", "esq"}

    -- Posições-alvo correspondentes a cada direção
    self.pos_objetivo = {800, 700, 180, 280, 380, 600, 500, 280, 180, 80, 400, 300, 180,
                         280, 380, 200, 100, 0}
    self.i = 1  -- Índice atual no caminho
end

-- Atualizar movimento e animação do inimigo
function Inimigo:update(dt)
    self.anim_inimigos:update(dt)

    -- Mover o inimigo na direção atual até alcançar o objetivo
    if self.direcao[self.i] == "esq" and self.posicao.x > self.pos_objetivo[self.i] then
        self.posicao.x = self.posicao.x - self.velocidade * dt
    elseif self.direcao[self.i] == "cima" and self.posicao.y > self.pos_objetivo[self.i] then
        self.posicao.y = self.posicao.y - self.velocidade * dt
    elseif self.direcao[self.i] == "baixo" and self.posicao.y < self.pos_objetivo[self.i] then
        self.posicao.y = self.posicao.y + self.velocidade * dt
    elseif self.i < #self.direcao then
        self.i = self.i + 1  -- Avançar para próxima direção
    end

end

-- Desenhar o inimigo e sua barra de vida
function Inimigo:draw()
    -- Desenhar sprite do inimigo (invertido horizontalmente com -1)
    self.anim_inimigos:draw(self.img, self.posicao.x, self.posicao.y, 0, -1, 1)

    -- Desenhar fundo da barra de vida (preto)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.posicao.x - 80, self.posicao.y - 10, 60, 10)

    -- Desenhar barra de vida (vermelha, proporcional à vida restante)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.posicao.x - 78, self.posicao.y - 8, self.barra_vida, 6)

    -- Resetar cor para branco
    love.graphics.setColor(1, 1, 1)

    -- Código comentado para debug:
    -- love.graphics.circle("line", self.posicao.x - 50, self.posicao.y + 50, 150)  -- Mostrar raio de detecção
    -- love.graphics.print("vida: " ..self.vida, 10, 10)  -- Mostrar vida na tela
end
