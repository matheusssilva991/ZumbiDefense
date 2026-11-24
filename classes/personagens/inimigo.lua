local Classe = require "classes.classic"
local Vector = require "classes.vector"
local Config = require "configuracao"

local Inimigo = Classe:extend()
local pontos = {}
local trechos = {}
for i, coordenadas in ipairs(Config.caminho) do
    pontos[i] = Vector(coordenadas[1], coordenadas[2])
end
for i = 1, #pontos - 1 do
    local deslocamento = pontos[i + 1] - pontos[i]
    local comprimento = deslocamento:getmag()
    trechos[i] = {tamanho = comprimento, direcao = deslocamento / comprimento}
end

function Inimigo:new(tipo, multiplicadorVida, nascimento)
    self.tipo = tipo
    self.nascimento = nascimento
    self.posicao = pontos[1]:clone()
    self.trecho = 1
    self.avancoNoTrecho = 0
    self.progresso = 0
    self.lentidaoRestante = 0
    self.reducao = 0
    self.vidaMaxima = math.floor(tipo.vida * multiplicadorVida + 0.5)
    self.vida = self.vidaMaxima
end

function Inimigo:receberDano(dano)
    self.vida = math.max(0, self.vida - dano)
end

function Inimigo:aplicarLentidao(reducao, duracao)
    self.reducao = reducao
    self.lentidaoRestante = duracao
end

function Inimigo:mover(dt)
    local tempoLento = math.min(dt, self.lentidaoRestante)
    self.lentidaoRestante = self.lentidaoRestante - tempoLento
    local distancia = self.tipo.velocidade * (dt - self.reducao * tempoLento)

    while distancia > 0 and self.trecho <= #trechos do
        local trecho = trechos[self.trecho]
        local restante = trecho.tamanho - self.avancoNoTrecho
        local avanco = math.min(distancia, restante)
        self.progresso = self.progresso + avanco
        distancia = distancia - avanco

        if avanco >= restante then
            self.trecho = self.trecho + 1
            self.avancoNoTrecho = 0
            self.posicao:replace(pontos[self.trecho])
        else
            self.avancoNoTrecho = self.avancoNoTrecho + avanco
            local origem = pontos[self.trecho]
            self.posicao:set(
                origem.x + trecho.direcao.x * self.avancoNoTrecho,
                origem.y + trecho.direcao.y * self.avancoNoTrecho
            )
        end
    end

    return self.trecho > #trechos
end

function Inimigo:proporcaoVida()
    return self.vida / self.vidaMaxima
end

function Inimigo:draw(recursos, tempo)
    local g = love.graphics
    local x, y = self.posicao.x, self.posicao.y
    if self.lentidaoRestante > 0 then
        g.setColor(0.65, 0.9, 1)
    end
    recursos:animar("inimigos", recursos.quadros.inimigos[self.tipo.quadro],
        tempo - self.nascimento, 0.15, x + 50, y - 50, -1, 1)
    g.setColor(0, 0, 0)
    g.rectangle("fill", x - 30, y - 60, 60, 10)
    g.setColor(1, 0.18, 0.18)
    g.rectangle("fill", x - 28, y - 58, 56 * self:proporcaoVida(), 6)
    g.setColor(1, 1, 1)
end

return Inimigo
