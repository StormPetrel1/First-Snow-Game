
--== File caches ==--
local bit = require 'bit'
local spec = require 'spec'
local sprite = require 'sprite'
local world = require 'world'

--== Function caches ==--
local boolNum = boolNum
local normalize = normalize
local signx0 = signx0
local lshift = bit.lshift
local rshift = bit.rshift
local drawImage = love.graphics.draw
local line = love.graphics.line
local points = love.graphics.points
local polygon = love.graphics.polygon
local rect = love.graphics.rectangle
local color = love.graphics.setColor
local keyDown = love.keyboard.isDown
local random = love.math.random
local randomNorm = love.math.randomNormal
local mousePos = love.mouse.getPosition
local abs = math.abs
local max = math.max
local cameraToWorld = spec.cameraToWorld
local push = table.insert
local terrain = world.terrain

--== Constant caches ==--
local buoyancy = world.buoyancy
local drag = world.drag
local friction = world.friction
local gravity = world.gravity
local waterLevel = world.waterLevel
local waterResist = world.waterResist

--== Pure ==--
local function boxCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	local overlapX = abs(x2 - x1) - w1 - w2
	
	if overlapX < 0 then
		local overlapY = abs(y2 - y1) - h1 - h2
		
		-- If there is overlap in both dimensions, return the values
		if overlapY < 0 then return overlapX, overlapY end
	end
end

--== Packages ==--
local ent = {}

-- Player --
do
	--== Data ==--
	-- Entity references --
	local holding = 0
	
	-- Finite-state values --
	local jump = false
	local sheltered = false
	
	-- Physics --
	local x = -250
	local y = -300
	local vx = 0
	local vy = 1
	local accel = 1/16
	local w = 12.5
	local h = 22.5
	
	-- Stats --
	local jumpStrength = -6
	local temp = 100
	local matches = 4
	
	--== Mutations ==--
	local function movePlayer(xdir, ydir)
		-->> Update velocity >>--
		vx = vx + xdir * accel
		vy = vy + ydir * accel * 0.5
	end
	
	--== Packages ==--
	ent.player = {
		--== Messages ==--
		getPos = function() return x, y end,
		getVel = function() return vx, vy end,
		getSize = function() return w, h end,
		getTemp = function() return temp end,
		getHolding = function() return holding end,
		
		--== Mutations ==--
		draw = function()
			color(1,1,1,1)
			local dirX = signx0(vx)
			drawImage(sprite.player, x - w * dirX, y - h, 0, dirX, 1)
		end,
		
		resolveCollision = function(overlapX, overlapY)
			if overlapX > overlapY then
				-->> Correct overlap
				x = x + overlapX * signx0(vx)
				
				-->> Bounce and friction >>--
				vx = vx * -0.5
				vy = vy * friction
			else
				-->> Correct overlap
				y = y + overlapY * signx0(vy)
				
				-->> Bounce and friction >>--
				vx = vx * friction
				vy = jump and vy >= 0 and jumpStrength or vy * -0.125
			end
		end,
		
		pickupWood = function(id)
			holding = id
		end,
		
		useMatch = function()
			if matches > 0 then
				matches = matches - 1
				return true
			end
			
			return false
		end,
		
		heat = function(n)
			temp = temp + n
		end,
		
		-- Client update --
		function()
			-->> Update jump
			jump = keyDown 'space'
			
			-->> Update velocity >>--
			movePlayer(
				boolNum(keyDown('d', 'right')) - boolNum(keyDown('a', 'left')),
				boolNum(keyDown('s', 'down')) - boolNum(keyDown('w', 'up'))
			)
		end,
		
		-- Movement --
		function()
			-->> Update velocity using forces >>--
			vx = vx * drag
			vy = vy * drag + gravity
			
			-->> Check for water
			if y > waterLevel + h then
				-->> Apply water resistance >>--
				vx = vx * waterResist
				vy = vy * waterResist
				
				-->> Hypothermia onset >>--
				temp = temp - 0.1
			end
			
			-->> Update position >>--
			x = x + vx
			y = y + vy
		end,
		
		-- Static collision --
		function()
			local terrainY = terrain(x) - h
			if y > terrainY then
				y = terrainY
				vx = vx * friction
				vy = jump and jumpStrength or 0
			end
		end,
		
		-- Slow hypothermia onset --
		function()
			temp = temp - 0.02
		end,
		
		-- Manipulate wood --
		function()
			-->> Early exit for invalid IDs or long distance >>--
			if holding <= 0 then return end
			local wood = ent.wood
			local woodX, woodY = wood.getPos(holding)
			if abs(woodX - x) > 100 then return end
			
			local mouseX, mouseY = cameraToWorld(mousePos())
			wood.accelerate(holding, normalize(mouseX - woodX, mouseY - woodY))
		end
	}
end

-- Trees --
do
	--== Data ==--
	local n = 0
	
	-- Physics --
	local x = {}
	local w = 6
	local h = {}
	
	--== Packages ==--
	ent.tree = {
		--== Messages ==--
		
		--== Mutations ==--
		new = function(_x)
			n = n + 1
			x[n] = _x
			h[n] = 128
		end,
		
		draw = function()
			for i = 1, n do
				color(0.35, 0.2, 0.125)
				local x = x[i]
				local h = h[i]
				local y = terrain(x) - h
				if h > 20 then
					polygon('fill', x, y - h, x + w, y + h, x - w, y  + h)
					
					-->> Draw branches >>--
					local size = 1
					for branchY = y - h, y + rshift(h, 1), 4 do
						local alternateSign = lshift(size % 2, 1) - 1
						-- Snow --
						color(0.5, 0.55, 0.65, 1)
						line(x, branchY - 1, x + size * alternateSign, branchY + 24)
						color(0.15, 0.4, 0.2, 1)
						line(x, branchY, x + size * alternateSign, branchY + 25)
						size = size + 1
					end
				else
					rect('fill', x - w, y - h, lshift(w, 1), lshift(h, 1))
				end
			end
		end,
		
		detectCollisionAt = function(testX, testY)
			local groundY = terrain(testX)
			for i = 1, n do
				if abs(x[i] - testX) < w and abs(groundY - h[i] - testY) < h[i] then
					return i
				end
			end
			
			return -1
		end,
		
		cutAt = function(id, cutY)
			local groundY = terrain(x[id])
			local newH = rshift(groundY - cutY, 1)
			local remainderH = h[id] - newH
			h[id] = newH
			ent.wood.new(x[id], cutY - remainderH, w, remainderH)
		end,
	}
