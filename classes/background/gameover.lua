local Config = require "configuracao"

local Gameover = {}
local x, y = (Config.largura - 510) / 2, (Config.altura - 310) / 2
local botao = {x = x + 148, y = y + 237, largura = 214, altura = 43}

function Gameover.noBotao(mouseX, mouseY)
    return mouseX >= botao.x and mouseX < botao.x + botao.largura
        and mouseY >= botao.y and mouseY < botao.y + botao.altura
end

local function fundo(recursos, titulo)
    local g = love.graphics
    g.setColor(0.02, 0.02, 0.03, 0.74)
    g.rectangle("fill", 0, 0, Config.largura, Config.altura)
    g.setColor(0.075, 0.08, 0.11)
    g.rectangle("fill", x, y, 510, 310, 5)
    g.setColor(1, 1, 1, 0.26)
    g.draw(recursos.imagens.fundoGameover, x + 5, y + 5)
    g.setColor(1, 1, 1)
    g.setFont(recursos.titulo)
    g.printf(titulo, x, y + 35, 510, "center")
    g.setFont(recursos.fonte)
end

function Gameover.draw(recursos, partida, recorde, falhaAoSalvar)
    fundo(recursos, "FIM DE JOGO")
    local g = love.graphics
    g.printf(("Onda %d   |   %d abates   |   %d invasões"):format(
        partida.onda, partida.abates, partida.invasoes), x + 10, y + 121, 490, "center")
    g.setColor(0.98, 0.79, 0.43)
    g.printf(("Recorde: onda %d, %d abates"):format(recorde.onda, recorde.abates),
        x + 10, y + 157, 490, "center")
    if falhaAoSalvar then
        g.printf("Não foi possível salvar o recorde.", x + 10, y + 187, 490, "center")
    end

    local mouseX, mouseY = love.mouse.getPosition()
    if Gameover.noBotao(mouseX, mouseY) then
        g.setColor(0.27, 0.48, 0.34)
    else
        g.setColor(0.16, 0.33, 0.24)
    end
    g.rectangle("fill", botao.x, botao.y, botao.largura, botao.altura, 4)
    g.setColor(1, 1, 1)
    g.printf("Reiniciar [R]", botao.x, botao.y + 6, botao.largura, "center")
end

function Gameover.drawPausa(recursos)
    fundo(recursos, "JOGO PAUSADO")
    love.graphics.printf("Pressione P para retomar", x, y + 138, 510, "center")
end

return Gameover
