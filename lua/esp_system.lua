--[[
    ArizonaX ESP System v2.0.0
    Advanced object visualization and detection system
    
    Features:
    - 3D to 2D coordinate transformation
    - World scanning and object registration
    - Distance-based filtering
    - Performance optimized with caching
    - Support for players, NPCs, vehicles, items
]]

local ESPSystem = {
    state = {
        enabled = true,
        drawLines = true,
        objects = {},
        lastUpdateTime = 0,
        updateInterval = 100
    },
    
    config = {
        maxDistance = 500,
        markerSize = 8,
        lineWidth = 2,
        updateInterval = 100,
        maxObjects = 200,
        cacheEnabled = true
    },
    
    colors = {
        player = 0xFF4CAF50,        -- Green
        npc = 0xFF2196F3,           -- Blue
        object = 0xFFFF9800,        -- Orange
        vehicle = 0xFF9C27B0,       -- Purple
        target = 0xFFF44336,        -- Red
        item = 0xFFFFEB3B,          -- Yellow
        line = 0xFF2196F3,          -- Blue
        text = 0xFFFFFFFF           -- White
    },
    
    fonts = {
        main = nil,
        small = nil
    }
}

--[[
    Initialize ESP system with fonts
]]
function ESPSystem:initialize(fontMain, fontSmall)
    self.fonts.main = fontMain
    self.fonts.small = fontSmall
    self.state.lastUpdateTime = os.clock() * 1000
end

--[[
    Set ESP enabled state
]]
function ESPSystem:setEnabled(enabled)
    self.config.enabled = enabled
end

--[[
    Set line drawing enabled state
]]
function ESPSystem:setLineDrawing(enabled)
    self.config.drawLines = enabled
end

--[[
    Get configuration
]]
function ESPSystem:getConfig()
    return {
        enabled = self.config.enabled,
        drawLines = self.config.drawLines,
        maxDistance = self.config.maxDistance
    }
end

--[[
    Register object for ESP tracking
]]
function ESPSystem:registerObject(id, objectType, modelId, x, y, z, label)
    if not id then return false end
    
    -- Limit number of objects
    if #self.state.objects >= self.config.maxObjects then
        return false
    end
    
    self.state.objects[id] = {
        id = id,
        type = objectType,
        modelId = modelId,
        x = x,
        y = y,
        z = z,
        label = label,
        distance = 0,
        screenX = nil,
        screenY = nil,
        visible = false,
        lastUpdated = os.clock() * 1000
    }
    
    return true
end

--[[
    Unregister object
]]
function ESPSystem:unregisterObject(id)
    if self.state.objects[id] then
        self.state.objects[id] = nil
        return true
    end
    return false
end

--[[
    Get color for object type
]]
function ESPSystem:getColorForType(objectType)
    local colors = self.colors
    
    if objectType == "player" then
        return colors.player
    elseif objectType == "npc" then
        return colors.npc
    elseif objectType == "vehicle" then
        return colors.vehicle
    elseif objectType == "target" then
        return colors.target
    elseif objectType == "item" then
        return colors.item
    else
        return colors.object
    end
end

--[[
    Calculate distance between two 3D points
]]
function ESPSystem:calculateDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

--[[
    Convert 3D world coordinates to 2D screen coordinates
    Returns: screenX, screenY (nil if off-screen)
]]
function ESPSystem:convert3DToScreen(worldX, worldY, worldZ)
    local ok, screenX, screenY = pcall(convert3DCoordsToScreen, worldX, worldY, worldZ)
    
    if ok and screenX and screenY then
        return screenX, screenY
    end
    
    return nil, nil
end

--[[
    Draw marker at screen position
]]
function ESPSystem:drawMarker(screenX, screenY, color, size)
    size = size or self.config.markerSize
    
    -- Draw center dot
    renderDrawBox(screenX - 1, screenY - 1, screenX + 1, screenY + 1, color)
    
    -- Draw cross
    renderDrawLine(screenX - size, screenY, screenX + size, screenY, color, 1)
    renderDrawLine(screenX, screenY - size, screenX, screenY + size, color, 1)
end

--[[
    Draw line between two screen positions
]]
function ESPSystem:drawLine(x1, y1, x2, y2, color, width)
    width = width or self.config.lineWidth
    renderDrawLine(x1, y1, x2, y2, color, width)
end

--[[
    Draw text at screen position with background
]]
function ESPSystem:drawText(text, screenX, screenY, color, font)
    font = font or self.fonts.small
    
    if font then
        -- Draw background
        renderDrawBox(screenX - 5, screenY - 15, screenX + 60, screenY + 5, 0x80000000)
        -- Draw text
        renderFontDrawText(font, text, screenX, screenY - 12, color)
    end
