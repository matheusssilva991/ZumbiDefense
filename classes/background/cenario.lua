local Config = require "configuracao"

local Cenario = {}
local texturas = {"grama", "areia", "madeira", "madeira", "madeira", "madeira"}

function Cenario.draw(recursos)
    local g = love.graphics
    for linha, fileira in ipairs(Config.mapa) do
        for coluna, terreno in ipairs(fileira) do
            local x, y = Config.origemCelula(linha, coluna)
            local imagem = recursos.imagens[texturas[terreno]]
            local escala = Config.tamanhoCelula / imagem:getWidth()
            g.draw(imagem, x, y, 0, escala)
        end
    end
end

function Cenario.drawEscurecimento()
    local g = love.graphics
    g.setColor(0, 0, 0.2, 0.55)
    g.rectangle("fill", 0, 0, Config.largura, Config.altura - Config.tamanhoCelula)
    g.setColor(1, 1, 1)
end

return Cenario
