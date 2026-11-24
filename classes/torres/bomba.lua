local Classe = require "classes.classic"
local Vector = require "classes.vector"

local Bomba = Classe:extend()

function Bomba:new(x, y, linha, coluna, item)
    self.posicao = Vector(x, y)
    self.linha = linha
    self.coluna = coluna
    self.item = item
    self.tempo = 0
end

function Bomba:detonar(inimigos, tocar)
    for _, inimigo in ipairs(inimigos) do
        if inimigo.vida > 0 and self.posicao:dist(inimigo.posicao) <= self.item.raio then
            inimigo:receberDano(self.item.dano)
        end
    end
    tocar("bomba")
end

function Bomba:update(dt)
    self.tempo = self.tempo + dt
    return self.tempo + 1e-9 >= self.item.duracao
end

function Bomba:draw(recursos)
    recursos:animar("explosao", recursos.quadros.explosao, self.tempo, 0.1,
        self.posicao.x - 50, self.posicao.y - 35)
end

return Bomba