end

--[[
    Update object positions and visibility
]]
function ESPSystem:updateObjects(playerX, playerY, playerZ)
    local currentTime = os.clock() * 1000
    local timeSinceUpdate = currentTime - self.state.lastUpdateTime
    
    -- Only update at specified interval
    if timeSinceUpdate < self.config.updateInterval then
        return
    end
    
    self.state.lastUpdateTime = currentTime
    
    for id, obj in pairs(self.state.objects) do
        if obj then
            -- Calculate distance
            obj.distance = self:calculateDistance(playerX, playerY, playerZ, obj.x, obj.y, obj.z)
            
            -- Check if within max distance
            if obj.distance <= self.config.maxDistance then
                -- Convert to screen coordinates
                obj.screenX, obj.screenY = self:convert3DToScreen(obj.x, obj.y, obj.z)
                obj.visible = (obj.screenX ~= nil and obj.screenY ~= nil)
            else
                obj.visible = false
            end
        end
    end
end

--[[
    Render all visible objects
]]
function ESPSystem:render(playerX, playerY, playerZ)
    if not self.config.enabled then
        return
    end
    
    playerX = playerX or 0
    playerY = playerY or 0
    playerZ = playerZ or 0
    
    -- Update object visibility and positions
    self:updateObjects(playerX, playerY, playerZ)
    
    -- Draw all visible objects
    for id, obj in pairs(self.state.objects) do
        if obj and obj.visible then
            local color = self:getColorForType(obj.type)
            
            -- Draw marker
            self:drawMarker(obj.screenX, obj.screenY, color, self.config.markerSize)
            
            -- Draw label with distance
            local labelText = obj.label .. " [" .. string.format("%.0f", obj.distance) .. "m]"
            self:drawText(labelText, obj.screenX + 15, obj.screenY, color, self.fonts.small)
            
            -- Draw line from player to object (optional)
            if self.config.drawLines and obj.distance < 200 then
                local playerScreenX, playerScreenY = self:convert3DToScreen(playerX, playerY, playerZ)
                if playerScreenX and playerScreenY then
                    self:drawLine(playerScreenX, playerScreenY, obj.screenX, obj.screenY, 
                                 self.colors.line, 1)
                end
            end
        end
    end
end

--[[
    Scan world for objects (abstract - implement based on game API)
]]
function ESPSystem:scanWorld()
    -- This is an abstract example
    -- Implementation depends on specific game API
    
    -- Example structure:
    -- for _, objectHandle in ipairs(getAllObjects()) do
    --     if getObjectModel(objectHandle) == TARGET_MODEL_ID then
    --         local x, y, z = getObjectCoordinates(objectHandle)
    --         self:registerObject(objectHandle, "object", TARGET_MODEL_ID, x, y, z, "Target")
    --     end
    -- end
end

--[[
    Clear all registered objects
]]
function ESPSystem:clearCache()
    self.state.objects = {}
end

--[[
    Get object count
]]
function ESPSystem:getObjectCount()
    local count = 0
    for _ in pairs(self.state.objects) do
        count = count + 1
    end
    return count
end

--[[
    Get visible object count
]]
function ESPSystem:getVisibleObjectCount()
    local count = 0
    for _, obj in pairs(self.state.objects) do
        if obj and obj.visible then
            count = count + 1
        end
    end
    return count
end

--[[
    Print ESP statistics
]]
function ESPSystem:printStats()
    local totalCount = self:getObjectCount()
    local visibleCount = self:getVisibleObjectCount()
    
    sampAddChatMessage("[ESP Stats] Total: " .. totalCount .. " | Visible: " .. visibleCount, 0x2196F3)
    sampAddChatMessage("[ESP Stats] Max Distance: " .. self.config.maxDistance .. "m", 0x2196F3)
    sampAddChatMessage("[ESP Stats] Enabled: " .. (self.config.enabled and "YES" or "NO"), 0x2196F3)
    sampAddChatMessage("[ESP Stats] Lines: " .. (self.config.drawLines and "YES" or "NO"), 0x2196F3)
end

--[[
    Get object by ID
]]
function ESPSystem:getObject(id)
    return self.state.objects[id]
end

--[[
    Get all objects
]]
function ESPSystem:getObjects()
    return self.state.objects
end

--[[
    Update object position
]]
function ESPSystem:updateObjectPosition(id, x, y, z)
    if self.state.objects[id] then
        self.state.objects[id].x = x
        self.state.objects[id].y = y
        self.state.objects[id].z = z
        return true
    end
    return false
end

return ESPSystem
