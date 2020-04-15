
-- adds gui library
local uare = require "uare"


-- variables controlling camera
camera = { }
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

-- variable that stores player data such as position and speed
player = { }

--variable that holds if the game is over
gameover = false

-- variables that stores gun data
playerBullets = { }	-- bullets in room
guns = { }			-- basic gun data

--variables that store enemy data
enemiesAround = { } -- enemies alive in the room
enemies = { }		-- basic enemy data
enemyBullets = { }  -- holds gunner bullets

-- represents an enum for basic enemy types
-- enTy = enemy types
enTy = {runner = 1, gunner = 2} 
ruTy = {basicboi = 1, fastboi = 2, bigboi = 3}
guTy = {slowboi = 1, jumpyboi = 2}
-- guSt = states
states = {still = 1, moving = 2}


debugAngle3 = 0

-- function is only called once at the beginning of the game
function love.load()

	WWIDTH, WHEIGHT = 1024, 576

	-- Makes window resizable
	love.window.setMode(WWIDTH, WHEIGHT, {resizable=true, vsync=false, minwidth=1024, minheight=576})

	-- Store sprites into their own variables
	tileset = love.graphics.newImage("Sprites/Tileset.png")
	playerSprite = love.graphics.newImage("Sprites/pipo-nekonin001.png")
	playerGun = love.graphics.newImage("Sprites/flamethrower_side.png")
	defaultBullet = love.graphics.newImage("Sprites/bullet.png")

	debugEnemy = love.graphics.newImage("Sprites/Box.png")
	
	-- Set the width and height of each tile on the screen (recommended to use power of 2 numbers)
	tileWidth, tileHeight = 16, 16
	playerWidth, playerHeight = 16, 16
	player2Width, player2Height = 32, 32
	-- Get the width and height of the tile spritesheet
	local tilesetWidth, tilesetHeight = tileset:getWidth(), tileset:getHeight()
	local player2SpriteWidth, player2SpriteHeight = playerSprite:getWidth(), playerSprite:getHeight()
	
	widthOffset = love.graphics.getWidth() / 4
	heightOffset = love.graphics.getHeight() / 4
	
	-- all tiles for the game are stored in quad, index starts at 1
	quads = 
	{
		love.graphics.newQuad(0, 0, tileWidth, tileHeight, tilesetWidth, tilesetHeight), -- 1 = floor tile
		love.graphics.newQuad(16, 0	, tileWidth, tileHeight, tilesetWidth, tilesetHeight) -- 2 = wall tile
	}
	
	playerSpriteSheet =
	{
		love.graphics.newQuad(0, 0, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 1 = walking down right foot extended
		love.graphics.newQuad(32, 0, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 2 = walking down base
		love.graphics.newQuad(64, 0, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 3 = walking down left foot extended
		love.graphics.newQuad(0, 32, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 4 = walking left right foot extended
		love.graphics.newQuad(32, 32, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 5 = walking left base
		love.graphics.newQuad(64, 32, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 6 = walking left left foot extended
		love.graphics.newQuad(0, 64, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 7 = walking right right foot extended
		love.graphics.newQuad(32, 64, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 8 = walking right base
		love.graphics.newQuad(64, 64, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 9 = walking right left foot extended
		love.graphics.newQuad(0, 96, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 10 = walking up right foot extended
		love.graphics.newQuad(32, 96, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight), -- 11 = walking up base
		love.graphics.newQuad(64, 96, player2Width, player2Height, player2SpriteWidth, player2SpriteHeight) -- 12 = walking up left foot extended
	}
	
	-- The game map is stored here, they are referenced by their quad index
	tileTable = 
	{
		{ 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
	}

	--sets up gui stuff
	uareStuff()



	--sets player default values
	player.isWalking = false
	player.frame = 1
	player.animationOffset = 0
	player.currentFrame = 1
	player.frameLength = 100
	player.maxFrame = 4 * player.frameLength

	player.health = 5

	player.iframes = 0
	player.iframesMax = .5
	
	-- Place the character in the center of the screen
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	
	-- sets player movement speed
	player.speed = 150


	
	-- holds current gun (1 = assault rifle, 2 = shotgun, 3 = flamethrower)
	gunType = 1

	-- holds bullet information
	-- holds arrays for each bullet type
	playerBullets[1] = { }
	playerBullets[2] = { }
	playerBullets[3] = { }

	-- holds distance bullets spawn away from player
	bulletSpawnDis = .05

	--holds data for each gun
	guns = {{ }, { }, { }}

	-- holds bullet sprite for each gun
	guns[1].bulletSprite = defaultBullet
	guns[2].bulletSprite = defaultBullet
	guns[3].bulletSprite = love.graphics.newImage("Sprites/Fire1.png")

	--TODO sets gun sprites for each gun 
	--[[
	guns[1].gunSprite = 
	guns[2].gunSprite = 
	guns[3].gunSprite = 
	--]]

	-- sets bullet speed
	guns[1].bulletSpeed = 450
	guns[2].bulletSpeed = 400
	guns[3].bulletSpeed = 250

	--sets number of bullets per shot
	guns[1].bulletsPerShot = 1
	guns[2].bulletsPerShot = 8
	guns[3].bulletsPerShot = 3

	--sets level of randomness for bullet spread
	guns[1].bulletSpread = .1
	guns[2].bulletSpread = .35
	guns[3].bulletSpread = .2

	-- holds the shot timers for each gun (in seconds)
	guns[1].shotTimer = 0
	guns[2].shotTimer = 0
	guns[3].shotTimer = 0

	guns[1].shotTimerMax = .15
	guns[2].shotTimerMax = .8
	guns[3].shotTimerMax = .1

	--holds the max time (in seconds) bullets can be on screen (1000 if not relevant)
	guns[1].maxTime = 1000
	guns[2].maxTime = 1000
	guns[3].maxTime = .5





	-- holds data on enemies
	-- enemy type 1 moves towards player
	-- enemy type 2 moves away from player and shoots
	enemies = {{ }, { }}

	-- holds data on enemy 1 types
	-- enemy type 1-1 is basic enemy
	-- enemy type 1-2 moves fast but has low health
	-- enemy type 1-3 moves slow but has much higher health
	-- doing it like this to show we can use inheritance
	enemies[1] = {{ }, { }, { }}

	-- holds data on enemy 2 types
	-- enemy type 2-1 stays away but shoots less often
	-- enemy type 2-2 might get closer but shoots more frequently
	enemies[2] = {{ }, { }}


	-- make tables tat hold all enemy information

	enemiesAround = {{ }, { }}
	enemiesAround[enTy.runner] = {{ }, { }, { }}
	enemiesAround[enTy.gunner] = {{ }, { }}

	-- sets movement speed of each enemy
	enemies[enTy.runner][ruTy.basicboi].moveSpeed = 100
	enemies[enTy.runner][ruTy.fastboi].moveSpeed = 200
	enemies[enTy.runner][ruTy.bigboi].moveSpeed = 50
	enemies[enTy.gunner][guTy.slowboi].moveSpeed = 100
	enemies[enTy.gunner][guTy.jumpyboi].moveSpeed = 300

	-- sets enemy health
	enemies[enTy.runner][ruTy.basicboi].enemyHealth = 5
	enemies[enTy.runner][ruTy.fastboi].enemyHealth = 3
	enemies[enTy.runner][ruTy.bigboi].enemyHealth = 15
	enemies[enTy.gunner][guTy.slowboi].enemyHealth = 6
	enemies[enTy.gunner][guTy.jumpyboi].enemyHealth = 4

	-- sets enemy aggro range
	enemies[enTy.runner][ruTy.basicboi].aggroRange = 250
	enemies[enTy.runner][ruTy.fastboi].aggroRange = 350
	enemies[enTy.runner][ruTy.bigboi].aggroRange = 400
	enemies[enTy.gunner][guTy.slowboi].aggroRange = 500
	enemies[enTy.gunner][guTy.jumpyboi].aggroRange = 400

	--sets range gunners start moving away
	enemies[enTy.gunner][guTy.slowboi].startRange = 200
	enemies[enTy.gunner][guTy.jumpyboi].startRange = 150

	-- sets range gunners stop moving away
	enemies[enTy.gunner][guTy.slowboi].stopRange = 400
	enemies[enTy.gunner][guTy.jumpyboi].stopRange = 300

	-- sets gunner shot timers  
	enemies[enTy.gunner][guTy.slowboi].shotTimer = 0
	enemies[enTy.gunner][guTy.jumpyboi].shotTimer = 0

	enemies[enTy.gunner][guTy.slowboi].shotTimer = 2
	enemies[enTy.gunner][guTy.jumpyboi].shotTimer = 1


	--sets enemy sprites 
	enemies[enTy.runner][ruTy.basicboi].enemySprite = debugEnemy
	enemies[enTy.runner][ruTy.fastboi].enemySprite = debugEnemy
	enemies[enTy.runner][ruTy.bigboi].enemySprite = debugEnemy
	enemies[enTy.gunner][guTy.slowboi].enemySprite = debugEnemy
	enemies[enTy.gunner][guTy.jumpyboi].enemySprite = debugEnemy

	--[[holds copy paste stuff
	enemies[enTy.runner][ruTy.basicboi]. = 
	enemies[enTy.runner][ruTy.fastboi]. = 
	enemies[enTy.runner][ruTy.bigboi]. = 
	enemies[enTy.gunner][guTy.slowboi]. = 
	enemies[enTy.gunner][guTy.jumpyboi]. = 
	--]]

	--spawns enemies on map
	spawnEnemies()



	
end

--uare requires you to set up a "style" for each ui element
--styles can be reused of course
function uareStuff() 

	--set up style for healthbar
	healthStyle = uare.newStyle({
		height = 25,
		width = 30,

		color = {1, 0, 0},

		drag = {
			enabled = true,
			fixed = {
				x = false,
				y = true
			},

			bounds = {
				{
					x = WWIDTH*.05
				},
				{
					x = WWIDTH*.25
				}
			}
		}
	})

	--set up style for healthbar background 
	healthBackgroundStyle = uare.newStyle({
	    height = 25,
	    width = WWIDTH*.25-21,
	    
	    color = {0, 1, 0},
	    
	    text = {
			font = love.graphics.newFont(24),
			color = {255, 255, 255},
			align = "center",
			offset = {
	        	x = 150,
	        	y = -16
	    	}
	    }
	})

	--set style for restart message
	restartStyle = uare.newStyle({
		height = 200,
		width = 400,

		color = {0, 0, 0},

		text = {
			font = love.graphics.newFont(24),
			color = {1,1,1},
			align = "center",
			offset = {
				x = 0,
				y = -50
			}
		}

	})

	--create the object for the background of the healthbar
	healthLabel = uare.new({
		x = WWIDTH*.05,
		y = WHEIGHT*.05
	}):style(healthBackgroundStyle)

	--create the healthbar (actually just a box that indicates health)
	healthbar = uare.new({
		x = WWIDTH*.25,
		y = WHEIGHT*.05
	}):style(healthStyle)

	--create a box with the gameover text
	--the neat thing is that it hides the player lol
	--no need for a death animation
	restartButton = uare.new({
		x = WWIDTH * .5-200,
		y = WHEIGHT * .5-100
	}):style(restartStyle)
	restartButton.text.display = "Game Over!\nPress R to Restart"

end


-- Update is run every frame
-- Currently checks for movemovent input and moves the character if necessary
function love.update(dt)

	-- updates the GUI
	updateUareStuff(dt)

	-- only allow player movement if they have not already lost
	if gameover == false then
		updatePlayer(dt)

	-- if game is over, allow player to hit r to restart
	elseif love.keyboard.isDown('r') then
		uare.clear()
		love.event.quit("restart")
	end
	
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
	
	-- playerAnimation
	playerFrameManager()

	--update bullet positions
	updateBullets(dt)
	
	--calculate remaining time of shot timers
	checkShotTimers(dt)

	--handle enemy updates
	updateEnemies(dt)

	--fire bullets if left click is held and we are allowed to shoot again
	if gameover == false and love.mouse.isDown(1) and guns[gunType].shotTimer <= 0 then
		fireBullets()
	end

	--put here in case of screen size change
	widthOffset = love.graphics.getWidth() / 4
	heightOffset = love.graphics.getHeight() / 4
	
	camera:setScale(0.5, 0.5)
	camera:setPostion(player.x - widthOffset, player.y - heightOffset)
	
	
end


function love.draw()

	camera:set()


	-- For loop with second nested for loop that goes through the tileTable drawing each tile
	-- in their respective x, y coordinates
	for rowIndex = 1, #tileTable do
		local row = tileTable[rowIndex]
		for columnIndex = 1, #row do
			local number = row[columnIndex]
			love.graphics.draw(tileset, quads[number], (columnIndex-1) * tileWidth, (rowIndex - 1) * tileHeight)
		end
	end

	-- Local variables that store the current location of the mouse
	--local mouseX, mouseY = love.mouse.getPosition()
	local mouseX, mouseY = camera:mousePosition()

	-- Local variable that stores the angle that the character should be rotated to
	local characterAngle = math.angle(mouseX, mouseY, player.x + (playerWidth / 2), player.y  + (playerHeight / 2))
	if gameover == true then characterAngle = 0 end
	playerSpriteDirection(characterAngle)

	love.graphics.draw(playerSprite, playerSpriteSheet[player.frame + player.animationOffset], player.x, player.y, 0, 1, 1, 16, 16)
	love.graphics.draw(playerGun, player.x, player.y+5, characterAngle, 1, 1, 26)
	
	--[[
	love.graphics.print(characterAngle, 100, 100)
	love.graphics.print(mouseX, 100, 112)
	love.graphics.print(mouseY, 100, 124)
	love.graphics.print(player.x, 100, 136)
	love.graphics.print(player.y, 100, 148)
	love.graphics.print(gunType, 100, 160)
	love.graphics.print(debugAngle3, 100, 172)

	-- love.graphics.print(player.animationOffset, 100, 112)
	-- love.graphics.print(player.frame, 100, 124)

	--]]

	-- draws each instance of playerBullets
	for j = 1, #playerBullets do
		for i,v in ipairs(playerBullets[j]) do
			local spr = guns[j].bulletSprite
			love.graphics.draw(spr, v.x, v.y, 0, 1, 1, spr:getHeight()/2, spr:getWidth()/2)
		end 
	end

	-- draws each enemy
	--explanation for array iteration in checkPlayerCollisions()
	for k = 1, #enemiesAround do
		for j = 1, #enemiesAround[k] do
			for i, v in ipairs(enemiesAround[k][j]) do
				love.graphics.draw(enemies[k][j].enemySprite, v.x, v.y, 0, 1, 1, 0, 0)
			end
		end
	end

	-- TODO draws enemy bullets 



	
	
	camera:unset()


	-- draws the GUI, keep last so it draws over other stuff
	--uare.draw()
	healthLabel:drawSelf()
	healthbar:drawSelf()
	if (gameover == true) then restartButton:drawSelf() end
	love.graphics.setColor(1,1,1)
	
	
end

-- Function takes two sets of coordinates and calculates the angle between the two points
-- Returned angle assumes all sprites by default face left
function math.angle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end

-- function takes two sets of coordinates and finds the distance between them
function findDistance(x1,y1, x2,y2) 
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

--check if point (x, y) is in a box determined by c and s
--(cx, cy) at top left
--(cx + sx, cy + sy) at bottom left
function collisionBox(x, y, cx, cy, sx, sy)
	if (x > cx and x < cx + sx and y > cy and y < cy + sy) then
		return true
	end

	return false
end

--check if two boxes are overlapping
function collisionBoxes (x1, y1, x2, y2, cx, cy, sx, sy)
	if x2 < cx or x1 > cx + sx or y2 < cy or y1 > cy + sx then
		return false
	end

	return true
end

--iterates through guns the player has when right click is hit
function love.mousepressed(x, y, button)
	if button == 2 then
	    gunType = gunType + 1

	    --if the gun type is at the limit of the array, go back to start
    	if gunType > #guns then gunType = 1 end
	end
end

--here's where the ui stuff is 
function updateUareStuff(dt)
	--gotta call this function in update!
	uare.update(dt, love.mouse.getX(), love.mouse.getY())

	--update healthbar with player health
	healthbar:setHorizontalRange(player.health / 5)

	--store healtbar value in a text field 
	local hp = healthbar:getHorizontalRange()

	healthLabel.text.display = hp * 5
end

function updatePlayer(dt) 
	player.isWalking = false
	
	-- If the player is pressing d or a then move them horizontally
	if love.keyboard.isDown('d') then
		-- confine the player to the screen boundary
		if player.x < (love.graphics.getWidth() - playerWidth) then
			-- move the player if enough time has passed since the last check (dt)
			player.x = player.x + (player.speed * dt)
			player.isWalking = true
		end
	elseif love.keyboard.isDown('a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
			player.isWalking = true
		end
	end
	
	if love.keyboard.isDown('w') then
		if player.y > 0 then
			player.y = player.y - (player.speed * dt)
			player.isWalking = true
		end
	elseif love.keyboard.isDown('s') then
		if player.y < (love.graphics.getHeight() - playerHeight) then
			player.y = player.y + (player.speed * dt)
			player.isWalking = true
		end
	end

	checkPlayerCollisions(player.x, player.y)


end

-- function that manages what frame of the character table is displayed
function playerFrameManager()
	
	-- if the player is walking increment the current frame counter
	-- when the current frame counter exceeds the maximum, roll back to the beginning

	-- if the player isn't moving, reset the counter to the beginning
	if player.isWalking then
		player.currentFrame = player.currentFrame + 1
		if player.currentFrame > player.maxFrame then
			player.currentFrame = 1
		end
	else
		player.currentFrame = 1
	end
	
	-- manages when to play the base walking sprite vs the feet extended walking sprites.
	-- the duration of each frame is directly controlled by player.frameLength
	if ((player.currentFrame >= 1 and player.currentFrame < (1 * player.frameLength)) or (player.currentFrame > (player.frameLength * 2) and player.currentFrame <= (player.frameLength * 3))) then
		player.frame = 2
	elseif (player.currentFrame > player.frameLength and player.currentFrame <= (player.frameLength * 2)) then
		player.frame = 1
	else
		player.frame = 3
	end
	
end

-- function that decides which direction the player is facing and sets an offset to control the sprite table
function playerSpriteDirection(characterAngle)
	
	-- if player is facing down
	if (characterAngle <= -0.785 and characterAngle >= -2.355) then
		player.animationOffset = 0
	-- if player is facing up
	elseif (characterAngle >= 0.785 and characterAngle <= 2.355) then
		player.animationOffset = 9
	-- if player is facing left
	elseif (characterAngle <= 0.785 and characterAngle >= -0.785) then
		player.animationOffset = 3
	-- player is facing right
	else
		player.animationOffset = 6
	end
end

--spawns all enemies on load
--TODO call this when all enemies are destroyed
--TODO increment amount of enemies that get spawned
function spawnEnemies() 
	enemyCounts = { {math.random() * 6, math.random() * 3, math.random() * 2}, 
	{0, 0} }

	--for each number carried in the array, spawn that amount of enemies
	for k=1, #enemyCounts do
		for j=1, #enemyCounts[k] do
			for i=1, enemyCounts[k][j] do
				--throw enemy in a random place in the room 
				newx = math.random() * love.graphics.getWidth()
				newy = math.random() * love.graphics.getHeight()
				table.insert(enemiesAround[k][j], {x = newx, y = newy, state = states.still, health = enemies[k][j].enemyHealth})
			end
		end
	end

end

function updateEnemies(dt)

	--check runners first 
	local k = enTy.runner 
	for j=1, #enemiesAround[k] do
		for i, v in ipairs(enemiesAround[k][j]) do

			--grab reference to distance to player
			local dis = findDistance(player.x, player.y, v.x, v.y)

			--if player is close, change to moving state
			if v.state == states.still and dis < enemies[k][j].aggroRange then
				v.state = states.moving
			end

			--if in moving state, move enemy
			if v.state == states.moving then 
				moveEnemy(v, enemies[k][j].moveSpeed, dt) 
			end
		end 
	end


	-- check gunners second 
	k = enTy.gunner
	for j=1, #enemiesAround[k] do
		for i, v in ipairs(enemiesAround[k][j]) do

			local dis = findDistance(player.x, v.x, player.y, v.y)

			if dis < enemies[k][j].aggroRange then
				--TODO fire bullet at player on countdown
			end

			if state == states.still then
				if dis < enemies[k][j].startRange then
					v.state = states.moving
				end
			else 
				if dis > enemies[k][j].stopRange then
					v.state = states.still
				else
					moveEnemy(v, -enemies[k][j].moveSpeed, dt)
				end
			end
		end 
	end

end

--pass in an individual enemy (v), speed and dt
--call to move an enemy towards (or away if spd is negative) the player
function moveEnemy(v, spd, dt) 
	--if player is in iframes, do not move forward
	--this prevents fast enemies from being impossible to kill
	--and also gives the player a breather 
	if player.iframes <= 0 then
		local angle = math.atan2((player.y - v.y), (player.x - v.x))

		local enemyDx = spd * math.cos(angle)
		local enemyDy = spd * math.sin(angle)

		v.x = v.x + (enemyDx * dt)
		v.y = v.y + (enemyDy * dt)
	end
end


--updates bullet positions, then checks if they should still exist
function updateBullets(dt) 

	--iterates throgugh each type of bullet
	for j=1, #playerBullets, 1 do

		--iterates through each bullet in each bullet type's table
		--uses while loop to prevent loop from skiping indeces when bullets are removed
		local i = 1
		while (i <= #playerBullets[j]) do

			-- just storing it in v for convience
			v = playerBullets[j][i]

			v.x = v.x + (v.dx * dt)
			v.y = v.y + (v.dy * dt)

			v.time = v.time + dt

			--if bullet is outside the level geometry or on screen for too long, destroy it
			if checkBounds(v.x, v.y) or checkPBulletCollisions(v.x, v.y) or v.time > guns[j].maxTime then
				table.remove(playerBullets[j], i)
			else
				-- only increment if no bullet was removed
				-- if playerBullets[0][2] is removed, playerBullets[0][3] will take its place
				i = i + 1
			end
		end
	end
end

--checks if the passed in x and y values are outside of the level geometry
function checkBounds(x, y)
	return x < 0 or y < 0 or x > love.graphics.getWidth() or y > love.graphics.getHeight()
end

--check each individual enemy to see if its colliding with the player
function checkPlayerCollisions(x, y) 

	--increment through both enemy types in the enemiesAround array
	for k=1, #enemiesAround do
		--increment through each subtype of enemy
		for j=1, #enemiesAround[k] do
			--increment through each individual enemy for each subtype
			for i,v in ipairs(enemiesAround[k][j]) do

				--grab a reference to the enemy's sprite for easier math
				local spr = enemies[k][j].enemySprite

				--compare a 16x16 box around the player with the enemy's collision box
				--player sprite origin is in the middle, enemy origin is at top left
				--also check if player is in iframes
				if player.iframes <= 0 and collisionBoxes(x-8, y-8, x+8, y+8,
					v.x, v.y, spr:getWidth(), spr:getHeight()) then
					--decrement player health and set iframes
					player.health = player.health - 1
					player.iframes = player.iframesMax
					--if player's outta health then they're dead!!!
					if (player.health <= 0) then
						gameover = true
					end

					--return true if you collide with an enemy
					return true
				end
			end
		end
	end

	-- if collision didn't happen, return false
	return false
end

-- check each individual enemy to see if its overlapping with a bullet
function checkPBulletCollisions(x, y)
	for k=1, #enemiesAround do
		for j=1, #enemiesAround[k] do
			for i,v in ipairs(enemiesAround[k][j]) do
				--local dis = findDistance(x, y, v.x, v.y)
				local spr = enemies[k][j].enemySprite

				if collisionBox(x, y, v.x, v.y, spr:getWidth(), spr:getHeight()) then
					v.health = v.health - 1
					if (v.health <= 0) then
						table.remove(enemiesAround[k][j], i)
					end

					return true
				end
			end
		end
	end

	return false
end

--decreases shot timers for each weapon
function checkShotTimers(dt) 
	for i=1, #guns do
		if guns[i].shotTimer > 0 then
			guns[i].shotTimer = guns[i].shotTimer - dt
		end
	end

	--also decrement iframes for the player
	if player.iframes > 0 then
		player.iframes = player.iframes - dt
	end
end

--fire the bullet of the currently selected gun
function fireBullets()

	--set the can shoot timer
	guns[gunType].shotTimer = guns[gunType].shotTimerMax

	--hold the starting x and y, as well as mouse x and y in world coords
	local startX = player.x
	local startY = player.y
	local mouseX, mouseY = camera:mousePosition()

	--determine angle to shoot
	local angle = math.atan2((mouseY - startY), (mouseX - startX))

	--create each bullet required for currently selected gun 
	for i = 1, guns[gunType].bulletsPerShot, 1 do

		--create shot spread 
		local offAngle = angle + ((math.random() - .5) * guns[gunType].bulletSpread)

		--set the amount the bullet should move each update
		local bulletDx = guns[gunType].bulletSpeed * math.cos(offAngle)
		local bulletDy = guns[gunType].bulletSpeed * math.sin(offAngle)

		--add bullet to bullet table
		table.insert(playerBullets[gunType], {x = startX, y = startY, dx = bulletDx, dy = bulletDy, time = 0})

		--push the bullet in the array forward a little bit so that they are outside the player
		local lastBul = playerBullets[gunType][#playerBullets[gunType]]
		lastBul.x = lastBul.x + (lastBul.dx * bulletSpawnDis)
		lastBul.y = lastBul.y + (lastBul.dy * bulletSpawnDis)
	end
end

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:setPostion(x, y)
	self.x = x
	self.y = y
end

function camera:setScale(sx, sy)
	self.scaleX = sx
	self.scaleY = sy
end

-- default mouse.getPosition() gets local coordinates
-- use this for world coordinates
function camera:mousePosition()
	return love.mouse.getX() * self.scaleX + self.x, love.mouse.getY() * self.scaleY + self.y
end