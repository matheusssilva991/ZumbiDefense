local Config = require "configuracao"
local Partida = require "partida"
local Recorde = require "recorde"
local Recursos = require "recursos"
local Cenario = require "classes.background.cenario"
local Loja = require "classes.background.loja"
local Moeda = require "classes.background.moeda"
local Objetivo = require "classes.personagens.objetivo"
local Gameover = require "classes.background.gameover"

local partida, recursos, recorde, falhaAoSalvar

local function reiniciar()
    recursos:pararEfeitos()
    partida = Partida(function(efeito) recursos:tocar(efeito) end)
end

function love.load()
    recursos = Recursos.carregar()
    recorde = Recorde.carregar(love.filesystem)
    falhaAoSalvar = false
    reiniciar()
end

function love.update(dt)
    local faseAnterior = partida.fase
    partida:update(dt)
    if faseAnterior ~= "derrota" and partida.fase == "derrota" then
        recorde, falhaAoSalvar = Recorde.registrar(love.filesystem, recorde, partida, falhaAoSalvar)
    end
end

local function desenharPlacar()
    local g = love.graphics
    local estado, cor
    if partida.fase == "preparacao" then
        estado = ("Onda 1 em %ds"):format(math.ceil(partida.tempoFase))
        cor = {0.97, 0.78, 0.42}
    elseif partida.fase == "intervalo" then
        estado = ("Onda %d em %ds"):format(partida.onda + 1, math.ceil(partida.tempoFase))
        cor = {0.97, 0.78, 0.42}
    elseif partida.fase == "onda" then
        estado = ("Onda %d  |  %d restantes"):format(partida.onda, partida:inimigosRestantes())
        cor = {0.85, 0.94, 0.87}
    else
        estado = ("Onda %d"):format(partida.onda)
        cor = {0.85, 0.94, 0.87}
    end

    local abates = "Abates: " .. partida.abates
    local larguraAbates = recursos.fonte:getWidth(abates) + 20
    local larguraEstado = recursos.fonte:getWidth(estado) + 20
    local gX = Config.largura - larguraEstado - 10
    g.setColor(0.035, 0.04, 0.065, 0.86)
    g.rectangle("fill", 10, 8, larguraAbates, 31, 4)
    g.rectangle("fill", gX, 8, larguraEstado, 31, 4)
    g.setColor(1, 1, 1)
    g.print(abates, 20, 14)
    g.setColor(cor)
    g.print(estado, gX + 10, 14)
    g.setColor(1, 1, 1)
end

function love.draw()
    local g = love.graphics
    g.setFont(recursos.fonte)
    g.setColor(1, 1, 1)
    Cenario.draw(recursos)
    Objetivo.draw(recursos)
    Cenario.drawEscurecimento()

    local previa
    if not partida.pausada and partida.fase ~= "derrota" then
        previa = Loja.previa(partida, love.mouse.getPosition())
    end
    Loja.drawAlcance(previa)
    for _, torre in ipairs(partida.torres) do
        torre:draw(recursos, partida.tempo)
    end
    for _, inimigo in ipairs(partida.inimigos) do
        inimigo:draw(recursos, partida.tempo)
    end
    for _, bomba in ipairs(partida.bombas) do
        bomba:draw(recursos)
    end
    Loja.drawPrevia(recursos, previa, partida.tempo)
    desenharPlacar()

    g.setColor(0.035, 0.04, 0.065, 0.86)
    g.rectangle("fill", 8, 505, 385, 90, 4)
    g.setColor(1, 1, 1)
    Moeda.draw(recursos, partida.tempo, partida.moedas)
    Objetivo.drawVida(recursos, partida.tempo, partida.vida)
    Loja.draw(recursos, partida)

    local mensagem = partida.mensagem
    if previa then
        mensagem = previa.motivo
    end
    if partida.fase ~= "derrota" and not partida.pausada then
        if mensagem then
            g.setColor(1, 0.67, 0.56)
            g.print(mensagem, 18, 558)
        elseif partida.selecionado then
            g.print("Esc para cancelar a seleção", 18, 558)
        else
            g.setColor(0.8, 0.82, 0.88)
            g.print("P para pausar", 18, 558)
        end
    end
    g.setColor(1, 1, 1)

    if partida.fase == "derrota" then
        Gameover.draw(recursos, partida, recorde, falhaAoSalvar)
    elseif partida.pausada then
        Gameover.drawPausa(recursos)
    end
end

function love.mousepressed(x, y, botao)
    if partida.fase == "derrota" then
        if botao == 1 and Gameover.noBotao(x, y) then
            reiniciar()
        end
    elseif botao == 1 then
        partida:clicar(x, y)
    elseif botao == 2 then
        partida:cancelarSelecao()
    end
end

function love.keypressed(tecla, _, repeticao)
    if repeticao then
        return
    end
    if tecla == "p" and partida.fase ~= "derrota" then
        partida:alternarPausa()
        recursos:ajustarPausa(partida.pausada)
    elseif tecla == "escape" then
        partida:cancelarSelecao()
    elseif tecla == "r" and partida.fase == "derrota" then
        reiniciar()
    end
end
