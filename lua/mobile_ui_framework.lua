--[[
    ArizonaX Mobile UI Framework v2.0.0
    Advanced MoonLoader UI System for SAMP Mobile
    
    Features:
    - Drag-and-drop menu system
    - Interactive buttons with callbacks
    - Smooth sliders with range control
    - Dynamic scaling for different screen sizes
    - Optimized rendering with caching
    - Material Design color palette
]]

local UIFramework = {
    state = {
        menuVisible = true,
        menuX = 50,
        menuY = 50,
        scale = 1.0,
        dragging = false,
        dragOffsetX = 0,
        dragOffsetY = 0,
        fonts = {
            main = nil,
            small = nil
        },
        sliderValues = {},
        buttonCallbacks = {}
    },
    
    config = {
        menu_width = 280,
        menu_height = 400,
        header_height = 30,
        button_height = 35,
        slider_height = 45,
        padding = 10,
        margin = 5
    },
    
    colors = {
        header = 0xFF2196F3,        -- Blue
        background = 0xFF1E1E1E,    -- Dark black
        button = 0xFF424242,        -- Gray
        button_hover = 0xFF616161,  -- Light gray
        slider_bg = 0xFF424242,     -- Gray
        slider_active = 0xFF2196F3, -- Blue
        text = 0xFFFFFFFF,          -- White
        text_shadow = 0xFF000000,   -- Black
        border = 0xFF424242         -- Gray
    }
}

--[[
    Initialize fonts (called once at startup)
]]
function UIFramework:initializeFonts()
    if self.state.fonts.main == nil then
        self.state.fonts.main = renderCreateFont("Arial", 18, 4)
    end
    if self.state.fonts.small == nil then
        self.state.fonts.small = renderCreateFont("Arial", 14, 4)
    end
end

--[[
    Initialize scaling based on screen resolution
]]
function UIFramework:initializeScaling()
    local screenX, screenY = getScreenResolution()
    
    -- Scale based on screen height
    if screenY >= 1920 then
        self.state.scale = 1.2
    elseif screenY >= 1440 then
        self.state.scale = 1.0
    elseif screenY >= 1080 then
        self.state.scale = 0.85
    else
        self.state.scale = 0.7
    end
end

--[[
    Toggle menu visibility
]]
function UIFramework:toggleMenu()
    self.state.menuVisible = not self.state.menuVisible
end

--[[
    Set menu visibility
]]
function UIFramework:setMenuVisible(visible)
    self.state.menuVisible = visible
end

--[[
    Set menu position
]]
function UIFramework:setMenuPosition(x, y)
    self.state.menuX = x
    self.state.menuY = y
    self:clampMenuPosition()
end

--[[
    Get menu position
]]
function UIFramework:getMenuPosition()
    return self.state.menuX, self.state.menuY
end

--[[
    Get current state
]]
function UIFramework:getState()
    return self.state
end

--[[
    Check if point is in area
]]
function UIFramework:isPosInArea(px, py, ax, ay, aw, ah)
    return px >= ax and py >= ay and px <= ax + aw and py <= ay + ah
end

--[[
    Clamp menu position to screen boundaries
]]
function UIFramework:clampMenuPosition()
    local screenX, screenY = getScreenResolution()
    local width = self.config.menu_width * self.state.scale
    local height = self.config.menu_height * self.state.scale
    
    if self.state.menuX < 0 then
        self.state.menuX = 0
    end
    if self.state.menuX + width > screenX then
        self.state.menuX = screenX - width
    end
    
    if self.state.menuY < 0 then
        self.state.menuY = 0
    end
    if self.state.menuY + height > screenY then
        self.state.menuY = screenY - height
    end
end

--[[
    Register button callback
]]
function UIFramework:registerButton(id, label, x, y, width, height, callback)
    self.state.buttonCallbacks[id] = {
        label = label,
        x = x,
        y = y,
        width = width,
        height = height,
        callback = callback
    }
end

--[[
    Set slider value
]]
function UIFramework:setSliderValue(id, value)
    self.state.sliderValues[id] = value
end

--[[
    Get slider value
]]
function UIFramework:getSliderValue(id)
    return self.state.sliderValues[id] or 0
end

--[[
    Render button with click detection
]]
function UIFramework:renderButton(id, x, y, width, height, label, mouseX, mouseY, mouseButton)
    local config = self.config
    local colors = self.colors
    local padding = config.padding
    
    -- Check if mouse is over button
    local isHovered = self:isPosInArea(mouseX, mouseY, x, y, width, height)
    local buttonColor = isHovered and colors.button_hover or colors.button
    
    -- Draw button background
    renderDrawBoxWithBorder(x, y, x + width, y + height, buttonColor, 1, colors.border)
    
    -- Draw button text
    local textX = x + padding
    local textY = y + (height - 16) / 2
    renderFontDrawText(self.state.fonts.small, label, textX, textY, colors.text)
    
    -- Handle click
    if isHovered and mouseButton == 0x01 then
        local callback = self.state.buttonCallbacks[id]
        if callback and callback.callback then
            callback.callback()
        end
        return true
    end
    
    return false
end

