--[[
    ArizonaX Mobile - Main Integration Script v2.0.0
    Complete integration of UI Framework and ESP System
    
    Commands:
    /mmenu - Toggle menu visibility
    /esp - Toggle ESP system
    /esplines - Toggle ESP lines
    /espstats - Show ESP statistics
    /uiinfo - Show UI information
]]

local UIFramework = require("lua.mobile_ui_framework")
local ESPSystem = require("lua.esp_system")

-- Configuration
local CONFIG = {
    ESP_OBJECTS = {
        -- Define object models to track
        -- Format: {modelId = "label", ...}
    },
    DEFAULT_DISTANCE = 250,
    DEFAULT_OPACITY = 100
}

-- Game state
local gameState = {
    initialized = false,
    lastPlayerX = 0,
    lastPlayerY = 0,
    lastPlayerZ = 0,
    uiInitialized = false
}

--[[
    Initialize main system
]]
function initializeSystem()
    if gameState.initialized then return end
    
    -- Wait for SAMP to be available
    while not isSampAvailable() do
        wait(100)
    end
    
    -- Initialize UI Framework
    UIFramework:initializeFonts()
    UIFramework:initializeScaling()
    
    -- Initialize ESP System
    ESPSystem:initialize(UIFramework.state.fonts.main, UIFramework.state.fonts.small)
    
    -- Register chat commands
    registerChatCommands()
    
    gameState.initialized = true
    sampAddChatMessage("[ArizonaX] System initialized successfully!", 0x2196F3)
end

--[[
    Register all chat commands
]]
function registerChatCommands()
    -- Toggle menu
    sampRegisterChatCommand("mmenu", function()
        UIFramework:toggleMenu()
        local visible = UIFramework.state.menuVisible
        sampAddChatMessage("[Menu] " .. (visible and "Opened ✓" or "Closed ✗"), 0x2196F3)
    end)
    
    -- Toggle ESP
    sampRegisterChatCommand("esp", function()
        local enabled = not ESPSystem.config.enabled
        ESPSystem:setEnabled(enabled)
        sampAddChatMessage("[ESP] " .. (enabled and "Enabled ✓" or "Disabled ✗"), 0x2196F3)
    end)
    
    -- Toggle ESP lines
    sampRegisterChatCommand("esplines", function()
        local enabled = not ESPSystem.config.drawLines
        ESPSystem:setLineDrawing(enabled)
        sampAddChatMessage("[ESP] Lines " .. (enabled and "enabled ✓" or "disabled ✗"), 0x2196F3)
    end)
    
    -- Show ESP statistics
    sampRegisterChatCommand("espstats", function()
        ESPSystem:printStats()
    end)
    
    -- Show UI information
    sampRegisterChatCommand("uiinfo", function()
        local state = UIFramework:getState()
        sampAddChatMessage("[UI] Menu position: " .. state.menuX .. ", " .. state.menuY, 0x2196F3)
        sampAddChatMessage("[UI] Scale: " .. string.format("%.2f", state.scale), 0x2196F3)
        sampAddChatMessage("[UI] Visible: " .. (state.menuVisible and "YES" or "NO"), 0x2196F3)
    end)
    
    -- Clear ESP cache
    sampRegisterChatCommand("espclear", function()
        ESPSystem:clearCache()
        sampAddChatMessage("[ESP] Cache cleared!", 0x2196F3)
    end)
end

--[[
    Get player coordinates
]]
function getPlayerCoordinates()
    local ok, ped = sampGetCharHandleBySampPlayerId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    if ok then
        local x, y, z = getCharCoordinates(ped)
        return x, y, z
    end
    return gameState.lastPlayerX, gameState.lastPlayerY, gameState.lastPlayerZ
end

--[[
    Build menu buttons
]]
function buildMenuButtons()
    return {
        {
            id = "btn_esp_toggle",
            label = "🎯 ESP " .. (ESPSystem.config.enabled and "ON" or "OFF")
        },
        {
            id = "btn_esp_lines",
            label = "📍 Lines " .. (ESPSystem.config.drawLines and "ON" or "OFF")
        },
        {
            id = "btn_esp_clear",
            label = "🔄 Clear Cache"
        }
    }
