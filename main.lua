--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.

    Assignment : make player vs com (AI) pong game. by Yuncheol.Y
    1. make Player class and ComMode class for paddle control
        the 3 modes can be selected at first menu
        (player(1p) vs player(2p), player vs com and com vs com)
    1-1 make new game state = menu (select)

    2. AI levels build
        each level has own features discribed below
        level 1 : constant speed, sometime excute odd act(get paddle velocity-> -y velocity during 1/6 sec )
        level 2 : constant speed, sometime excute odd act less than level 1 with entropy system(about 1/20 sec)
        level max : no limitation of speed (velcity is calculated from equation with approaching time (back to back time))
    2-1 AI paddle velocity calculator for level max
        velocity of paddle is constant on level 1 and 2 
        so update function check only ball height and determine moving toward y position of ball
        level max using velocity calculated from approaching time to x = 0 from other side (refraction moment)  
    3. limited frame (TDB)
        for AI (ComMode) speed is easily setting on limited frame (60) 
        so we can give same UX for other computer systems.
    4. entropy system
        this concept is from path of exile evasion system. 
        https://pathofexile.fandom.com/wiki/Evasion
        using this concept odd act is excuted less than given odd act system.
        total entropy = 200
        hit entropy = 50
        and initialization after 5s-> accur nothing -> new 

    day 0 re-update
    make Player class and ComMode class and revise main.lua 

    day 1 re-update
    revision and correction of main.lua file

    day 2 re-update
    make mode and level menu and written draft of comMode(AI) code 
    not sure this code working properly
    please check !
	
	day 3 re-update
	make more detiled AI desctiption of comMode(AI) code
	
	day 4 re-update
	easy update for AI mode

    day 5 re-update
    keep going level 1 and 2 update of AI mode    
    check comple error and finish 

    current progress :
    main menu prints works fine but selection function is not working (solve)    
    AI movement is nothing (code correction is needed)
    
    
    player controler is not working (solve)
    update function or key checking is failed (solve)
    


]]

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

-- the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and
-- methods
--
-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

-- our Paddle class, which stores position and dimensions for each Paddle
-- and the logic for rendering them
--require 'Paddle'

-- make two types of paddle class. 1. player, 2. com 
require 'Player'

require 'ComMode'

-- our Ball class, which isn't much different than a Paddle structure-wise
-- but which will mechanically function very differently
require 'Ball'

-- size of our actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

