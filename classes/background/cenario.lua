-- ============================================
-- CLASSE CENARIO
-- Gerencia a renderização do mapa e
-- o sistema de seleção de tiles com o mouse
-- ============================================

Cenario = Classe:extend()

function Cenario:new()
    -- Sistema de seleção de tiles (grade azul/vermelha)
    self.selecao = {x=0, y=0, cor = {0,0,1,0.4}}  -- Começa azul (posição válida)
    self.mouse = {}

    -- Carregar texturas dos diferentes tipos de blocos
    local img_terra = love.graphics.newImage("Sprites/background/sand_tile_1.png")
    local img_grama = love.graphics.newImage("Sprites/background/grass_tile_1.png")
    local img_madeira = love.graphics.newImage("Sprites/background/madeira.png")

    -- Array de imagens indexado pelos valores do mapa
    self.img = {img_grama, img_terra, img_madeira, img_madeira, img_madeira}
end

-- Atualizar sistema de seleção de tiles
function Cenario:update()
    -- Atualizar posição do mouse
    self.mouse.x = love.mouse.getX()
    self.mouse.y = love.mouse.getY()

    -- Detectar qual tile o mouse está sobre (grid de 100x100 pixels)
    for i=1, 6 do
        for j=1, 8 do
            -- Calcular coluna (x) do tile
            if (self.mouse.x > (j-1)*100 and self.mouse.x < j*100) then
                self.selecao.x = j-1
            end

            -- Calcular linha (y) do tile
            if (self.mouse.y > (i-1)*100 and self.mouse.y < i*100) then
                self.selecao.y = i-1
            end

            -- Definir cor do indicador baseado no tipo de tile
            -- Azul = Grama (pode colocar torre)
            -- Vermelho = Areia/Caminho (onde zumbis andam)
            -- Transparente = Outros tiles
            if (mapa[self.selecao.y+1][self.selecao.x+1] == 1) then
                self.selecao.cor = {0,0,1,0.4}  -- Azul
            elseif (mapa[self.selecao.y+1][self.selecao.x+1] == 2) then
                self.selecao.cor = {1,0,0,0.4}  -- Vermelho
            else
                self.selecao.cor = {0,0,0,0}    -- Transparente
            end
        end
    end
end

-- Desenhar o mapa e o indicador de seleção
function Cenario:draw()
    -- Desenhar todas as texturas do mapa (reduzidas para 25%)
    love.graphics.push()
    love.graphics.scale(0.25, 0.25)

    for i=1, #mapa do
       for j=1, #mapa[i] do
            -- Desenhar tile correspondente ao valor no mapa
            love.graphics.draw(self.img[mapa[i][j]], (j-1)*TAM_BLOCO, (i-1)*TAM_BLOCO)
        end
    end

    love.graphics.pop()

    -- Desenhar retângulo de seleção sobre o tile atual
    love.graphics.setColor(self.selecao.cor)
    love.graphics.rectangle("fill", self.selecao.x*100, self.selecao.y*100, 100, 100)
    love.graphics.setColor(1, 1, 1, 1)
end