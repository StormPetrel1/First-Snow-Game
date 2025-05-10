
-- Load all Love2D dependencies AFTER this function is called by Love2D
-- Each data file does its own initialization

-->>
return function()
	--== File caches ==--
	local draw = require 'draw'
	local handler = require 'handler'
	local spec = require 'spec'
	local update = require 'update'
	
	--== Function caches ==--
	local poll = love.event.poll
	local pump = love.event.pump
	local clear = love.graphics.clear
	local getColor = love.graphics.getBackgroundColor
	local isActive = love.graphics.isActive
	local origin = love.graphics.origin
	local present = love.graphics.present
	local pause = love.timer.sleep
	local step = love.timer.step
	local uiDim = spec.uiDim
	
	--== Constant caches ==--
	local targetDT = spec.targetDT
	
	--== Data ==--
	local frame = 0
	local sleep = 0
	
	-->> Play theme infinitely >>--
	local theme = love.audio.newSource('theme.mp3', 'stream')
	theme:setLooping(true)
	theme:play()
	
	-->> Set background color
	love.graphics.setBackgroundColor(0.025, 0.05, 0.15)
	
	-->> Speed up line drawing
	love.graphics.setLineStyle 'rough'
	
	-->> Increase point size
	love.graphics.setPointSize(2)
	
	-->> Ignore startup times
	step()
	
	-->> Return main loop >>--
	return function()
		-->> Process events
		pump()
		
		-->> Pass event data to handler >>--
		-- Iterator is not cached because poll's implementation is unknown
		for name, a,b,c,d,e,f in poll() do
			-->> Return exit status if event function returns true >>--
			local event = handler[name]
			if event and event(a,b,c,d,e,f) then
				return a or 0
			end
		end
		
		-->> Count frames
		frame = frame + 1
		
		-->> Update
		update(frame)
		
		if isActive() then
			-->> Reset graphics state >>--
			clear(getColor())
			origin()
			
			-->> Draw >>--
			draw(frame, uiDim())
			present()
		end
		
		-->> Limit FPS >>--
		sleep = sleep + targetDT - step()
		pause(sleep)
	end
end
