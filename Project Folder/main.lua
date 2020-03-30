-- variable that stores player data such as position and speed
player = { }

-- variables that stores gun data
playerBullets = { }
guns = { }

-- variables controlling camera
camera = { }
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

debugAngle = 0

-- function is only called once at the beginning of the game
function love.load()
	-- Makes window resizable
	love.window.setMode(1024, 576, {resizable=true, vsync=false, minwidth=1024, minheight=576})

	-- Store sprites into their own variables
	tileset = love.graphics.newImage("Sprites/Tileset.png")
	playerSprite = love.graphics.newImage("Sprites/pipo-nekonin001.png")
	playerGun = love.graphics.newImage("Sprites/flamethrower_side.png")
	
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
	guns[2].bulletSpread = .5
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
	guns[3].maxTime = 1

	player.isWalking = false
	player.frame = 1
	player.animationOffset = 0
	player.currentFrame = 1
	player.frameLength = 100
	player.maxFrame = 4 * player.frameLength
	
	-- Place the character in the center of the screen
	player.x = love.graphics.getWidth() / 2
	player.y = love.graphics.getHeight() / 2
	
	-- sets player movement speed
	player.speed = 150
	
end


-- Update is run every frame
-- Currently checks for movemovent input and moves the character if necessary
function love.update(dt)

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
	
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end
	
	-- playerAnimation()
	playerFrameManager()

	--update bullet positions
	updateBullets(dt)
	
	--calculate remaining time of shot timers
	checkShotTimers(dt)

	--fire bullets if left click is held and we are allowed to shoot again
	if love.mouse.isDown(1) and guns[gunType].shotTimer <= 0 then
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
	
	playerSpriteDirection(characterAngle)
	
	love.graphics.draw(playerSprite, playerSpriteSheet[player.frame + player.animationOffset], player.x, player.y, 0, 1, 1, 16, 16)
	love.graphics.draw(playerGun, player.x, player.y+5, characterAngle, 1, 1, 26)
	
	love.graphics.print(characterAngle, 100, 100)
	love.graphics.print(mouseX, 100, 112)
	love.graphics.print(mouseY, 100, 124)
	love.graphics.print(player.x, 100, 136)
	love.graphics.print(player.y, 100, 148)
	love.graphics.print(gunType, 100, 160)
	love.graphics.print(debugAngle, 100, 172)

	-- love.graphics.print(player.animationOffset, 100, 112)
	-- love.graphics.print(player.frame, 100, 124)

	--draws bullets as little circles, TODO set to sprites
	love.graphics.setColor(0.5, 0.5, 0.5)
	for j = 1, #playerBullets do
		for i,v in ipairs(playerBullets[j]) do
			love.graphics.circle("fill", v.x, v.y, 3)
		end 
	end
	
	
	camera:unset()
	
	
end

-- Function takes two sets of coordinates and calculates the angle between the two points
-- Returned angle assumes all sprites by default face left
function math.angle(x1,y1, x2,y2)
	return math.atan2(y2-y1, x2-x1)
end

--iterates through guns the player has when right click is hit
function love.mousepressed(x, y, button)
	if button == 2 then
	    gunType = gunType + 1

	    --if the gun type is at the limit of the array, go back to start
    	if gunType > #guns then gunType = 1 end
	end
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
			if checkBounds(v.x, v.y) or v.time > guns[j].maxTime then
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

--decreases shot timers for each weapon
function checkShotTimers(dt) 
	for i=1, #guns do
		if guns[i].shotTimer > 0 then
			guns[i].shotTimer = guns[i].shotTimer - dt
		end
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