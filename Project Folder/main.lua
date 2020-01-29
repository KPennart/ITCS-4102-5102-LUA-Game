function love.load()
	-- Variable that stores the Box sprite in a Love Image
	box = love.graphics.newImage("Sprites/Box.png")
	
	-- Variables that hold the width and height of the Box sprite in Sprites folder
	characterWidth = box:getWidth()
	characterHeight = box:getHeight()
	
	-- Variables that hold the location of the character's x, y coordinates
	characterX = 100
	characterY = 100
end

-- Function takes two sets of coordinates and calculates the angle between the two points
-- Returned angle assumes all sprites by default face left
function math.angle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end


function love.draw()
	-- Local variables that store the current location of the mouse
	local mouseX, mouseY = love.mouse.getPosition()
	-- Local variable that stores the angle that the character should be rotated to
	local characterAngle = math.angle(mouseX, mouseY, characterX + (characterWidth / 2), characterY  + (characterHeight / 2))
	
	-- Draw the character with rotation applied
	love.graphics.draw(box, characterX, characterY, characterAngle)
end