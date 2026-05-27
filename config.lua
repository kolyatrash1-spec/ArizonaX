--[[
    Arizona Mode Object Database
    Клады (сокровища) на Arizona RP
    
    Object IDs:
    964 - Plastic crate (основной вид клада)
    1271 - Small box
    1431 - Buried chest
]]

local config = {
    -- Основные настройки ESP
    esp = {
        enabled = true,
        maxDistance = 500,  -- метры
        drawLines = true,
        refreshInterval = 1000  -- миллисекунды
    },
    
    -- UI настройки
    ui = {
        menuX = 50,
        menuY = 50,
        menuWidth = 280,
        menuHeight = 400
    },
    
    -- Известные локации кладов в Arizona RP
    -- (примеры для тестирования)
    treasures = {
        {
            name = "LS Downtown",
            modelId = 964,
            x = 1350.123,
            y = -1750.321,
            z = 13.471
        },
        {
            name = "Las Venturas",
            modelId = 964,
            x = 2510.151,
            y = -1685.341,
            z = 14.078
        },
        {
            name = "San Fierro North",
            modelId = 964,
            x = -2030.600,
            y = 260.120,
            z = 35.233
        },
        {
            name = "LV Suburbs",
            modelId = 964,
            x = 2215.787,
            y = -1162.134,
            z = 26.237
        },
        {
            name = "Rural Area",
            modelId = 1271,
            x = 1223.720,
            y = 2035.810,
            z = 10.820
        }
    },
    
    -- Цветовая схема
    colors = {
        primary = 0xFF2196F3,     -- Синий
        secondary = 0xFF424242,   -- Серый
        success = 0xFF4CAF50,     -- Зеленый
        warning = 0xFFFF9800,     -- Оранжевый
        danger = 0xFFF44336,      -- Красный
        text = 0xFFFFFFFF         -- Белый
    }
}

--[[
    Получить все ID объектов для сканирования
]]
function config:getTargetModelIds()
    return {964, 1271, 1431}
end

--[[
    Получить позицию по названию локации
]]
function config:getTreasureByName(name)
    for _, treasure in ipairs(self.treasures) do
        if treasure.name == name then
            return treasure
        end
    end
    return nil
end

--[[
    Получить все локации
]]
function config:getAllTreasures()
    return self.treasures
end

--[[
    Добавить новую локацию клада
]]
function config:addTreasure(name, modelId, x, y, z)
    table.insert(self.treasures, {
        name = name,
        modelId = modelId,
        x = x,
        y = y,
        z = z
    })
end

return config
