-- ============================================
-- CLASSE LOJA
-- Interface de compra de torres e bombas
-- Exibe os itens disponíveis e seu preço
-- ============================================

Loja = Classe:extend()

function Loja:new()
    -- Carregar sprites da loja
    self.img = love.graphics.newImage("Sprites/background/placa.png")
    self.img_torre = love.graphics.newImage("Sprites/personagens/torre1.png")
    self.img_bomba = love.graphics.newImage("Sprites/personagens/bomba.png")

    -- Configurar animação da torre na loja
    self.largura_torre = self.img_torre:getWidth()
    self.altura_torre = self.img_torre:getHeight()
    self.largF = self.largura_torre/8
    self.altF = self.altura_torre/5

    local grid = anim.newGrid(self.largF, self.altF, self.largura_torre, self.altura_torre)
    self.animation = anim.newAnimation(grid('1-8', 1), 0.1)

    self.raio_torre = 0  -- Raio do indicador visual ao selecionar
end

-- Atualizar sistema de seleção de torres/bombas
function Loja:update(dt)
    -- Detectar clique do mouse
    if love.mouse.isDown(1) and tempo_mouse == 1 then
        -- Converter posição do mouse em coordenadas da matriz
        pos_matriz.x, pos_matriz.y = math.floor(posicao_mouse.y/100)+1, math.floor(posicao_mouse.x/100)+1

        -- Verificar clique no botão da torre (posição 4 no mapa)
        if mapa[pos_matriz.x][pos_matriz.y] == 4 and moeda.quantidade >= 20 then
            self.tipo_torre = 1      -- Torre automática
            self.raio_torre = 150    -- Mostrar raio de alcance
            pegouTorre = true        -- Ativar modo de posicionamento
        -- Verificar clique no botão da bomba (posição 5 no mapa)
        elseif mapa[pos_matriz.x][pos_matriz.y] == 5 and moeda.quantidade >= 10 then
            self.tipo_torre = 2      -- Bomba explosiva
            self.raio_torre = 150    -- Mostrar raio de explosão
            pegouTorre = true        -- Ativar modo de posicionamento
        end
    end
end

-- Desenhar interface da loja
function Loja:draw()
    -- Desenhar placas de fundo para os itens
    love.graphics.draw(self.img, 405, 500)
    love.graphics.draw(self.img, 505, 500)

    -- Desenhar ícone da torre com animação
    self.animation:draw(self.img_torre, 405, 500)

    -- Desenhar preço da torre com efeito de sombra
    love.graphics.setColor(0, 0, 0)  -- Sombra
    love.graphics.print("$20", 419, 542)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print("$20", 417, 540)

    -- Desenhar ícone da bomba (reduzido para 50%)
    love.graphics.push()
    love.graphics.scale(0.5, 0.5)
    love.graphics.draw(self.img_bomba, 505/0.5+40, 500/0.5+40)
    love.graphics.pop()

    -- Desenhar preço da bomba com efeito de sombra
    love.graphics.setColor(0, 0, 0)  -- Sombra
    love.graphics.print("$10", 519, 542)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print("$10", 517, 540)

    -- Desenhar bordas decorativas dos botões da loja
    local pos_x = 400
    for j=1, 2 do
        love.graphics.setLineWidth(5)
        love.graphics.setColor(0.2, 0.1, 0.07)  -- Cor marrom
        love.graphics.rectangle("line", pos_x+2, ALTURA_TELA - 97, 100, 95)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(1)
        pos_x = pos_x + 100
     end

    -- Mostrar preview da torre/bomba seguindo o mouse quando selecionada
    if pegouTorre == true then
        -- Desenhar círculo amarelo transparente indicando o raio de alcance
        love.graphics.setColor(1, 1, 0, 0.25)
        love.graphics.circle("fill", mouse.x, mouse.y, self.raio_torre)

        -- Desenhar contorno do círculo
        love.graphics.setColor(1, 1, 0)
        love.graphics.setLineWidth(5)
        love.graphics.setLineStyle("smooth")
        love.graphics.circle("line", mouse.x, mouse.y, self.raio_torre)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)

        -- Desenhar sprite da torre ou bomba no cursor
        if self.tipo_torre == 1 then
            self.animation:draw(self.img_torre, mouse.x - 50, mouse.y - 50)
        elseif self.tipo_torre == 2 then
            love.graphics.push()
            love.graphics.scale(0.5, 0.5)
            love.graphics.draw(self.img_bomba, (mouse.x - 25)/0.5, (mouse.y - 25)/0.5)
            love.graphics.pop()
        end
    end
end