local Config = require "configuracao"

local Objetivo = {}

function Objetivo.draw(recursos)
    local x, y = Config.origemCelula(5, 1)
    local imagem = recursos.imagens.casa
    love.graphics.draw(imagem, x, y, 0, Config.tamanhoCelula / imagem:getWidth())
end

function Objetivo.drawVida(recursos, tempo, vida)
    recursos:animar("vida", recursos.quadros.vida, tempo, 0.1, 171, 516, 0.125)
    love.graphics.print("x" .. vida, 206, 520)
end

return Objetivo
