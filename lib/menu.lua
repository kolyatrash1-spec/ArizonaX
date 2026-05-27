--[[
    ArizonaX Mobile Menu System v1.0
    Fully compatible with MonetLoader for Arizona Mode
    Mobile UI with drag-and-drop, buttons, and sliders
]]

local menu = {
    x = 50,
    y = 50,
    width = 280,
    height = 400,
    visible = true,
    dragging = false,
    dragOffsetX = 0,
    dragOffsetY = 0,
    
    --색상 설정
    colors = {
        header = 0xFF2196F3,
        background = 0xFF1E1E1E,
        button = 0xFF424242,
        buttonHover = 0xFF616161,
        text = 0xFFFFFFFF,
        border = 0xFF424242
    },
    
    -- Слайдеры
    sliders = {
        distance = { value = 250, min = 50, max = 500, label = "Distance:" },
        opacity = { value = 100, min = 0, max = 100, label = "Opacity:" }
    }
}

--[[
    Проверка находится ли точка в области
]]
local function isPointInArea(px, py, ax, ay, aw, ah)
    return px >= ax and py >= ay and px <= ax + aw and py <= ay + ah
end

--[[
    Отрисовка прямоугольника с границей
]]
local function drawRectWithBorder(x1, y1, x2, y2, color, borderColor)
    renderDrawBox(x1, y1, x2, y2, color)
    renderDrawLine(x1, y1, x2, y1, borderColor, 1)
    renderDrawLine(x2, y1, x2, y2, borderColor, 1)
    renderDrawLine(x2, y2, x1, y2, borderColor, 1)
    renderDrawLine(x1, y2, x1, y1, borderColor, 1)
end

--[[
    Отрисовка кнопки
]]
function menu:drawButton(x, y, width, height, label, mouseX, mouseY)
    local isHovered = isPointInArea(mouseX, mouseY, x, y, width, height)
    local btnColor = isHovered and self.colors.buttonHover or self.colors.button
    
    drawRectWithBorder(x, y, x + width, y + height, btnColor, self.colors.border)
    renderFontDrawText(nil, label, x + 10, y + 8, self.colors.text)
    
    return isHovered
end

--[[
    Отрисовка слайдера
]]
function menu:drawSlider(x, y, width, sliderId, mouseX, mouseY, mouseDown)
    local slider = self.sliders[sliderId]
    if not slider then return end
    
    renderFontDrawText(nil, slider.label, x + 10, y + 5, self.colors.text)
    
    -- Track
    local trackY = y + 25
    renderDrawBox(x + 10, trackY, x + width - 10, trackY + 4, self.colors.button)
    
    -- Handle position
    local trackWidth = width - 20
    local percent = (slider.value - slider.min) / (slider.max - slider.min)
    local handleX = x + 10 + percent * trackWidth
    
    -- Progress bar
    renderDrawBox(x + 10, trackY, handleX, trackY + 4, self.colors.header)
    
    -- Handle
    renderDrawBox(handleX - 4, trackY - 4, handleX + 4, trackY + 8, self.colors.header)
    
    -- Value text
    renderFontDrawText(nil, tostring(math.floor(slider.value)), x + width - 40, y + 5, self.colors.text)
    
    -- Handle mouse interaction
    if mouseDown and mouseY >= trackY - 8 and mouseY <= trackY + 12 then
        if mouseX >= x + 10 and mouseX <= x + width - 10 then
            local newPercent = (mouseX - x - 10) / trackWidth
            newPercent = math.max(0, math.min(1, newPercent))
            slider.value = slider.min + newPercent * (slider.max - slider.min)
        end
    end
end

--[[
    Отрисовка меню
]]
function menu:draw(mouseX, mouseY, mouseDown)
    if not self.visible then return end
    
    -- Заголовок (для drag-and-drop)
    local headerHeight = 30
    local isInHeader = isPointInArea(mouseX, mouseY, self.x, self.y, self.width, headerHeight)
    
    if mouseDown and isInHeader then
        if not self.dragging then
            self.dragging = true
            self.dragOffsetX = mouseX - self.x
            self.dragOffsetY = mouseY - self.y
        end
    else
        self.dragging = false
    end
    
    if self.dragging then
        self.x = mouseX - self.dragOffsetX
        self.y = mouseY - self.dragOffsetY
        
        -- Ограничиваем движение
        local screenX, screenY = getScreenResolution()
        if self.x < 0 then self.x = 0 end
        if self.y < 0 then self.y = 0 end
        if self.x + self.width > screenX then self.x = screenX - self.width end
        if self.y + self.height > screenY then self.y = screenY - self.height end
    end
    
    -- Фон меню
    drawRectWithBorder(self.x, self.y, self.x + self.width, self.y + self.height, 
                       self.colors.background, self.colors.border)
    
    -- Заголовок
    renderDrawBox(self.x, self.y, self.x + self.width, self.y + headerHeight, self.colors.header)
    renderFontDrawText(nil, "Arizona ESP", self.x + 10, self.y + 7, self.colors.text)
    
    -- Кнопки
    local btnY = self.y + headerHeight + 10
    
    if self:drawButton(self.x + 10, btnY, self.width - 20, 35, "🎯 Toggle ESP", mouseX, mouseY) then
        if mouseDown then
            sendCommand("/esp")
        end
    end
    
    btnY = btnY + 40
    if self:drawButton(self.x + 10, btnY, self.width - 20, 35, "📍 Lines", mouseX, mouseY) then
        if mouseDown then
            sendCommand("/esplines")
        end
    end
    
    btnY = btnY + 40
    if self:drawButton(self.x + 10, btnY, self.width - 20, 35, "🔄 Clear", mouseX, mouseY) then
        if mouseDown then
            sendCommand("/espclear")
        end
    end
    
    -- Слайдеры
    btnY = btnY + 45
    self:drawSlider(self.x, btnY, self.width, "distance", mouseX, mouseY, mouseDown)
    
    btnY = btnY + 50
    self:drawSlider(self.x, btnY, self.width, "opacity", mouseX, mouseY, mouseDown)
end

--[[
    Переключить видимость меню
]]
function menu:toggle()
    self.visible = not self.visible
end

return menu
