
--== File caches ==--
local bit = require 'bit'
local ent = require 'ent'
local spec = require 'spec'
local sprite = require 'sprite'
local clearTable = require 'table.clear'
local world = require 'world'

--== Function caches ==--
local options = options
local pairs = pairs
local lshift = bit.lshift
local circle = love.graphics.circle
local drawImage = love.graphics.draw
local getDim = love.graphics.getDimensions
local line = love.graphics.line
local origin = love.graphics.origin
local gpop = love.graphics.pop
local gprint = love.graphics.print
local gpush = love.graphics.push
local rect = love.graphics.rectangle
local color = love.graphics.setColor
local mouseDown = love.mouse.isDown
local mousePos = love.mouse.getPosition
local fps = love.timer.getFPS
local floor = math.floor
local cameraToWorld = spec.cameraToWorld
local setUICamera = spec.setUICamera
local updateCamera = spec.updateCamera
local push = table.insert
local getHint = world.getHint
local getScene = world.getScene
local getTentX = world.getTentX
local terrain = world.terrain

--== Constant caches ==--
local player = ent.player
local targetDT = spec.targetDT
local waterLevel = world.waterLevel

--== Data ==--
local groundMesh = {}

-->>
return function(frame, uiW, uiH)
	--== Temp ==--
	local scene = getScene()
	
	-->> Position camera
	setUICamera()
	
	-->> Draw background >>--
	
	
	
	-->> Transition based on scene >>--
	if scene == 1 then
		-- Main screen --
		-->> Reposition camera
		origin()
		updateCamera(player.getPos())
			-->> Draw tent >>--
			color(1,1,1,1)
			local tentX = getTentX()
			drawImage(sprite.tent, tentX, terrain(tentX) - 46)
			
			-->> Draw entities >>--
			for _, entType in pairs(ent) do
				entType.draw()
			end
			
			-->> Draw water >>--
			color(0, 0.5, 0.75, 0.5)
			local windowW, windowH = getDim()
			local waterX, waterFloor = cameraToWorld(0, windowH)
			rect(
				'fill',
				waterX,
				waterLevel,
				lshift(uiW, 2),
				waterFloor - waterLevel
			)
			
			-->> Draw ground >>--
			-->> Reset ground mesh
			clearTable(groundMesh)
			
			-->> Fill ground mesh >>--
			for cameraX = 0, windowW do
				--== Temp ==--
				local alternation = cameraX % 2 == 0
				local worldX, worldY = cameraToWorld(cameraX, windowH)
				local groundY = terrain(worldX)
				
				-->> Push line (alternating from top to bottom) >>--
				push(groundMesh, worldX)
				push(groundMesh, options(alternation, worldY, groundY))
				push(groundMesh, worldX)
				push(groundMesh, options(alternation, groundY, worldY))
			end
			
			-->> Render ground mesh
			color(0.5, 0.55, 0.65, 1)
			line(groundMesh)
			
		-->> Reposition camera
		origin()
		setUICamera()
		
		-->> Draw FPS
		color(1,1,1,1)
		gprint(fps() .. ' FPS', -uiW + 4, -uiH + 2)
		
		-->> Draw timer
		local seconds = floor(frame * targetDT)
		gprint(
			floor(seconds / 60) .. ':' .. seconds % 60,
			-uiW + 4, -uiH + 14
		)
		
		-->> Draw hint
		gprint(getHint(), -uiW + 4, -uiH + 26, 0, 2,2)
		
		-->> Draw player temperature
		color(0.125, 0.75, 1, 1)
		local barWidth = lshift(player.getTemp(), 2)
		rect('fill', -barWidth, -uiH, lshift(barWidth, 1), 14)
		
	elseif scene == 2 then
		-- Intro 3 --
		color(1,1,1, frame % 400 / 600)
		gprint(
			'Make your way East to your tent,',
			-225,-20, 0, 2, 2
		)
		gprint(
			'before you freeze to death.',
			-185,10, 0, 2, 2
		)
		
		-->> Next scene
		world.transition(frame)
		
	elseif scene == 3 then
		-- Intro 2 --
		color(1,1,1, frame % 400 / 600)
		gprint(
			'The life encompassing you...',
			-175,-20, 0, 2, 2
		)
		
		-->> Next scene
		world.transition(frame)
		
	elseif scene == 4 then
		-- Intro 1 --
		color(1,1,1, frame % 400 / 600)
		gprint(
			'The rivers, the lakes, the snow, the Earth...',
			-260,-20, 0, 2, 2
		)
		gprint(
			'the mediums that connect us all as one...',
			-250,10, 0, 2, 2
		)
		
		-->> Next scene
		world.transition(frame)
		
	elseif scene == -1 then
		-- Loss screen --
		color(1,1,1,1)
		gprint(
			'The cold claims your soul.',
			-250,-20, 0, 3, 3
		)
		gprint(
			'Game over',
			-100,20, 0, 3, 3
		)
		
		if mouseDown(1) then love.event.push('quit', 'restart') end
		
	elseif scene == -2 then
		-- Win screen --
		color(1,1,1,1)
		gprint(
			'You welcome a warm sleep...',
			-250,-20, 0, 3, 3
		)
		gprint(
			'You win',
			-100,20, 0, 3, 3
		)
		
		if mouseDown(1) then love.event.push('quit', 'restart') end
	end
	
	-->> Reset camera
	origin()
	
	-->> Draw indicators >>--
	if mouseDown(1) then
		color(1,1,1,1)
		local x, y = mousePos()
		line(x - 6, y, x + 6, y)
		
	elseif mouseDown(2) then
		color(1,1,1,1)
		local x, y = mousePos()
		circle('fill', x, y, 4)
	end
end