end

-- Wood --
do
	--== Data ==--
	local n = 0
	
	-- Physics --
	local x = {}
	local y = {}
	local vx = {}
	local vy = {}
	local w = {}
	local h = {}
	
	-- Stats --
	local mass = {}
	local temp = {}
	
	--== Packages ==--
	ent.wood = {
		--== Messages ==--
		getPos = function(id) return x[id], y[id] end,
		
		--== Mutations ==--
		new = function(_x, _y, _w, _h)
			n = n + 1
			x[n] = _x
			y[n] = _y
			vx[n] = 0
			vy[n] = 0
			w[n] = _w
			h[n] = _h
			mass[n] = _w * _h
			temp[n] = 30
		end,
		
		draw = function()
			for i = 1, n do
				if temp[i] > 100 then
					color(0.75, 0.3, 0.1, 1)
					points(
						x[i] + randomNorm(-12,0), y[i] + randomNorm(-12,-12),
						x[i] + randomNorm(-8,0), y[i] + randomNorm(-16,-16)
					)
				else
					color(0.3, 0.15, 0.075, 1)
				end
				local w, h = w[i], h[i]
				rect('fill', x[i] - w, y[i] - h, lshift(w, 1), lshift(h, 1))
			end
		end,
		
		detectCollisionAt = function(testX, testY)
			for i = 1, n do
				if abs(x[i] - testX) < w[i] and abs(y[i] - testY) < h[i] then
					return i
				end
			end
			
			return -1
		end,
		
		accelerate = function(id, _vx, _vy)
			local resist = max(16, mass[id] * 0.05)
			vx[id] = vx[id] + _vx / resist
			vy[id] = vy[id] + _vy / resist
		end,
		
		turn = function(id)
			local _w = w[id]
			w[id] = h[id]
			h[id] = _w
		end,
		
		light = function(id)
			if mass[id] < 4 then return end
			temp[id] = 200
		end,
		
		-- Movement --
		function()
			for i = 1, n do
				-->> Calculate new velocity using forces >>--
				local _vx = vx[i] * drag
				local _vy = vy[i] * drag + gravity
				
				-->> Check for water
				if y[i] > waterLevel + h[i] then
					-->> Apply water resistance to new velcoity >>--
					_vx = _vx * waterResist
					_vy = _vy * -0.5 + buoyancy
					
					-->> Put out fire
					temp[i] = 30
				end
				
				-->> Update velocity >>--
				vx[i] = _vx
				vy[i] = _vy
				
				-->> Update position >>--
				x[i] = x[i] + _vx
				y[i] = y[i] + _vy
			end
		end,
		
		-- Static collision --
		function()
			for i = 1, n do
				local terrainY = terrain(x[i]) - h[i]
				if y[i] > terrainY then
					y[i] = terrainY
					vx[i] = vx[i] * friction
					vy[i] = vy[i] * -0.125
				end
			end
		end,
		
		-- Player collision --
		function()
			--== Temp ==--
			local player = ent.player
			local playerX, playerY = player.getPos()
			local playerW, playerH = player.getSize()
			local playerVX, playerVY = player.getVel()
			
			for i = 1, n do
				local overlapX, overlapY = boxCollision(
					playerX,
					playerY,
					playerW,
					playerH,
					x[i],
					y[i],
					w[i],
					h[i]
				)
				
				-->> Collision!!! >>--
				if overlapX then
					player.resolveCollision(overlapX, overlapY)
					
					-->> Accelerate wood >>--
					local resist = mass[i] * 0.05
					vx[i] = vx[i] + playerVX / resist
					vy[i] = vy[i] + playerVY / resist
				end
			end
		end,
		
		-- Heat --
		function()
			local player = ent.player
			local playerX = player.getPos()
			for i = 1, n do
				if temp[i] > 100 then
					temp[i] = temp[i] - 0.25
					mass[i] = mass[i] * 0.99
					if abs(x[i] - playerX) < 100 then
						player.heat(0.075)
					end
				end
			end
		end,
		
	}
end

-- Air --
do
	--== Data ==--
	local n = 0
	
	-- Physics --
	local x = {}
	local y = {}
	local vx = {}
	local vy = {}
	
	-- Stats --
	local temp = {}
	
	--== Packages ==--
	ent.air = {
		--== Messages ==--
		
		--== Mutations ==--
		new = function(_x, _y)
			n = n + 1
			x[n] = _x
			y[n] = _y
			vx[n] = 0
			vy[n] = 0
			temp[n] = 30
		end,
		
		draw = function()
			for i = 1, n do
				if temp[i] > 100 then
					color(1, 0.75, 0, temp[i] / 300)
					points(x[i], y[i])
				end
			end
		end,
		
	}
end

-->> Create entities >>--
for treeX = -2000, 4000, 75 do
	local offsetX = treeX + random(-25, 25)
	if terrain(offsetX) < waterLevel then
		ent.tree.new(offsetX)
	end
end

-->>
return ent
