local Classe = require "classes.classic"
local Config = require "configuracao"
local Inimigo = require "classes.personagens.inimigo"
local Torre = require "classes.torres.torre"
local Bomba = require "classes.torres.bomba"

local Partida = Classe:extend()
local epsilon = 1e-9

function Partida:new(tocar)
    self.tocar = tocar or function() end
    self.vida = Config.vidaInicial
    self.moedas = Config.moedasIniciais
    self.abates = 0
    self.abatesParaBonus = 0
    self.invasoes = 0
    self.onda = 0
    self.fase = "preparacao"
    self.pausada = false
    self.tempoFase = Config.preparacao
    self.tempo = 0
    self.acumulado = 0
    self.inimigos = {}
    self.torres = {}
    self.bombas = {}
    self.ocupacao = {}
    for linha in ipairs(Config.mapa) do
        self.ocupacao[linha] = {}
    end
end

function Partida:alternarPausa()
    if self.fase ~= "derrota" then
        self.pausada = not self.pausada
    end
end

function Partida:cancelarSelecao()
    self.selecionado = nil
    self.mensagem = nil
end

function Partida:motivoCompraInvalida(item, linha, coluna, terreno)
    if not linha then
        return "Fora do mapa"
    end
    if terreno ~= item.terreno then
        return item.terreno == 1 and "Use um bloco de grama" or "Use o caminho"
    end
    if self.ocupacao[linha][coluna] then
        return "Célula ocupada"
    end
    if self.moedas < item.preco then
        return "Moedas insuficientes"
    end
end

function Partida:clicar(x, y)
    if self.pausada or self.fase == "derrota" then
        return
    end

    local linha, coluna, terreno = Config.celulaEm(x, y)
    local item = Config.loja[terreno]
    if item then
        if self.moedas >= item.preco then
            self.selecionado = item
            self.mensagem = nil
        else
            self.mensagem = "Moedas insuficientes"
        end
        return
    end

    item = self.selecionado
    if not item then
        return
    end
    self.mensagem = self:motivoCompraInvalida(item, linha, coluna, terreno)
    if self.mensagem then
        return
    end

    local centroX, centroY = Config.centroCombate(linha, coluna)
    self.moedas = self.moedas - item.preco
    self.ocupacao[linha][coluna] = true
    self:cancelarSelecao()
    if item.tipo == "bomba" then
        local bomba = Bomba(centroX, centroY, linha, coluna, item)
        self.bombas[#self.bombas + 1] = bomba
        bomba:detonar(self.inimigos, self.tocar)
        self:resolverAbates()
    else
        self.torres[#self.torres + 1] = Torre(centroX, centroY, item)
    end
end

function Partida:resolverAbates()
    for i = #self.inimigos, 1, -1 do
        local inimigo = self.inimigos[i]
        if inimigo.vida == 0 then
            self.moedas = self.moedas + inimigo.tipo.moedas
            self.abates = self.abates + 1
            self.abatesParaBonus = self.abatesParaBonus + 1
            self.tocar("abate")
            table.remove(self.inimigos, i)
        end
    end

    local bonus = math.floor(self.abatesParaBonus / Config.abatesPorBonus)
    self.vida = self.vida + bonus * Config.vidaPorBonus
    self.abatesParaBonus = self.abatesParaBonus % Config.abatesPorBonus
end

function Partida:iniciarOnda()
    self.fase = "onda"
    self.onda = self.onda + 1
    self.configOnda = Config.onda(self.onda)
    self.gerados = 0
    self.tempoGeracao = 0
end

function Partida:gerarInimigo(dt)
    if self.gerados == self.configOnda.quantidade then
        return
    end
    if self.tempoGeracao <= epsilon then
        local sequencia = self.configOnda.sequencia
        local tipo = Config.tiposZumbi[sequencia[self.gerados % #sequencia + 1]]
        local inimigo = Inimigo(tipo, self.configOnda.multiplicadorVida, self.tempo)
        self.inimigos[#self.inimigos + 1] = inimigo
        self.gerados = self.gerados + 1
        self.tempoGeracao = self.tempoGeracao + self.configOnda.intervalo
        self.tocar("zumbi")
    end
    self.tempoGeracao = self.tempoGeracao - dt
end

function Partida:inimigosRestantes()
    return self.configOnda.quantidade - self.gerados + #self.inimigos
end

function Partida:simular(dt)
    self.tempo = self.tempo + dt
    for i = #self.bombas, 1, -1 do
        local bomba = self.bombas[i]
        if bomba:update(dt) then
            self.ocupacao[bomba.linha][bomba.coluna] = nil
            table.remove(self.bombas, i)
        end
    end

    if self.fase ~= "onda" then
        self.tempoFase = self.tempoFase - dt
        if self.tempoFase > epsilon then
            return
        end
        self:iniciarOnda()
    end

    self:gerarInimigo(dt)
    for _, torre in ipairs(self.torres) do
        torre:update(dt, self.inimigos, self.tocar)
    end
    self:resolverAbates()

    for i = #self.inimigos, 1, -1 do
        local inimigo = self.inimigos[i]
        if inimigo:mover(dt) then
            self.vida = math.max(0, self.vida - inimigo.tipo.dano)
            self.invasoes = self.invasoes + 1
            table.remove(self.inimigos, i)
        end
    end

    if self.vida == 0 then
        self.fase = "derrota"
        self:cancelarSelecao()
    elseif self:inimigosRestantes() == 0 then
        self.fase = "intervalo"
        self.tempoFase = Config.intervalo
    end
end

function Partida:update(dt)
    if self.pausada or self.fase == "derrota" then
        return
    end
    -- Limita a recuperação após uma suspensão longa da janela.
    self.acumulado = self.acumulado + math.min(dt, 0.25)
    while self.acumulado + epsilon >= Config.passo and self.fase ~= "derrota" do
        self.acumulado = math.max(0, self.acumulado - Config.passo)
        self:simular(Config.passo)
    end
end

return Partida
