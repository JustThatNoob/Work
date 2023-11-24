function game()
    score = 0

    
    function love.load()   
        wf = require 'Libraries/windfield'
        world = wf.newWorld(0, 0)
        
        camera = require 'Libraries/camera'
        cam = camera(nil, nil, 3)
    
    
        anim8 = require 'Libraries/anim8'
        love.graphics.setDefaultFilter("nearest", "nearest")
    
        sti = require 'Libraries/sti'
        gameMap = sti('Maps/map1.lua')
        
        speed = 75
    
        player = {x = 395, y = 390, width = 50, height = 35}
        player.collider = world:newBSGRectangleCollider(player.x, player.y, 12, 20, 5)
        player.collider:setFixedRotation(true)
        player.sprite = love.graphics.newImage('sprites/Sprout Lands - Sprites - Basic pack/Characters/Basic Charakter Spritesheet.png')
        player.Spritesheet = love.graphics.newImage('sprites/Sprout Lands - Sprites - Basic pack/Characters/Basic Charakter Spritesheet.png')
        player.grid = anim8.newGrid(48, 48, player.Spritesheet:getWidth(), player.Spritesheet:getHeight())
        player.dir = "up"
    
        player.animations = {}
        player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2)
        player.animations.up = anim8.newAnimation( player.grid('1-4', 2), 0.2)
        player.animations.left = anim8.newAnimation( player.grid('1-4', 3), 0.2)
        player.animations.right = anim8.newAnimation( player.grid('1-4', 4), 0.2)
    
        player.anim = player.animations.left
    
        
        world:addCollisionClass("fruits")
    
    
    
        walls = {}
    
        if gameMap.layers["walls"] then
            for i, obj in pairs(gameMap.layers["walls"].objects) do
                local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height + 5)
                wall:setType('static')
                table.insert(walls, wall)
            end
        end
    
        fruits_ = {}
    
        if gameMap.layers["fruits_obj"] then
            for j, obj in pairs(gameMap.layers["fruits_obj"].objects) do
                local fruit = world:newRectangleCollider(obj.x, obj.y, 13, 13)
                fruit:setType('static')
                fruit:setCollisionClass("fruits")
                table.insert(fruits_, fruit)
            end
        end
    
        world:setQueryDebugDrawing(true)
        
    end
    
    
    function love.update(dt)
        
        
        f_visible = true
        
        
        local isMoving = false
    
        local vx = 0
        local vy = 0
    
        if love.keyboard.isDown("w") then
            vy =  speed *  -1
            player.anim = player.animations.up
            player.dir = "up"
            isMoving = true
        end
        if love.keyboard.isDown("s") then
            vy = speed 
            player.anim = player.animations.down
            player.dir = "down"
            isMoving = true
        end
        if love.keyboard.isDown("a") then
            vx = speed  *-1
            player.anim = player.animations.left
            player.dir = "left"
            isMoving = true
        end
        if love.keyboard.isDown("d") then
            vx = speed 
            player.anim = player.animations.right
            player.dir = "right"
            isMoving = true
        end
    
        player.collider:setLinearVelocity(vx, vy)
    
        if isMoving == false then
            player.anim:gotoFrame(2)
        end
    
    
        player.anim:update(dt)
    
        world:update(dt)
        player.x = player.collider:getX()
        player.y = player.collider:getY()
    
        cam:lookAt(player.x, player.y)
        
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
    
        if cam.x < w/6 then
            cam.x = w/6
        end
        if cam.y < h/6 then
            cam.y = h/6
        end
    
        local mapW = gameMap.width * gameMap.tilewidth
        local mapH = gameMap.height * gameMap.tileheight
    
        if cam.x > (mapW - w/6) then
            cam.x = (mapW - w/6)
        end
        if cam.y > (mapH - h/6) then
            cam.y = (mapH - h/6)
        end
    
    
    end
    
    
    function love.keypressed(key, scancode, isrepeat)
        if key == "escape" then
            love.event.quit()
        end
        
        if key == "space" then
            local px, py = player.collider:getPosition()
            if player.dir == "up" then
                py = py - 15
            elseif player.dir == "down" then
                py = py + 15
            elseif player.dir == "left" then
                px = px - 10
            elseif player.dir == "right" then
                px = px + 10
            end
    
            local collider = world:queryCircleArea(px, py, 8, {"fruits"})
            if #collider > 0 then
                for i, obj in pairs(collider) do 
                    for j, fruit in pairs(fruits_) do
                        if obj == fruit then
                            fruits_[j]:destroy()
                            score = score + 1
                        end
                    end
                end
            end
        
        end
    end
    
    
    function love.draw()
        cam:attach()
            gameMap:drawLayer(gameMap.layers["grass"])
            gameMap:drawLayer(gameMap.layers["paths"])
            gameMap:drawLayer(gameMap.layers["fences + hills"])
            gameMap:drawLayer(gameMap.layers["deco"])
            gameMap:drawLayer(gameMap.layers["fruits"])
    
    
            player.anim:draw(player.Spritesheet, player.x, player.y, nil, 1, nil, 24, 24)
    
        cam:detach()
    
        
        love.graphics.print(score)
    end   
end

function menu()

    local BUTTON_HEIGHT = 64
    
    local
    function newButton(text, fn)
        return {text = text, fn = fn, now = false, last = false}
    end
    
    local buttons = {}
    
    local font = nil
    
    
    function love.load()
    
        font = love.graphics.newFont(32)
    
        table.insert(buttons, newButton("Start Game", function () game() end))
        table.insert(buttons, newButton("Quit", function () love.event.quit() end ))
    end
    
    function love.draw()
        local ww = love.graphics.getWidth()
        local wh = love.graphics.getHeight()
    
        local button_width = ww * (1/3)
        local margin = 32
    
        local total_height = (BUTTON_HEIGHT + margin) * #buttons
        local cursor_y = 0
                
    
    
        for i, button in ipairs(buttons) do
                    
            button.last = button.now
    
            local bx = (ww * 0.5) - (button_width * 0.5)
            local by = (wh * 0.5) - (total_height * 0.5) + cursor_y
            local color = {0.4, 0.5, 0.4, 1}
    
            local mx, my = love.mouse.getPosition()
    
            local hot = mx > bx and mx < bx + button_width and my > by and my < by + BUTTON_HEIGHT
    
            if hot then
                color = {0.8, 0.9, 0.8, 1}
            end
    
            button.now = love.mouse.isDown(1)
    
            if button.now and not button.last and hot then
                button.fn()
            end
    
    
            love.graphics.setColor(unpack(color))
            love.graphics.rectangle("fill", bx, by, button_width, BUTTON_HEIGHT ) 
            cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
    
            love.graphics.setColor(0, 0, 0, 1)
    
                    
    
            local textW = font:getWidth(button.text)
            local textH = font:getHeight(button.text)
    
            love.graphics.print(button.text, font, (ww * 0.5) - (textW * 0.5), by + textH * 0.5)
        end
    end
end


current_state = "menu"


if current_state == "game" then
    game()
elseif current_state == "menu" then
    menu()
end
