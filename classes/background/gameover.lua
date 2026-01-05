-- ============================================
-- CLASSE GAMEOVER
-- Tela de fim de jogo exibida quando o
-- jogador perde (vida da casa chega a zero)
-- ============================================

Gameover = Classe:extend()

function Gameover:new()
    -- Carregar imagem de fundo
    self.img_fundo = love.graphics.newImage("Sprites/background/fundo_gameover.png")

    -- Dimensões e posição da janela de game over
    self.larg = 510
    self.alt = 310
    self.x = (LARGURA_TELA - self.larg)/2  -- Centralizar horizontalmente
    self.y = (ALTURA_TELA - self.alt)/2    -- Centralizar verticalmente
end

-- Método update (não utilizado, mas mantido por consistência)
function Gameover:update(dt)
    -- Nenhuma lógica necessária aqui
end

-- Desenhar tela de game over com estatísticas
function Gameover:draw()
    -- Configurar fonte grande para o título
    self.font = love.graphics.setNewFont("fontes/Pixeled.ttf", 30)
    self.txtGameOver = "FIM DE JOGO!"

    -- Calcular posição centralizada do texto
    self.txtGameOverx = (LARGURA_TELA - self.font:getWidth(self.txtGameOver)) / 2
    self.txtGameOvery = (ALTURA_TELA - self.font:getHeight()) / 2

    -- Desenhar retângulo de fundo preto
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x, self.y, self.larg, self.alt)
    love.graphics.setColor(1, 1, 1)

    -- Desenhar imagem de fundo decorativa
    love.graphics.draw(self.img_fundo, self.x + 5, self.y +5)

    -- Desenhar título "FIM DE JOGO!" com efeito de sombra
    love.graphics.setColor(0, 0, 0)  -- Sombra
    love.graphics.print(self.txtGameOver, self.txtGameOverx+3, self.txtGameOvery - 80+3)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print(self.txtGameOver, self.txtGameOverx, self.txtGameOvery - 80)

    -- Voltar para a fonte padrão
    love.graphics.setFont(fonte)

    -- Desenhar estatística: Zumbis eliminados
    love.graphics.setColor(0, 0, 0)  -- Sombra
    love.graphics.print("ZUMBIS ELIMINADOS: ".. zumbisMortos, self.txtGameOverx - 17, self.txtGameOvery + 73)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print("ZUMBIS ELIMINADOS: ".. zumbisMortos, self.txtGameOverx - 20, self.txtGameOvery + 70)

    -- Desenhar estatística: Zumbis que invadiram
    love.graphics.setColor(0, 0, 0)  -- Sombra
    love.graphics.print("ZUMBIS INVASORES: ".. zumbisEntrou, self.txtGameOverx - 17, self.txtGameOvery + 113)
    love.graphics.setColor(1, 1, 1)  -- Texto branco
    love.graphics.print("ZUMBIS INVASORES: ".. zumbisEntrou, self.txtGameOverx - 20, self.txtGameOvery + 110)
end