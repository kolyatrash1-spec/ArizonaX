--[[
    ArizonaX Main Script v1.0
    Fully compatible with MonetLoader for Arizona Mode
    
    Commands:
    /mmenu - Toggle menu
    /esp - Toggle ESP
    /esplines - Toggle lines
    /espclear - Clear objects cache
]]

local menu = require("lib.menu")
local esp = require("lib.esp")

-- Глобальные переменные
local playerX, playerY, playerZ = 0, 0, 0
local isMenuOpen = true
local mouseX, mouseY = 0, 0
local mouseDown = false

--[[
    Получить позицию игрока
]]
local function getPlayerPos()
    local ok, x, y, z = pcall(getPlayerPos)
    if ok and x and y and z then
        return x, y, z
    end
    return playerX, playerY, playerZ
end

--[[
    Отправить команду в чат
]]
function sendCommand(cmd)
    -- Обертка для совместимости
    local ok, result = pcall(sendChatMessage, cmd)
    if ok then
        return result
    end
    return nil
end

--[[
    Регистрация команды
]]
local function registerCommand(name, handler)
    -- Для Arizona Mode с MonetLoader
    if addCommandHandler then
        addCommandHandler(name, handler)
    end
end

--[[
    Главная функция обработки событий
]]
function onFrame()
    -- Получаем позицию игрока
    playerX, playerY, playerZ = getPlayerPos()
    
    -- Получаем позицию мыши
    local ok, mx, my = pcall(getCursorPos)
    if ok and mx and my then
        mouseX = mx
        mouseY = my
    end
    
    -- Получаем состояние клика мыши
    local ok2, mousePressed = pcall(isKeyPressed, 0x01)  -- Left mouse button
    if ok2 then
        mouseDown = mousePressed
    end
    
    -- Отрисовка меню
    menu:draw(mouseX, mouseY, mouseDown)
    
    -- Отрисовка ESP
    esp:render(playerX, playerY, playerZ)
end

--[[
    Обработчик команды /mmenu
]]
registerCommand("mmenu", function(params)
    menu:toggle()
    local state = menu.visible and "Открыто" or "Закрыто"
    sendCommand("/say [ArizonaX] Меню " .. state)
end)

--[[
    Обработчик команды /esp
]]
registerCommand("esp", function(params)
    esp.enabled = not esp.enabled
    local state = esp.enabled and "Включена" or "Отключена"
    sendCommand("/say [ESP] " .. state)
end)

--[[
    Обработчик команды /esplines
]]
registerCommand("esplines", function(params)
    esp.drawLines = not esp.drawLines
    local state = esp.drawLines and "включены" or "отключены"
    sendCommand("/say [ESP] Линии " .. state)
end)

--[[
    Обработчик команды /espclear
]]
registerCommand("espclear", function(params)
    esp.objects = {}
    sendCommand("/say [ESP] Кэш очищен")
end)

--[[
    Инициализация скрипта
]]
function main()
    -- Ждем загрузки сервера
    wait(3000)
    
    sendCommand("/say [ArizonaX] Скрипт загружен! Используй /mmenu для меню")
    
    -- Основной цикл
    while true do
        pcall(onFrame)
        wait(0)
    end
end

-- Запуск скрипта
main()
