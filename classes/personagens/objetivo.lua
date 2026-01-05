-- ============================================
-- CLASSE OBJETIVO (CASA)
-- Representa a casa que o jogador deve proteger
-- dos ataques dos zumbis
-- ============================================

Objetivo = Classe:extend()

function Objetivo:new()
    -- Carregar sprites
    self.img = love.graphics.newImage("Sprites/personagens/objetivo.png")
    self.img_vida = love.graphics.newImage("Sprites/background/vida.png")

    -- Pontos de vida da casa
    self.vida = 100

    -- Posição da casa no mapa (linha 5, coluna 1)
    self.posicao = Vector(0, 4*TAM_BLOCO)

    -- Configurar animação do ícone de vida
    local g_vida = anim.newGrid(230, 230, self.img_vida:getWidth(), self.img_vida:getHeight())
    self.anim_vida = anim.newAnimation(g_vida('1-3', 1, '1-3', 2, '1-1', 3), 0.1)
end

-- Atualizar animação e sistema de bônus de vida
function Objetivo:update(dt)
    self.anim_vida:update(dt)

    -- Conceder bônus de vida a cada 20 zumbis eliminados
    if vida_bonus == 20 then
        self.vida = self.vida + 10
        vida_bonus = 0  -- Resetar contador
    end
end

-- Desenhar casa, ícone de vida e contador
function Objetivo:draw()
    -- Desenhar sprite da casa (reduzida para 25% do tamanho)
    love.graphics.push()
    love.graphics.scale(0.25, 0.25)
    love.graphics.draw(self.img, self.posicao.x, self.posicao.y)
    love.graphics.pop()

    -- Desenhar ícone animado de coração (vida)
    love.graphics.push()
    love.graphics.scale(0.15, 0.15)
    self.anim_vida:draw(self.img_vida, 20*TAM_BLOCO*0.15, 58.5*TAM_BLOCO*0.15)
    love.graphics.pop()

    -- Desenhar contador de pontos de vida com efeito de sombra
    love.graphics.setColor(0, 0, 0)  -- Sombra preta
    love.graphics.print("x"..self.vida, 222, 516)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print("x"..self.vida, 220, 514)

end
