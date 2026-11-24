local Moeda = {}

function Moeda.draw(recursos, tempo, quantidade)
    recursos:animar("moeda", recursos.quadros.moeda, tempo, 0.1, 18, 511, 0.12)
    love.graphics.print("x" .. quantidade, 55, 520)
end

return Moeda
