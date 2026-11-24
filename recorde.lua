local Recorde = {}
local arquivo = "recorde.txt"
local inteiroMaximo = 2 ^ 53 - 1

function Recorde.carregar(arquivos)
    local texto = arquivos.read(arquivo)
    if texto then
        local onda, abates = texto:match("^(%d+) (%d+)%s*$")
        onda, abates = tonumber(onda), tonumber(abates)
        if onda and abates and onda <= inteiroMaximo and abates <= inteiroMaximo then
            return {onda = onda, abates = abates}
        end
    end
    return {onda = 0, abates = 0}
end

function Recorde.registrar(arquivos, recorde, partida, pendente)
    if partida.onda > recorde.onda or (partida.onda == recorde.onda and partida.abates > recorde.abates) then
        recorde = {onda = partida.onda, abates = partida.abates}
        pendente = true
    end
    if pendente then
        local salvo = arquivos.write(arquivo, string.format("%d %d\n", recorde.onda, recorde.abates))
        return recorde, not salvo
    end
    return recorde, false
end

return Recorde
