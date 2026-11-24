local Config = require "configuracao"
local Partida = require "partida"
local Inimigo = require "classes.personagens.inimigo"
local Loja = require "classes.background.loja"
local Recorde = require "recorde"

local total = 0
local function teste(nome, executar)
    executar()
    total = total + 1
    print("OK  " .. nome)
end

local function aproximar(obtido, esperado)
    assert(math.abs(obtido - esperado) < 1e-7, ("Esperado %.8f, obtido %.8f"):format(esperado, obtido))
end

local function comprar(partida, lojaX, x, y)
    partida:clicar(lojaX, 550)
    partida:clicar(x, y)
end

local function passos(partida, quantidade)
    for _ = 1, quantidade do
        partida:update(Config.passo)
    end
end

local function partidaEmOnda(tocar)
    local partida = Partida(tocar)
    partida:iniciarOnda()
    partida.gerados = partida.configOnda.quantidade
    return partida
end

local function zumbiRapido(progresso, vida)
    local inimigo = Inimigo(Config.tiposZumbi.rapido, 1, 0)
    inimigo:mover(progresso / inimigo.tipo.velocidade)
    if vida then
        inimigo:receberDano(inimigo.vida - vida)
    end
    return inimigo
end

teste("tiro letal na entrada da casa é contado apenas como abate", function()
    local sons = {}
    local partida = partidaEmOnda(function(som) sons[#sons + 1] = som end)
    comprar(partida, 450, 150, 350)
    partida.torres[1].carga = 0.8
    local invasor = zumbiRapido(1649.75, 20)
    partida.inimigos = {invasor}

    passos(partida, 1)

    assert(partida.vida == 100 and partida.invasoes == 0 and partida.abates == 1)
    assert(partida.moedas == 41 and #partida.inimigos == 0)
    assert(table.concat(sons, ",") == "tiro,abate")
end)

teste("bônus ao cruzar 20 abates preserva o excedente", function()
    local partida = partidaEmOnda()
    partida.abates = 19
    partida.abatesParaBonus = 19
    partida.vida = 100
    partida.inimigos = {zumbiRapido(0, 0), zumbiRapido(0, 0)}

    passos(partida, 2)

    assert(partida.abates == 21 and partida.abatesParaBonus == 1)
    assert(partida.vida == 110 and partida.moedas == 62)
end)

teste("torres escolhem pelo progresso e pulam alvos mortos", function()
    local partida = partidaEmOnda()
    comprar(partida, 450, 350, 250)
    comprar(partida, 450, 550, 250)
    local primeiro, avancado = zumbiRapido(866), zumbiRapido(870, 20)
    partida.inimigos = {primeiro, avancado}
    for _, torre in ipairs(partida.torres) do
        torre.carga = 0.8
        assert(torre:inimigoAlvo(partida.inimigos) == avancado)
    end
    local empate = zumbiRapido(870)
    assert(partida.torres[1]:inimigoAlvo({avancado, empate}) == avancado)

    passos(partida, 1)

    assert(partida.abates == 1 and primeiro.vida == 80)
    primeiro:receberDano(20)
    aproximar(primeiro:proporcaoVida(), 0.6)
    primeiro:receberDano(100)
    assert(primeiro:proporcaoVida() == 0)
end)

teste("derrota é terminal e uma nova partida começa limpa", function()
    local partida = partidaEmOnda()
    partida.vida = 5
    partida.inimigos = {zumbiRapido(1649.75)}
    partida:clicar(450, 550)

    passos(partida, 1)
    assert(partida.fase == "derrota" and partida.vida == 0 and partida.invasoes == 1)
    assert(not partida.selecionado)
    local tempo = partida.tempo
    passos(partida, 100)
    comprar(partida, 450, 150, 350)
    partida:alternarPausa()
    assert(partida.fase == "derrota" and partida.vida == 0 and partida.tempo == tempo)
    assert(partida.moedas == 60 and not partida.pausada and #partida.torres == 0)

    local nova = Partida()
    assert(nova.fase == "preparacao" and nova.vida == 100 and nova.moedas == 60)
    assert(nova.onda == 0 and nova.abates == 0 and nova.invasoes == 0 and nova.tempoFase == 12)
    assert(#nova.inimigos == 0 and #nova.torres == 0 and #nova.bombas == 0)
end)

teste("cliques consecutivos validam limites, terreno, ocupação e saldo", function()
    local partida = Partida()
    partida:clicar(450, 550)
    partida:clicar(201, 600)
    assert(partida.mensagem == "Fora do mapa" and partida.moedas == 60)
    partida:clicar(-1, 250)
    assert(partida.mensagem == "Fora do mapa" and partida.moedas == 60)
    partida:clicar(250, 250)
    assert(partida.mensagem == "Use um bloco de grama" and partida.moedas == 60)
    local previa = Loja.previa(partida, 200, 100)
    assert(previa.motivo and previa.x == 250 and previa.y == 130)
    partida:clicar(350, 250)
    assert(#partida.torres == 1 and not partida.selecionado and partida.moedas == 40)
    comprar(partida, 450, 350, 250)
    assert(partida.mensagem == "Célula ocupada" and partida.moedas == 40)
    partida:cancelarSelecao()
    assert(not partida.selecionado and not partida.mensagem)

    comprar(partida, 650, 550, 250)
    assert(partida.torres[2].item.tipo == "lentidao" and partida.moedas == 15)
    partida:clicar(450, 550)
    assert(partida.mensagem == "Moedas insuficientes" and not partida.selecionado)
end)

teste("bomba usa o raio da prévia, explode uma vez e libera a célula", function()
    local explosoes = 0
    local partida = partidaEmOnda(function(som)
        if som == "bomba" then
            explosoes = explosoes + 1
        end
    end)
    local dentro, fora = zumbiRapido(1450), zumbiRapido(1451)
    partida.inimigos = {dentro, fora}
    partida:clicar(550, 550)
    local previa = Loja.previa(partida, 201, 299)
    assert(not previa.motivo and previa.x == 250 and previa.y == 230)
    aproximar(dentro.posicao.y - previa.y, previa.item.raio)
    partida:clicar(201, 299)
    assert(partida.bombas[1].posicao.x == previa.x and partida.bombas[1].posicao.y == previa.y)
    assert(dentro.vida == 20 and fora.vida == 100 and explosoes == 1 and partida.moedas == 50)

    comprar(partida, 550, 201, 299)
    assert(partida.mensagem == "Célula ocupada" and partida.moedas == 50)
    passos(partida, 107)
    assert(#partida.bombas == 1 and explosoes == 1 and dentro.vida == 20)
    passos(partida, 1)
    assert(#partida.bombas == 0 and not partida.ocupacao[3][3])
    partida:clicar(201, 299)
    assert(#partida.bombas == 1 and partida.moedas == 40 and explosoes == 2)
end)

teste("lentidão reduz o movimento, renova a duração e não causa dano", function()
    local partida = partidaEmOnda()
    comprar(partida, 650, 550, 250)
    local torre = partida.torres[1]
    local inimigo = zumbiRapido(840)
    partida.inimigos = {inimigo}
    torre.carga = 1
    passos(partida, 1)
    assert(inimigo.vida == 100 and inimigo.lentidaoRestante > 1.98)
    aproximar(inimigo.progresso - 840, 80 * Config.passo * 0.65)
    local progresso = inimigo.progresso
    inimigo:aplicarLentidao(0.35, 2)
    inimigo:aplicarLentidao(0.35, 2)
    inimigo:mover(2.25)
    aproximar(inimigo.progresso - progresso, 80 * (2 * 0.65 + 0.25))
    assert(inimigo.lentidaoRestante == 0)
end)

teste("movimento usa o restante do passo após uma curva", function()
    local inimigo = zumbiRapido(0)
    inimigo:mover(3)
    aproximar(inimigo.posicao.x, 650)
    aproximar(inimigo.posicao.y, 170)
    aproximar(inimigo.progresso, 240)
end)

teste("pausa congela preparação e a onda spawna no tempo previsto", function()
    local partida = Partida()
    passos(partida, 120)
    partida:alternarPausa()
    local tempo, tempoFase = partida.tempo, partida.tempoFase
    passos(partida, 240)
    comprar(partida, 450, 350, 250)
    assert(partida.tempo == tempo and partida.tempoFase == tempoFase and #partida.torres == 0)
    partida:alternarPausa()
    passos(partida, 1319)
    assert(partida.fase == "preparacao" and #partida.inimigos == 0)
    passos(partida, 1)
    assert(partida.fase == "onda" and partida.onda == 1 and partida.gerados == 1)
    assert(partida:inimigosRestantes() == 6)
    passos(partida, 335)
    assert(partida.gerados == 1)
    passos(partida, 1)
    assert(partida.gerados == 2 and partida:inimigosRestantes() == 6)
end)

local function abrirComTresTorres(partida)
    comprar(partida, 450, 350, 250)
    comprar(partida, 450, 550, 250)
    comprar(partida, 450, 550, 350)
end

local function assinatura(partida)
    local partes = {
        partida.fase, partida.onda, partida.vida, partida.abates, partida.invasoes, partida.moedas,
    }
    for _, inimigo in ipairs(partida.inimigos) do
        partes[#partes + 1] = ("%.9f,%.9f,%d"):format(inimigo.posicao.x, inimigo.posicao.y, inimigo.vida)
    end
    return table.concat(partes, "|")
end

teste("10, 30, 60 e 144 FPS produzem os mesmos estados", function()
    local referencia = {}
    local instantes = {13, 22, 35, 50, 65, 95}
    for _, fps in ipairs({10, 30, 60, 144}) do
        local partida = Partida()
        abrirComTresTorres(partida)
        local quadro = 0
        for _, instante in ipairs(instantes) do
            for _ = quadro + 1, instante * fps do
                partida:update(1 / fps)
            end
            quadro = instante * fps
            local estado = assinatura(partida)
            referencia[instante] = referencia[instante] or estado
            assert(estado == referencia[instante], ("Divergência em %d FPS no segundo %d"):format(fps, instante))
        end
    end
end)

local function simularTresOndas(partida, usarBomba)
    local bombaUsada = false
    for _ = 1, 240 * 60 do
        if usarBomba and not bombaUsada and partida.fase == "onda" then
            for _, inimigo in ipairs(partida.inimigos) do
                if inimigo.vida <= 80 and inimigo.progresso >= 690 and inimigo.progresso <= 960 then
                    comprar(partida, 550, 450, 350)
                    bombaUsada = #partida.bombas == 1
                    break
                end
            end
        end
        partida:update(1 / 60)
        if partida.fase == "derrota" or (partida.fase == "intervalo" and partida.onda == 3) then
            return bombaUsada
        end
    end
    error("As três primeiras ondas não terminaram no tempo de simulação")
end

teste("aberturas de três torres, composição mista e sem compras", function()
    local semCompras = Partida()
    simularTresOndas(semCompras)
    assert(semCompras.fase == "derrota" and semCompras.onda == 3)

    local torres = Partida()
    abrirComTresTorres(torres)
    simularTresOndas(torres)
    assert(torres.fase == "intervalo" and torres.onda == 3 and torres.abates == 24)

    local mista = Partida()
    comprar(mista, 450, 350, 250)
    comprar(mista, 650, 550, 250)
    assert(simularTresOndas(mista, true))
    assert(mista.fase == "intervalo" and mista.onda == 3)
    print(("    Três torres: %d vida, %d abates. Mista: onda %d, %d vida, %d abates."):format(
        torres.vida, torres.abates, mista.onda, mista.vida, mista.abates))
end)

teste("ondas avançam, mantêm intervalo mínimo e escalam a vida", function()
    local partida = partidaEmOnda()
    passos(partida, 1)
    assert(partida.fase == "intervalo" and partida.tempoFase == 10)
    passos(partida, 1199)
    assert(partida.fase == "intervalo")
    passos(partida, 1)
    assert(partida.fase == "onda" and partida.onda == 2 and partida:inimigosRestantes() == 8)

    local quarta = Config.onda(4)
    assert(quarta.quantidade == 12 and quarta.multiplicadorVida == 1 and quarta.sequencia[6] == "tanque")
    local longa = Config.onda(20)
    assert(longa.quantidade == 44 and longa.intervalo == 0.9)
    aproximar(longa.multiplicadorVida, 2.28)
end)

teste("recorde salvo compara onda e abates, e ignora arquivos inválidos", function()
    local conteudo
    local gravacoes = 0
    local arquivos = {
        read = function() return conteudo end,
        write = function(_, texto)
            conteudo = texto
            gravacoes = gravacoes + 1
            return true
        end,
    }
    assert(Recorde.carregar(arquivos).onda == 0)
    for _, invalido in ipairs({"{7, 2", "100000000000000000000 2"}) do
        conteudo = invalido
        assert(Recorde.carregar(arquivos).onda == 0)
    end
    local melhor = Recorde.registrar(arquivos, Recorde.carregar(arquivos), {onda = 3, abates = 10})
    assert(gravacoes == 1 and Recorde.carregar(arquivos).abates == 10)
    melhor = Recorde.registrar(arquivos, melhor, {onda = 2, abates = 15})
    assert(gravacoes == 1 and melhor.onda == 3)
    melhor = Recorde.registrar(arquivos, melhor, {onda = 3, abates = 11})
    assert(gravacoes == 2 and melhor.abates == 11)

    local escrever = arquivos.write
    arquivos.write = function() return false end
    local novo, erro = Recorde.registrar(arquivos, melhor, {onda = 4, abates = 15})
    assert(erro and novo.onda == 4 and Recorde.carregar(arquivos).onda == 3)
    arquivos.write = escrever
    novo, erro = Recorde.registrar(arquivos, novo, {onda = 3, abates = 15}, erro)
    assert(not erro and novo.onda == 4 and Recorde.carregar(arquivos).onda == 4)
end)

print(("%d verificações concluídas."):format(total))
