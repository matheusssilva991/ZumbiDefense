local Config = require "configuracao"

local Loja = {}

function Loja.previa(partida, mouseX, mouseY)
    local item = partida.selecionado
    if not item then
        return
    end

    local linha, coluna, terreno = Config.celulaEm(mouseX, mouseY)
    if Config.loja[terreno] then
        return
    end

    local motivo = partida:motivoCompraInvalida(item, linha, coluna, terreno)
    if not linha then
        return {motivo = motivo}
    end
    local x, y = Config.centroCombate(linha, coluna)
    return {item = item, x = x, y = y, motivo = motivo}
end

local function desenharItem(recursos, item, x, y, tempo, escala)
    if item.tipo == "bomba" then
        love.graphics.draw(recursos.imagens.bomba, x, y, 0, escala)
    else
        recursos:animar("torre", recursos.quadros.patrulha, tempo, 0.1, x, y, escala)
    end
end

function Loja.drawAlcance(previa)
    if not previa or not previa.item then
        return
    end
    local g = love.graphics
    local r, b = 0.35, 0.58
    local verde = 0.96
    if previa.motivo then
        r, verde, b = 1, 0.27, 0.25
    end
    g.setScissor(0, 0, Config.largura, Config.altura - Config.tamanhoCelula)
    g.setColor(r, verde, b, 0.14)
    g.circle("fill", previa.x, previa.y, previa.item.raio)
    g.setColor(r, verde, b, 0.85)
    g.circle("line", previa.x, previa.y, previa.item.raio)
    g.setScissor()
    g.setColor(1, 1, 1)
end

function Loja.drawPrevia(recursos, previa, tempo)
    if not previa or not previa.item then
        return
    end
    local item = previa.item
    local cor = item.cor or {1, 1, 1}
    local g = love.graphics
    g.setScissor(0, 0, Config.largura, Config.altura - Config.tamanhoCelula)
    g.setColor(cor[1], cor[2], cor[3], previa.motivo and 0.28 or 0.75)
    desenharItem(recursos, item, previa.x - 50, previa.y - 50, tempo, 1)
    g.setScissor()
    g.setColor(1, 1, 1)
end

function Loja.draw(recursos, partida)
    local g = love.graphics
    local linha = #Config.mapa
    local largura = Config.tamanhoCelula
    for coluna, terreno in ipairs(Config.mapa[linha]) do
        local item = Config.loja[terreno]
        if item then
            local x, y = Config.origemCelula(linha, coluna)
            local selecionado = partida.selecionado == item
            local disponivel = partida.moedas >= item.preco
            local brilho = disponivel and 1 or 0.64
            local cor = item.cor or {1, 1, 1}

            g.setColor(0.06, 0.065, 0.09, 0.85)
            g.rectangle("fill", x + 4, y + 4, largura - 8, largura - 8, 4)
            g.setColor(1, 1, 1, 0.22)
            g.draw(recursos.imagens.placa, x + 6, y + 6)
            if selecionado then
                g.setColor(0.54, 0.95, 0.7)
                g.rectangle("line", x + 4.5, y + 4.5, largura - 9, largura - 9, 4)
            end

            g.setColor(cor[1] * brilho, cor[2] * brilho, cor[3] * brilho)
            desenharItem(recursos, item, x + 20, y + 2, partida.tempo, 0.6)
            g.setColor(brilho, brilho, brilho)
            g.printf(item.nome, x, y + 47, largura, "center")
            g.setColor(0.97 * brilho, 0.78 * brilho, 0.42 * brilho)
            g.printf("$" .. item.preco, x, y + 65, largura, "center")
        end
    end
    g.setColor(1, 1, 1)
end

return Loja
