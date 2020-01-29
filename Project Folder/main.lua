-- variable that stores player data such as position and speed
player = { }

-- function is only called once at the beginning of the game
function love.load()
	-- Variable that stores the Box sprite in a Love Image
	box = love.graphics.newImage("Sprites/Box.png")
	
	player.img = box
	
	-- Variables that hold the width and height of the Box sprite in Sprites folder
	playerWidth = player.img:getWidth()
	playerHeight = player.img:getHeight()
	
	-- Place the character in the center of the screen
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	
	-- Give the player a movement speed of 200
	player.speed = 200
	
end


-- Update is run every frame
-- Currently checks for movemovent input and moves the character if necessary
function love.update(dt)

	-- If the player is pressing d or a then move them horizontally
	if love.keyboard.isDown('d') then
		-- confine the player to the screen boundary
		if player.x < (love.graphics.getWidth() - playerWidth) then
			-- move the player if enough time has passed since the last check (dt)
			player.x = player.x + (player.speed * dt)
		end
	elseif love.keyboard.isDown('a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	end
	
	if love.keyboard.isDown('w') then
		if player.y > 0 then
			player.y = player.y - (player.speed * dt)
		end
	elseif love.keyboard.isDown('s') then
		if player.y < (love.graphics.getHeight() - playerHeight) then
			player.y = player.y + (player.speed * dt)
		end
	end
	
end

function love.draw()
	-- Local variables that store the current location of the mouse
	local mouseX, mouseY = love.mouse.getPosition()
	-- Local variable that stores the angle that the character should be rotated to
	local characterAngle = math.angle(mouseX, mouseY, player.x + (playerWidth / 2), player.y  + (playerHeight / 2))
	
	-- Draw the character with rotation applied
	love.graphics.draw(player.img, player.x, player.y, characterAngle)
end

-- Function takes two sets of coordinates and calculates the angle between the two points
-- Returned angle assumes all sprites by default face left
function math.angle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end