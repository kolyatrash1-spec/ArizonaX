--[[
    ArizonaX ESP System v1.0
    Arizona Mode compatible object detection and visualization
    Object IDs for Arizona RP: 964 (crate), 1271 (small box), 1431 (buried chest)
]]

local esp = {
    enabled = true,
    drawLines = true,
    maxDistance = 250,
    objects = {},
    
    -- Object model IDs for Arizona RP
    targetObjects = {
        964,    -- Пластиковый ящик (основной клад)
        1271,   -- Маленькая коробка
        1431    -- Закопанный ящик
    },
    
    colors = {
        target = 0xFFF44336,    -- Red
        text = 0xFFFFFFFF,      -- White
        line = 0xFF2196F3       -- Blue
    }
}

--[[
    Расстояние между двумя точками
]]
local function getDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--[[
    Преобразование 3D в 2D координаты
]]
local function convert3DTo2D(x, y, z)
    local ok, screenX, screenY = pcall(convert3DCoordsToScreen, x, y, z)
    if ok and screenX and screenY then
        return screenX, screenY
    end
    return nil, nil
end

--[[
    Сканирование объектов мира
]]
function esp:scan(playerX, playerY, playerZ)
    -- Очищаем старые объекты
    self.objects = {}
    
    -- Сканируем все объекты в радиусе
    for objectId = 1, 2000 do
        local ok, x, y, z = pcall(getObjectPos, objectId)
        
        if ok and x and y and z then
            local dist = getDistance(playerX, playerY, playerZ, x, y, z)
            
            if dist <= self.maxDistance then
                -- Получаем модель объекта
                local ok2, modelId = pcall(getObjectModel, objectId)
                
                if ok2 and modelId then
                    -- Проверяем, целевой ли это объект
                    for _, targetModel in ipairs(self.targetObjects) do
                        if modelId == targetModel then
                            table.insert(self.objects, {
                                id = objectId,
                                modelId = modelId,
                                x = x,
                                y = y,
                                z = z,
                                dist = dist
                            })
                            break
                        end
                    end
                end
            end
        end
    end
end

--[[
    Отрисовка маркера
]]
local function drawMarker(x, y, color, size)
    size = size or 8
    -- Центральная точка
    renderDrawBox(x - 2, y - 2, x + 2, y + 2, color)
    -- Крест
    renderDrawLine(x - size, y, x + size, y, color, 1)
    renderDrawLine(x, y - size, x, y + size, color, 1)
end

--[[
    Отрисовка ESP
]]
function esp:render(playerX, playerY, playerZ)
    if not self.enabled or #self.objects == 0 then
        return
    end
    
    -- Сканируем объекты
    self:scan(playerX, playerY, playerZ)
    
    for _, obj in ipairs(self.objects) do
        local screenX, screenY = convert3DTo2D(obj.x, obj.y, obj.z)
        
        if screenX and screenY then
            -- Рисуем маркер
            drawMarker(screenX, screenY, self.colors.target, 8)
            
            -- Рисуем текст с расстоянием
            local text = "Clad [" .. math.floor(obj.dist) .. "m]"
            renderFontDrawText(nil, text, screenX + 15, screenY - 8, self.colors.text)
            
            -- Рисуем линию если нужно
            if self.drawLines and obj.dist < 200 then
                local playerScreenX, playerScreenY = convert3DTo2D(playerX, playerY, playerZ)
                if playerScreenX and playerScreenY then
                    renderDrawLine(playerScreenX, playerScreenY, screenX, screenY, 
                                 self.colors.line, 1)
                end
            end
        end
    end
end

--[[
    Получить статистику
]]
function esp:getStats()
    return {
        count = #self.objects,
        enabled = self.enabled,
        distance = self.maxDistance
    }
end

return esp
