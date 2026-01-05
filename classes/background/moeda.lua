-- ============================================
-- CLASSE MOEDA
-- Gerencia o sistema de moedas/dinheiro do jogo
-- Exibe o ícone animado e a quantidade de moedas
-- ============================================

Moeda = Classe:extend()

function Moeda:new()
    -- Posição do ícone na tela
    self.x = 10*0.15
    self.y = 56*TAM_BLOCO*0.15

    -- Carregar sprite da moeda
    self.img = love.graphics.newImage("Sprites/background/moeda.png")
    self.largura = self.img:getWidth()
    self.altura = self.img:getHeight()
    self.largura_q = 230
    self.altura_q = 329

    -- Configurar animação da moeda (16 frames no total)
    local grid = anim.newGrid(230, 329, self.largura, self.altura)
    self.animation = anim.newAnimation(grid('1-4', 1, '1-4', 2, '1-4', 3, '1-4', 4), 0.1)

    self.quantidade = 60  -- Quantidade inicial de moedas
end

-- Atualizar animação da moeda
function Moeda:update(dt)
    self.animation:update(dt)
end

-- Desenhar ícone e contador de moedas
function Moeda:draw ()
    -- Desenhar ícone animado da moeda (reduzido para 15%)
    love.graphics.push()
    love.graphics.scale(0.15, 0.15)
    self.animation:draw(self.img, 1* TAM_BLOCO * 0.15, 58*TAM_BLOCO*0.15)
    love.graphics.pop()

    -- Desenhar quantidade de moedas com efeito de sombra
    love.graphics.setColor(0, 0, 0, 1)  -- Sombra preta
    love.graphics.print("x"..self.quantidade, 50, 516)
    love.graphics.setColor(1, 1, 1, 1)  -- Texto branco
    love.graphics.print("x"..self.quantidade, 48, 514)
end
