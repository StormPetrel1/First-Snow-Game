
--== Function caches ==--
local noise = love.math.noise

--== Packages ==--
local world = {
	--== Constants ==--
	-- Physics --
	buoyancy = -0.5,
	drag = 31/32,
	friction = 31/32,
	gravity = 1/8,
	waterLevel = 575,
	waterResist = 7/8,
	
	--== Pure ==--
	terrain = function(x)
		return noise(x / 1024) * 1280
	end,
}

-- Scene transitions --
do
	--== Constants ==--
	local tentX = 4000
	
	--== Data ==--
	-- 0: pause screen, 1: main screen
	local scene = 4
	
	--== Pure ==--
	function world.getTentX()
		return tentX
	end
	
	--== Messages ==--
	function world.getScene()
		return scene
	end
	
	--== Mutations ==--
	function world.lose()
		if scene == 1 then scene = -1 end
	end
	
	function world.win()
		if scene == 1 then scene = -2 end
	end
	
	function world.transition(frame)
		if frame % 400 == 0 then
			scene = scene - 1
		end
	end
	
	function world.checkTent(playerX)
		if playerX > tentX then
			world.win()
		end
	end
end

-- Hints --
do
	--== Data ==--
	local hint = ''
	local lifetime = 0
	
	--== Messages ==--
	function world.getHint()
		return hint
	end
	
	--== Mutations ==--
	function world.updateHint()
		lifetime = lifetime - 1
		if lifetime < 0 then hint = '' end
	end
	
	function world.setHint(_hint)
		lifetime = 300
		hint = _hint
	end
end

-->>
return world
