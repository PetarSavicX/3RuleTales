function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setMode(800, 600, {
        fullscreen = false,
        borderless = false,
        resizable = true
    })
    love.window.maximize()

    DEBUGMODE = false


    -- Enemy = require 'src.enemy'
    anim8 = require 'libs.anim8'
    sti = require 'libs/sti'
    cameraLib = require 'libs.camera'
    camera = cameraLib()
    wf = require 'libs/windfield'

    world = wf.newWorld(0, 0)
    -- world:setDrawColor(1, 0, 0)

    gameMap = sti('/assets/maps/TestMap.lua')


    player = {}
    player.x = (gameMap.tilewidth * 15)
    player.y = (gameMap.tileheight * 1)
    player.speed = 250
    player.collider = world:newBSGRectangleCollider(player.x, player.y, 50, 80, 10)
    player.collider:setFixedRotation(true)
    player.spriteSheet = love.graphics.newImage('/assets/sprites/player/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('1-4', 1), 0.2 )
    player.animations.left = anim8.newAnimation( player.grid('1-4', 2), 0.2 )
    player.animations.right = anim8.newAnimation( player.grid('1-4', 3), 0.2 )
    player.animations.up = anim8.newAnimation( player.grid('1-4', 4), 0.2 )

    player.currentAnim = player.animations.down

    walls = {}

    if gameMap.layers['walls-obj'] then
        for i, obj in pairs(gameMap.layers['walls-obj'].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            -- wall:setObjectDrawColor(1, 0, 0)
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    world:update(dt)
    playerMovement(dt)
    cameraSettings()
end

function love.draw()
    camera:attach()
        gameMap:drawLayer(gameMap.layers["ground"])
        gameMap:drawLayer(gameMap.layers["walls"])
        gameMap:drawLayer(gameMap.layers["trees"])
        player.currentAnim:draw(player.spriteSheet, player.x, player.y, nil, 5, nil, 6, 9)
        if DEBUGMODE == true then
            world:draw()
        end
    camera:detach()
end





-- LOCAL FUCTIONS

function love.keypressed(key)
    if key == '.' then
        DEBUGMODE = not DEBUGMODE
    end
end

function cameraSettings()
    camera:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if camera.x < w/2 then
        camera.x = w/2
    end

    if camera.y < h/2 then
        camera.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if camera.x > (mapW - w/2) then
        camera.x = (mapW - w/2)
    end

    if camera.y > (mapH - h/2) then
        camera.y = (mapH - h/2)
    end
end

function playerMovement(dt)
    local playerMoving = false
    local vx = 0;
    local vy = 0

    if love.keyboard.isDown("d") then
        vx = player.speed
        player.currentAnim = player.animations.right
        playerMoving = true
    end

    if love.keyboard.isDown("a") then
        vx = player.speed * -1
        player.currentAnim = player.animations.left
        playerMoving = true
    end

    if love.keyboard.isDown("s") then
        vy = player.speed
        player.currentAnim = player.animations.down
        playerMoving = true
    end

    if love.keyboard.isDown("w") then
        vy =  player.speed * -1
        player.currentAnim = player.animations.up
        playerMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if playerMoving == false then
        player.currentAnim:gotoFrame(2)
    end

    player.currentAnim:update(dt)

    player.x = player.collider:getX()
    player.y = player.collider:getY()
end