--[[
    Called just once at the beginning of the game; used to set up
    game objects, variables, etc. and prepare the game world.
]]
function love.load()
    -- set love's default filter to "nearest-neighbor", which essentially
    -- means there will be no filtering of pixels (blurriness), which is
    -- important for a nice crisp, 2D look
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- set the title of our application window
    love.window.setTitle('Pong')

    -- seed the RNG so that calls to random are always random
    math.randomseed(os.time())

    -- initialize our nice-looking retro text fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    -- set up our sound effects; later, we can just index this table and
    -- call each entry's `play` method
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    -- initialize our player paddles; make them global so that they can be
    -- detected by other functions and modules
	
	-- loading all classes of paddle control
	
	player1 = Player(10, 30, 5, 20)
	player2 = Player(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
	computer1 = ComMode(10, 30, 5, 20)
	computer2 = ComMode(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	
		
	--After modeselect scene, we will use this code lines
	
	--Player vs Player mode
	--if playModes == playModes[1] then
	--	player1 = Paddle(10, 30, 5, 20)
	--	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	--end
	--Player vs Com
	--if playModes == playModes[2] then
	--	player1 = Player(10, 30, 5, 20)
	--	player2 = ComMode(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	--end
	
	--Com vs Player
	--if playModes == playModes[3] then
	--	player1 = ComMode(10, 30, 5, 20)
	--	player2 = ComMode(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
	--end
	
	

    -- place a ball in the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- initialize score variables
    player1Score = 0
    player2Score = 0
	computer1Score = 0
	computer2Score = 0

    -- either going to be 1 or 2; whomever is scored on gets to serve the
    -- following turn
	-- this number is related to only right or left paddle position
	-- so it's don't need to make other argument for computer 1 and 2
    servingPlayer = 1

    -- player who won the game; not set to a proper value until we reach
    -- that state in the game
    winningPlayer = 0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
    -- 5. 'menu' (select pvp or player vs com mode at the beginning) -- add for assignment
    -- 6. 'levelSelect' (select level of AI) -- add for assignment
    gameState = 'start'
	
	-- the state of play mode;
    -- 1. 'player vs player'
    -- 2. 'player vs com'
    -- 3. 'com vs com'
    

    --carefull! lua table start numbering 1
    playModes = {'Player vs Player', 'Player vs Com', 'Com vs Com'}
    currentModeNum = 1
    currentMode = playModes[currentModeNum]
    

    -- the levels of computer AI
    -- 1. '1'
    -- 2. '2'
    -- 3. 'hell'

    aiLevels = {'1', '2' , 'Hell'}
    currentLevelNum = 1
    currentLevel = aiLevels[currentLevelNum]
	
	-- Initialize Avtive paddle state for update function, 
	player1Active = false
	player2Active = false
	computer1Active = false
	computer2Active = false
	
   --  some variables related AI paddle movement
   desireHeight = 1
   desireVelocity = 0
   desireTime = 0
   --balliniHeight = VIRTUAL_HEIGHT / 2 - 2 -- always ball start at center

end

--[[
    Called whenever we change the dimensions of our window, as by dragging
    out its bottom corner, for example. In this case, we only need to worry
    about calling out to `push` to handle the resizing. Takes in a `w` and
    `h` variable representing width and height, respectively.
]]
function love.resize(w, h)
    push:resize(w, h)
end

--[[
    Called every frame, passing in `dt` since the last frame. `dt`
    is short for `deltaTime` and is measured in seconds. Multiplying
    this by any changes we wish to make in our game will allow our
    game to perform consistently across all hardware; otherwise, any
    changes we make will be applied as fast as possible and will vary
    across system hardware.
]]

function love.update(dt)
 --[[ 
	update 2021 - 10 - 20, 
	in play state , we check level (TBD) and mode state.
	1. check mode (PVP or Player vs Com)
	2. player 2 determined at initial love.load();
    problem 
    update function totally ruined make sure all parameters
    ]]

    if gameState == 'serve' then
        -- before switching to play, initialize ball's velocity based
        -- on player who last scored
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
        
       
        -- controler activation after modeselect (i.e. servemode)
        
        if currentMode == 'Player vs Player' then
            player1Active = true
            player2Active = true
        elseif currentMode == 'Player vs Com' then
            player1Active = true
            computer2Active = true
        elseif currentMode == 'Com vs Com' then
            computer1Active = true
            computer2Active = true
        end
    end

    if gameState == 'play' then
        -- detect ball collision with paddles, reversing dx if true and
        -- slightly increasing it, then altering the dy based on the position
        -- at which it collided, then playing a sound effect
		
		-- ball acting for player paddles
		if player1Active == true then
		    if ball:collides(player1) then
				ball.dx = -ball.dx * 1.03
				ball.x = player1.x + 5

                -- keep velocity going in the same direction, but randomize it
				if ball.dy < 0 then
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

				sounds['paddle_hit']:play()
			end
		end
		
		if player2Active == true then
		    if ball:collides(player2) then
				ball.dx = -ball.dx * 1.03
				ball.x = player2.x - 4

                if ball.dy < 0 then
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

				sounds['paddle_hit']:play()
			end
		end
		
		
		-- ball refracting at computer paddles boundary
        
		if computer1Active == true then
			 if ball:collides(computer1) then
				ball.dx = -ball.dx * 1.03
				ball.x = computer1.x + 5

            
				if ball.dy < 0 then
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

				sounds['paddle_hit']:play()
			end
		end
		
		if computer2Active == true then
		    if ball:collides(computer2) then
				ball.dx = -ball.dx * 1.03
				ball.x = computer2.x - 4

				
				if ball.dy < 0 then
					ball.dy = -math.random(10, 150)
				else
					ball.dy = math.random(10, 150)
				end

				sounds['paddle_hit']:play()
			end
		end
		
		
        -- detect upper and lower screen boundary collision, playing a sound
        -- effect and reversing dy if true
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- -4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- if we reach the left or right edge of the screen, go back to serve
        -- and update the score and serving player
        if ball.x < 0 then
            servingPlayer = 1
			
			if player2Active == true then
				player2Score = player2Score + 1
			end
			if computer2Active == true then
			    computer2Score = computer2Score + 1
			end
            sounds['score']:play()

            -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
			
            if player2Score == 10 or computer2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                -- places the ball in the middle of the screen, no velocity
                ball:reset()
            end
        end
        
        
        --ball score condition
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
			if player1Active == true then			
				player1Score = player1Score + 1
			end
			
		    if computer1Active == true then
				computer1Score = computer1Score + 1
			end
			
            sounds['score']:play()

            if player1Score == 10 or computer1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

       

		
    end

    --
    -- paddles can move no matter what state we're in
    --
    -- player 1 
    
	if player1Active == true then
		if love.keyboard.isDown('w') then
			player1.dy = -PADDLE_SPEED
		elseif love.keyboard.isDown('s') then
			player1.dy = PADDLE_SPEED
		else
			player1.dy = 0
		end
	end

    -- player 2
	
	if player2Active == true then
	    if love.keyboard.isDown('up') then
			player2.dy = -PADDLE_SPEED
		elseif love.keyboard.isDown('down') then
			player2.dy = PADDLE_SPEED
		else
			player2.dy = 0
		end
	end

    --
    -- now add main AI movements (comMode)
    --
    
    -- AI level : Hell 
    -- we'll use comMove:velocitycalc which determine for speed of comMode paddle.
    -- velocitycalc calculate paddle desireheight , desireTime and desireVelocity 
   
    -- update our ball based on its DX and DY only if we're in play state;
    -- scale the velocity by dt so movement is framerate-independent
    if gameState == 'play' then       
        ball:update(dt)
    end

    -- usage ComMode:velocitycalc(ball, height, width, desireHeight, desireVelocity, desireTime)
    -- 
    if gameState == 'play' then         
         if computer1Active == true then
            --computer1:velocitycalc(ball, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, desireHeight, desireVelocity, desireTime)
            --calculate manually in main function (SADGE)
            
            if ball.dx > 0 then
                desireTime = math.abs((VIRTUAL_WIDTH - ball.x) / ball.dx)
            elseif ball.dx < 0 then
                desireTime = math.abs(ball.x / ball.dx)
            elseif ball.dx == 0 then --strange condition for experiment
                desireTime = 50
            end
            
           --desireHeight (height approaching ball)
            desireHeight = ball.dy * desireTime + ball.y -- not complete, should consider refraction of top and bottom 
            desireVelocity = (desireHeight - computer1.y) / desireTime
        
           if desireHeight < 0 then
                desireHeight = math.abs(ball.dy * desireTime + ball.y)
                desireVelocity = math.abs(ball.dy + ball.y / desireTime) - computer1.y * desireTime
           end 
        
           if desireHeight > VIRTUAL_HEIGHT then
                desireHeight = VIRTUAL_HEIGHT-(ball.dy * desireTime + ball.y - VIRTUAL_HEIGHT)
                desireVelocity = 2 * VIRTUAL_HEIGHT * desireTime - ball.dy - ball.y * desireTime - computer1.y * desireTime
           end
            computer1.dy = desireVelocity
        end

        if computer2Active == true then
            --computer2:velocitycalc(ball, VIRTUAL_HEIGHT, VIRTUAL_WIDTH, desireHeight, desireVelocity, desireTime)
            --calculate manually in main function (SADGE)
                
                if ball.dx > 0 then
                    desireTime = math.abs((VIRTUAL_WIDTH - ball.x) / ball.dx)
                elseif ball.dx < 0 then
                    desireTime = math.abs(ball.x / ball.dx)
                elseif ball.dx == 0 then  --strange condition for experiment
                    desireTime = 50
                end
                
               --desireHeight (height approaching ball)
                desireHeight = ball.dy * desireTime + ball.y -- not complete, should consider refraction of top and bottom 
                desireVelocity = (desireHeight - computer2.y) / desireTime
            
               if desireHeight < 0 then
                    desireHeight = math.abs(ball.dy * desireTime + ball.y)
                    desireVelocity = math.abs(ball.dy + ball.y / desireTime) - computer2.y * desireTime
               end 
            
               if desireHeight > VIRTUAL_HEIGHT then
                    desireHeight = VIRTUAL_HEIGHT-(ball.dy * desireTime + ball.y - VIRTUAL_HEIGHT)
                    desireVelocity = 2 * VIRTUAL_HEIGHT * desireTime - ball.dy - ball.y * desireTime - computer2.y * desireTime
               end
            computer2.dy = desireVelocity
        end

    end 

	-- contained moving limitation (wall boundary condition)
	if player1Active == true then
		player1:update(dt)
	end
	 
	if player2Active == true then
		player2:update(dt)
	end
	
	if computer1Active == true then
		computer1:update(dt)
	end
	
	if computer2Active == true then
	    computer2:update(dt)
	end
	
	-- end of player vs player mode
	
	
	-- start player vs com mode
	-- making AI movement for level 1 or level2 should check require comMode and Player Class
	-- instead of Paddle class.
    
    -- update mode selection
	currentMode = playModes[currentModeNum]
    currentLevel = aiLevels[currentLevelNum]

    
end
	
--[[
    A callback that processes key strokes as they happen, just the once.
    Does not account for keys that are held down, which is handled by a
    separate function (`love.keyboard.isDown`). Useful for when we want
    things to happen right away, just once, like when we want to quit.
]]
function love.keypressed(key)
    -- `key` will be whatever key this callback detected as pressed
    if key == 'escape' then
        -- the function LÖVE2D uses to quit the application
        love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'menu'            
            --gameState = 'serve'
        elseif gameState == 'menu' then
            --gameState = 'play' 
            if currentMode ==  'Player vs Com' or currentMode == 'Com vs Com' then
                gameState = 'levelSelect'              
            else
                gameState = 'serve'
            end
        elseif gameState == 'levelSelect' then
              gameState = 'serve'
        elseif gameState == 'serve' then
              gameState = 'play'    
        elseif gameState == 'done' then
            -- game is simply in a restart phase here, but will set the serving
            -- player to the opponent of whomever won for fairness!
            -- change log (restart phase will set the menu)
            gameState = 'serve'

            ball:reset()

            -- reset scores to 0
            player1Score = 0
            player2Score = 0
			
			computer1Score = 0
			computer2Score = 0
            
            -- decide serving player as the opposite of who won
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
    if key == 'up' then 
        if gameState == 'menu' then
            currentModeNum = currentModeNum -1
            if currentModeNum < 1 then
                currentModeNum = 1
            end
        end

        if gameState == 'levelSelect' then
            currentLevelNum = currentLevelNum -1
            if currentLevelNum < 1 then
                currentLevelNum = 1
            end
        end
    end
    --[[new function for menu,level selection. release some key]]
    if key == 'down' then
        if gameState == 'menu' then            
            currentModeNum = currentModeNum +1
            if currentModeNum > 3 then
                currentModeNum = #playModes
            end
        end

        if gameState == 'levelSelect' then
            currentLevelNum = currentLevelNum + 1
            if currentLevelNum > 3 then
                currentLevelNum = #aiLevels
            end
        end
    end
   
end


--[[
    Called each frame after update; is responsible simply for
    drawing all of our game objects and more to the screen.
]]
function love.draw()
    -- begin drawing with push, in our virtual resolution
    push:start()

       
    --before love2d ver 11
    --love.graphics.clear(40, 45, 52, 255)
    
    --after love2d ver 11
    love.graphics.clear(0.15, 0.17, 0.2, 1) 

    
    -- render different things depending on which part of the game we're in
    if gameState == 'start' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        -- UI messages
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'menu' then       
        displayMenu()
    end
    
    if gameState == 'levelSelect' then       
        displayLevel()
    end

    -- show the score before ball is rendered so it can move over the text
    displayScore()
    
    if player1Active == true then
        player1:render()
    end
    if player2Active == true then
        player2:render()
    end

    if computer1Active == true then
        computer1:render()
    end
    if computer2Active == true then
        computer2:render()
    end

    ball:render()

    -- display FPS for debugging; simply comment out to remove
    displayFPS()


    --check current mode
    --love.graphics.printf(gameState .. currentMode ..  currentLevel, 0, 20, VIRTUAL_WIDTH/2, 'center')

    -- check variables of computer paddle
    --[[
    love.graphics.printf('desireVelocity : ' .. tostring(desireVelocity), 0, 20, VIRTUAL_WIDTH/2, 'center')
    love.graphics.printf('desireTime : ' .. tostring(desireTime), 0, 35, VIRTUAL_WIDTH/2, 'center')
    love.graphics.printf('desireHeight : ' .. tostring(desireHeight), 0, 50, VIRTUAL_WIDTH/2, 'center')
    ]]

    -- end our drawing to push
    push:finish()
end

--[[
    Simple function for rendering the scores.
]]
function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayMenu()
    -- display menu 
    love.graphics.setFont(smallFont)
    -- position is determined some arbitery value
    love.graphics.print('select play mode menu with up and down keys and press enter after your choice', VIRTUAL_WIDTH/2 -180 , 30) 
    for i = 1, #playModes do
        love.graphics.print(playModes[i], VIRTUAL_WIDTH/2 - 30, 30 + 10 * i )
    end
    love.graphics.print('select menu is :  ' .. currentMode, VIRTUAL_WIDTH/2 - 75 , 150) 

end

function displayLevel()
    -- display level 
    love.graphics.setFont(smallFont)
    love.graphics.print('select Level with up and down keys', VIRTUAL_WIDTH/2 -75 , 30) 
    for i = 1, #aiLevels do
        love.graphics.print(aiLevels[i], VIRTUAL_WIDTH/2 - 30, 30 + 10 * i)
    end
    love.graphics.print('select level is :  ' .. currentLevel, VIRTUAL_WIDTH/2 - 75, 150) 

end