end

--[[
    Build menu sliders
]]
function buildMenuSliders()
    return {
        {
            id = "slider_distance",
            label = "Distance (m):",
            min = 50,
            max = 500,
            value = ESPSystem.config.maxDistance
        },
        {
            id = "slider_opacity",
            label = "Opacity:",
            min = 0,
            max = 100,
            value = 100
        }
    }
end

--[[
    Handle button actions
]]
function handleButtonAction(buttonId)
    if buttonId == "btn_esp_toggle" then
        local enabled = not ESPSystem.config.enabled
        ESPSystem:setEnabled(enabled)
        sampAddChatMessage("[ESP] " .. (enabled and "Enabled ✓" or "Disabled ✗"), 0x2196F3)
        
    elseif buttonId == "btn_esp_lines" then
        local enabled = not ESPSystem.config.drawLines
        ESPSystem:setLineDrawing(enabled)
        sampAddChatMessage("[ESP] Lines " .. (enabled and "enabled ✓" or "disabled ✗"), 0x2196F3)
        
    elseif buttonId == "btn_esp_clear" then
        ESPSystem:clearCache()
        sampAddChatMessage("[ESP] Cache cleared!", 0x2196F3)
    end
end

--[[
    Handle slider value changes
]]
function handleSliderChange(sliderId, value)
    if sliderId == "slider_distance" then
        ESPSystem.config.maxDistance = value
        sampAddChatMessage("[Config] Max distance set to " .. string.format("%.0f", value) .. "m", 0x2196F3)
        
    elseif sliderId == "slider_opacity" then
        -- Future implementation for opacity control
        sampAddChatMessage("[Config] Opacity set to " .. string.format("%.0f", value) .. "%", 0x2196F3)
    end
end

--[[
    Register test objects for ESP (example)
]]
function registerTestObjects()
    -- Example: Register some test objects
    -- Uncomment and modify based on actual game objects
    
    -- ESPSystem:registerObject(1, "target", 1234, 100, 100, 10, "Target Object")
    -- ESPSystem:registerObject(2, "item", 5678, 150, 150, 10, "Item")
end

--[[
    Main game loop
]]
function mainLoop()
    while not gameState.initialized do
        wait(100)
    end
    
    -- Register test objects
    registerTestObjects()
    
    while true do
        wait(0)
        
        -- Get input
        local mouseX, mouseY = getCursorPos()
        local mouseButton = nil
        
        -- Detect mouse button press
        if isKeyJustPressed(0x01) then  -- Left mouse button
            mouseButton = 0x01
        end
        
        -- Get player position
        local playerX, playerY, playerZ = getPlayerCoordinates()
        gameState.lastPlayerX = playerX
        gameState.lastPlayerY = playerY
        gameState.lastPlayerZ = playerZ
        
        -- Build menu components
        local buttons = buildMenuButtons()
        local sliders = buildMenuSliders()
        
        -- Handle button clicks in menu
        if UIFramework.state.menuVisible then
            for _, button in ipairs(buttons) do
                if button.id == "btn_esp_toggle" and mouseButton == 0x01 then
                    local inArea = UIFramework:isPosInArea(
                        mouseX, mouseY,
                        UIFramework.state.menuX + UIFramework.config.padding,
                        UIFramework.state.menuY + UIFramework.config.header_height + UIFramework.config.padding,
                        UIFramework.config.menu_width - UIFramework.config.padding * 2,
                        UIFramework.config.button_height
                    )
                    if inArea then
                        handleButtonAction(button.id)
                    end
                end
            end
        end
        
        -- Render UI menu
        UIFramework:renderMenu(mouseX, mouseY, mouseButton, buttons, sliders)
        
        -- Update slider values
        for _, slider in ipairs(sliders) do
            local newValue = UIFramework:getSliderValue(slider.id)
            if newValue ~= slider.value then
                handleSliderChange(slider.id, newValue)
            end
        end
        
        -- Render ESP system
        ESPSystem:render(playerX, playerY, playerZ)
    end
end

--[[
    Main entry point
]]
function main()
    initializeSystem()
    mainLoop()
end

-- Start the script
main()
