local Anim8 = require "classes.anim8"

local Recursos = {}
Recursos.__index = Recursos

local arquivosImagem = {
    grama = "background/grass_tile_1",
    areia = "background/sand_tile_1",
    madeira = "background/madeira",
    placa = "background/placa",
    moeda = "background/moeda",
    vida = "background/vida",
    fundoGameover = "background/fundo_gameover",
    casa = "personagens/objetivo",
    inimigos = "personagens/inimigos",
    torre = "personagens/torre1",
    bomba = "personagens/bomba",
    explosao = "personagens/explosao",
}

local function grade(imagem, colunas, linhas)
    local largura, altura = imagem:getDimensions()
    return Anim8.newGrid(largura / colunas, altura / linhas, largura, altura)
end

local function novoEfeito(arquivo, volume, tom)
    local fonte = love.audio.newSource("audio/" .. arquivo, "static")
    fonte:setVolume(volume)
    fonte:setPitch(tom or 1)
    return {fonte}
end

function Recursos.carregar()
    local g = love.graphics
    local imagens = {}
    for nome, arquivo in pairs(arquivosImagem) do
        imagens[nome] = g.newImage("Sprites/" .. arquivo .. ".png")
    end

    local torre = grade(imagens.torre, 8, 5)
    local inimigos = grade(imagens.inimigos, 4, 4)
    local explosao = grade(imagens.explosao, 3, 3)
    local moeda = grade(imagens.moeda, 4, 4)
    local vida = grade(imagens.vida, 3, 3)
    local quadros = {
        patrulha = torre("1-5", 1),
        ataque = torre("6-8", 1, "1-8", 2),
        explosao = explosao("1-3", 1, "1-3", 2, "1-3", 3),
        moeda = moeda("1-4", 1, "1-4", 2, "1-4", 3, "1-4", 4),
        vida = vida("1-3", 1, "1-3", 2, 1, 3),
        inimigos = {},
    }
    for linha = 1, 4 do
        quadros.inimigos[linha] = inimigos("1-4", linha)
    end

    local efeitos = {
        tiro = novoEfeito("shotgun-firing-3-14483.mp3", 0.1, 2),
        lentidao = novoEfeito("shotgun-firing-4-6746.mp3", 0.06, 1.5),
        bomba = novoEfeito("musket-explosion-6383.mp3", 0.12),
        abate = novoEfeito("goresplat-7088.mp3", 0.05),
        zumbi = novoEfeito("zombie-growl-3-6863.mp3", 0.02),
    }
    local ambiente = love.audio.newSource("audio/terror-ambience-7003.mp3", "stream")
    ambiente:setVolume(0.01)
    ambiente:setLooping(true)
    ambiente:play()

    local fonte = g.newFont("fontes/Pixeled.ttf", 12)
    fonte:setFallbacks(g.newFont(12))

    return setmetatable({
        imagens = imagens,
        quadros = quadros,
        efeitos = efeitos,
        pausados = {},
        ambiente = ambiente,
        fonte = fonte,
        titulo = g.newFont("fontes/Pixeled.ttf", 24),
    }, Recursos)
end

function Recursos:animar(imagem, quadros, tempo, duracaoQuadro, x, y, sx, sy)
    local indice = math.floor(tempo / duracaoQuadro) % #quadros + 1
    love.graphics.draw(self.imagens[imagem], quadros[indice], x, y, 0, sx or 1, sy or sx or 1)
end

function Recursos:tocar(nome)
    local fontes = self.efeitos[nome]
    for _, fonte in ipairs(fontes) do
        if not fonte:isPlaying() then
            fonte:play()
            return
        end
    end

    if #fontes < 8 then
        local fonte = fontes[1]:clone()
        fontes[#fontes + 1] = fonte
        fonte:play()
    end
end

function Recursos:ajustarPausa(pausar)
    if pausar then
        for _, grupo in pairs(self.efeitos) do
            for _, fonte in ipairs(grupo) do
                if fonte:isPlaying() then
                    fonte:pause()
                    self.pausados[#self.pausados + 1] = fonte
                end
            end
        end
    else
        for _, fonte in ipairs(self.pausados) do
            fonte:play()
        end
        self.pausados = {}
    end
end

function Recursos:pararEfeitos()
    for _, grupo in pairs(self.efeitos) do
        for _, fonte in ipairs(grupo) do
            fonte:stop()
        end
    end
    self.pausados = {}
end

return Recursos