--[[
    Render slider with value control
]]
function UIFramework:renderSlider(id, label, min, max, x, y, width, mouseX, mouseY, mouseButton)
    local config = self.config
    local colors = self.colors
    local padding = config.padding
    
    -- Initialize slider value if not exists
    if not self.state.sliderValues[id] then
        self.state.sliderValues[id] = min
    end
    
    local value = self.state.sliderValues[id]
    local trackHeight = 4
    local handleSize = 16
    
    -- Draw label
    renderFontDrawText(self.state.fonts.small, label, x + padding, y + padding, colors.text)
    
    -- Draw track background
    local trackY = y + 20
    renderDrawBoxWithBorder(x + padding, trackY, x + width - padding, trackY + trackHeight, colors.slider_bg, 1, colors.border)
    
    -- Calculate handle position
    local trackWidth = width - padding * 2
    local valuePercent = (value - min) / (max - min)
    local handleX = x + padding + valuePercent * trackWidth
    
    -- Draw progress track
    renderDrawBox(x + padding, trackY, handleX, trackY + trackHeight, colors.slider_active)
    
    -- Draw handle
    renderDrawBoxWithBorder(
        handleX - handleSize / 2, trackY - (handleSize - trackHeight) / 2,
        handleX + handleSize / 2, trackY + (handleSize + trackHeight) / 2,
        colors.slider_active, 1, colors.text
    )
    
    -- Draw value text
    local valueText = string.format("%.0f", value)
    renderFontDrawText(self.state.fonts.small, valueText, x + width - 40, y + padding, colors.text)
    
    -- Handle mouse interaction
    local trackXStart = x + padding
    local trackXEnd = x + width - padding
    
    -- Check if clicking on track
    if mouseButton == 0x01 and mouseY >= trackY - 8 and mouseY <= trackY + trackHeight + 8 then
        if mouseX >= trackXStart and mouseX <= trackXEnd then
            local newPercent = (mouseX - trackXStart) / (trackXEnd - trackXStart)
            newPercent = math.max(0, math.min(1, newPercent))
            self.state.sliderValues[id] = min + newPercent * (max - min)
            return true
        end
    end
    
    return false
end

--[[
    Handle drag and drop
]]
function UIFramework:handleDragAndDrop(mouseX, mouseY, mouseButton)
    local headerX = self.state.menuX
    local headerY = self.state.menuY
    local headerW = self.config.menu_width * self.state.scale
    local headerH = self.config.header_height * self.state.scale
    
    local inHeader = self:isPosInArea(mouseX, mouseY, headerX, headerY, headerW, headerH)
    
    if mouseButton == 0x01 and inHeader then
        if not self.state.dragging then
            self.state.dragging = true
            self.state.dragOffsetX = mouseX - self.state.menuX
            self.state.dragOffsetY = mouseY - self.state.menuY
        end
    else
        self.state.dragging = false
    end
    
    if self.state.dragging then
        self.state.menuX = mouseX - self.state.dragOffsetX
        self.state.menuY = mouseY - self.state.dragOffsetY
        self:clampMenuPosition()
    end
end

--[[
    Render menu with buttons and sliders
]]
function UIFramework:renderMenu(mouseX, mouseY, mouseButton, buttons, sliders)
    if not self.state.menuVisible then
        return
    end
    
    local config = self.config
    local colors = self.colors
    local scale = self.state.scale
    
    local menuX = self.state.menuX
    local menuY = self.state.menuY
    local menuW = config.menu_width * scale
    local menuH = config.menu_height * scale
    
    -- Handle drag and drop
    if mouseButton == 0x01 then
        self:handleDragAndDrop(mouseX, mouseY, mouseButton)
    else
        self.state.dragging = false
    end
    
    -- Draw menu background
    renderDrawBoxWithBorder(menuX, menuY, menuX + menuW, menuY + menuH, colors.background, 2, colors.header)
    
    -- Draw header
    renderDrawBox(menuX, menuY, menuX + menuW, menuY + config.header_height * scale, colors.header)
    renderFontDrawText(self.state.fonts.main, "ArizonaX Menu", menuX + 10, menuY + 7, colors.text)
    
    -- Render buttons
    if buttons then
        local currentY = menuY + config.header_height * scale + config.padding
        
        for _, button in ipairs(buttons) do
            self:renderButton(
                button.id,
                menuX + config.padding,
                currentY,
                menuW - config.padding * 2,
                config.button_height * scale,
                button.label,
                mouseX,
                mouseY,
                mouseButton
            )
            currentY = currentY + config.button_height * scale + config.margin
        end
    end
    
    -- Render sliders
    if sliders then
        local currentY = menuY + config.header_height * scale + config.padding
        
        -- Calculate sliders starting position (below buttons)
        if buttons then
            currentY = currentY + (#buttons) * (config.button_height * scale + config.margin)
        end
        
        for _, slider in ipairs(sliders) do
            self:renderSlider(
                slider.id,
                slider.label,
                slider.min,
                slider.max,
                menuX + config.padding,
                currentY,
                menuW - config.padding * 2,
                mouseX,
                mouseY,
                mouseButton
            )
            currentY = currentY + config.slider_height * scale + config.margin
        end
    end
end

--[[
    Print debug information
]]
function UIFramework:printDebugInfo()
    sampAddChatMessage("[UI Debug] Menu: " .. self.state.menuX .. ", " .. self.state.menuY, 0x2196F3)
    sampAddChatMessage("[UI Debug] Scale: " .. string.format("%.2f", self.state.scale), 0x2196F3)
    sampAddChatMessage("[UI Debug] Visible: " .. (self.state.menuVisible and "YES" or "NO"), 0x2196F3)
    sampAddChatMessage("[UI Debug] Dragging: " .. (self.state.dragging and "YES" or "NO"), 0x2196F3)
end

return UIFramework
