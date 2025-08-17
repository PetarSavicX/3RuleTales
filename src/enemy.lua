local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, type)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.speed = 3

    if type == 1 then
        self = createEnemy1(self)
    elseif type == 2 then
        self = createEnemy2(self)
    end

    return self
end

function createEnemy1(self)
    self.hp = 30
    self.r = 50
    return self
end

function createEnemy2(self)
    self.hp = 20
    self.r = 100
    return self
end

return Enemy
