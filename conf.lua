local Config = require "configuracao"

function love.conf(t)
    t.identity = "zumbi-defense"
    t.window.title = "Zumbi Defense: A Última Resistência"
    t.window.width = Config.largura
    t.window.height = Config.altura
end
