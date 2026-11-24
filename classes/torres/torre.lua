local Classe = require "classes.classic"
local Vector = require "classes.vector"

local Torre = Classe:extend()

function Torre:new(x, y, item)
    self.posicao = Vector(x, y)
    self.item = item
    self.carga = item.cargaInicial
    self.atacando = false
end

function Torre:inimigoAlvo(inimigos)
    local alvo
    for _, inimigo in ipairs(inimigos) do
        if inimigo.vida > 0 and (not alvo or inimigo.progresso > alvo.progresso)
            and self.posicao:dist(inimigo.posicao) <= self.item.raio then
            alvo = inimigo
        end
    end
    return alvo
end

function Torre:update(dt, inimigos, tocar)
    local alvo = self:inimigoAlvo(inimigos)
    self.atacando = alvo ~= nil
    if not alvo then
        return
    end

    self.carga = self.carga + dt
    if self.carga + 1e-9 < self.item.intervalo then
        return
    end

    self.carga = math.max(0, self.carga - self.item.intervalo)
    if self.item.tipo == "lentidao" then
        alvo:aplicarLentidao(self.item.reducao, self.item.duracao)
        tocar("lentidao")
    else
        alvo:receberDano(self.item.dano)
        tocar("tiro")
    end
end

function Torre:draw(recursos, tempo)
    local quadros = self.atacando and recursos.quadros.ataque or recursos.quadros.patrulha
    local x, y = self.posicao.x, self.posicao.y
    if self.item.cor then
        love.graphics.setColor(self.item.cor)
    end
    recursos:animar("torre", quadros, tempo, 0.1, x - 50, y - 50)
    love.graphics.setColor(1, 1, 1)
end

return Torre
