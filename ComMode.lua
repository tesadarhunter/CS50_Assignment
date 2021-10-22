--[[
    GD50 2018
    Pong Remake

    -- ComMode Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents a paddle that can move up and down. Used in the main
    program to deflect the ball back toward the opponent.
    
    change log 2021 - 10 - 18
    change by Yuncheol.Y for project assignment
    This is a AI mode paddle class which is named comMode.
    ComMode class have new function for receive velocity calculator and their movement

    
]]

ComMode = Class{}

--[[
    The `init` function on our class is called just once, when the object
    is first created. Used to set up all variables in the class and get it
    ready for use.

    Our Paddle should take an X and a Y, for positioning, as well as a width
    and height for its dimensions.

    Note that `self` is a reference to *this* object, whichever object is
    instantiated at the time this function is called. Different objects can
    have their own x, y, width, and height values, thus serving as containers
    for data. In this sense, they're very similar to structs in C.
]]
function ComMode:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end




--[[velocitycalc calculate 2021 - 10 - 19 by Yuncheol.Y
1.total travel time of ball using ball 's x velocity
2.next approaching y position (height) of Com(AI) (goal height)
3.needed velocity for succesfully refract the ball (assume speed can be changed)
4. this is not global condition, make sure desireTime calculated from collision
]]

--[[ now maintenence
function ComMode:velocitycalc(ball, sHeight, sWidth, desireHeight, desireVelocity, desireTime)
    -- height , width mean virtual height and virtual width each
    --desire time camculation (travel time of ball)
   

    if ball.dx > 0 then
        desireTime = math.abs((sWidth - ball.x) / ball.dx)
    elseif ball.dx < 0 then
        desireTime = math.abs(ball.x / ball.dx)
    elseif ball.dx == 0 then
        desireTime = 50
    end
    
   --desireHeight (height approaching ball)
    desireHeight = ball.dy * desireTime + ball.y -- not complete, should consider refraction of top and bottom 
    desireVelocity = (desireHeight - self.y) / desireTime

   if desireHeight < 0 then
        desireHeight = math.abs(ball.dy * desireTime + ball.y)
        desireVelocity = math.abs(ball.dy + ball.y / desireTime) - self.y * desireTime
   end 

   if desireHeight > sHeight then
        desireHeight = sHeight-(ball.dy * desireTime + ball.y - sHeight)
        desireVelocity = 2 * sHeight * desireTime - ball.dy - ball.y * desireTime - self.y * desireTime
   end

   return desireTime, desireHeight, desireVelocity
end
]]


function ComMode:update(dt)

    
    -- math.max here ensures that we're the greater of 0 or the player's
    -- current calculated Y position when pressing up so that we don't
    -- go into the negatives; the movement calculation is simply our
    -- previously-defined paddle speed scaled by dt
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    -- similar to before, this time we use math.min to ensure we don't
    -- go any farther than the bottom of the screen minus the paddle's
    -- height (or else it will go partially below, since position is
    -- based on its top left corner)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end



end


--[[sameheightmoving fucntion 
AI move up and down toward same height of ball.
for level 1~2 (constant speed of paddle)
This function determine sign of moving paddle. 
0 :  same height
1 :  downside moving
-1:  upside moving
]]
function ComMode:sameheightmovingsign(ball)

    if self.y > ball.y then
        return -1
    end

    if self.y < ball.y then
        return 1
    end

    if self.y == ball.y then
        return 0 
    end 
end


--[[
    To be called by our main function in `love.draw`, ideally. Uses
    LÖVE2D's `rectangle` function, which takes in a draw mode as the first
    argument as well as the position and dimensions for the rectangle. To
    change the color, one must call `love.graphics.setColor`. As of the
    newest version of LÖVE2D, you can even draw rounded rectangles!
]]
function ComMode:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end