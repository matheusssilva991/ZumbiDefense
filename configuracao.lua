local Config = {
    largura = 800,
    altura = 600,
    tamanhoCelula = 100,
    passo = 1 / 120,
    preparacao = 12,
    intervalo = 10,
    moedasIniciais = 60,
    vidaInicial = 100,
    abatesPorBonus = 20,
    vidaPorBonus = 10,
    mapa = {
        {1,1,1,1,1,1,1,1},
        {1,1,2,2,2,1,2,2},
        {1,1,2,1,2,1,2,1},
        {1,1,2,1,2,1,2,1},
        {3,2,2,1,2,2,2,1},
        {3,3,3,3,4,5,6,3},
    },
    caminho = {
        {850, 130}, {650, 130}, {650, 430}, {450, 430},
        {450, 130}, {250, 130}, {250, 430}, {100, 430},
    },
    tiposZumbi = {
        rapido = {velocidade = 80, dano = 5, vida = 100, moedas = 1, quadro = 1},
        medio = {velocidade = 40, dano = 10, vida = 200, moedas = 2, quadro = 3},
        resistente = {velocidade = 25, dano = 15, vida = 300, moedas = 3, quadro = 4},
        tanque = {velocidade = 15, dano = 20, vida = 400, moedas = 4, quadro = 2},
    },
    loja = {
        [4] = {
            tipo = "tiro", nome = "Tiro", preco = 20, terreno = 1,
            raio = 150, dano = 20, intervalo = 0.8, cargaInicial = 0.21,
        },
        [5] = {
            tipo = "bomba", nome = "Bomba", preco = 10, terreno = 2,
            raio = 150, dano = 80, duracao = 0.9,
        },
        [6] = {
            tipo = "lentidao", nome = "Lentidão", preco = 25, terreno = 1,
            raio = 130, intervalo = 1, cargaInicial = 0,
            reducao = 0.35, duracao = 2, cor = {0.3, 0.9, 1},
        },
    },
}

local ondasIniciais = {
    {"rapido", "rapido", "rapido", "rapido", "rapido", "rapido"},
    {"rapido", "rapido", "medio", "rapido", "medio", "rapido", "medio", "rapido"},
    {"rapido", "medio", "rapido", "medio", "rapido", "resistente", "rapido", "medio", "rapido", "medio"},
}
local ciclo = {"rapido", "medio", "rapido", "resistente", "medio", "tanque"}

function Config.onda(numero)
    return {
        quantidade = 4 + 2 * numero,
        intervalo = math.max(0.9, 3 - 0.2 * numero),
        multiplicadorVida = 1 + 0.08 * math.max(0, numero - 4),
        sequencia = ondasIniciais[numero] or ciclo,
    }
end

function Config.celulaEm(x, y)
    local linha = math.floor(y / Config.tamanhoCelula) + 1
    local coluna = math.floor(x / Config.tamanhoCelula) + 1
    local fileira = Config.mapa[linha]
    if fileira and fileira[coluna] then
        return linha, coluna, fileira[coluna]
    end
end

function Config.origemCelula(linha, coluna)
    return (coluna - 1) * Config.tamanhoCelula, (linha - 1) * Config.tamanhoCelula
end

function Config.centroCombate(linha, coluna)
    local x, y = Config.origemCelula(linha, coluna)
    -- Mantém o centro de combate 20 px acima do centro geométrico da célula.
    return x + Config.tamanhoCelula / 2, y + Config.tamanhoCelula / 2 - 20
end

return Config
