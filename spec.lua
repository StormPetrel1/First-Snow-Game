
--== File caches ==--
local bit = require 'bit'

--== Function caches ==--
local rshift = bit.rshift
local transformGraphics = love.graphics.applyTransform
local getDim = love.graphics.getDimensions
local newTransform = love.math.newTransform
local floor = math.floor

--== Temp ==--
local targetFPS = 60
local targetWidth = 1024

--== Packages ==--
local spec = {
	--== Constants ==--
	targetDT = 1 / targetFPS,
}

do
	--== Constants ==--
	local targetPixelRatio = 1 / targetWidth
	
	--== Data ==--
	local camera = newTransform()
	
	--== Messages ==--
	function spec.cameraToWorld(x, y)
		return camera:inverseTransformPoint(x, y)
	end
	
	function spec.uiDim()
		--== Temp ==--
		local w, h = getDim()
		local scale = w * targetPixelRatio
		
		-->>
		return rshift(w / scale, 1), rshift(h / scale, 1)
	end
	
	--== Mutations ==--
	function spec.updateCamera(playerX, playerY)
		--== Temp ==--
		local w, h = getDim()
		local scale = w * targetPixelRatio
		
		-->> Transform window >>--
		transformGraphics(
			camera:setTransformation(
				rshift(w, 1),
				rshift(h, 1),
				0,
				scale,
				scale,
				playerX,
				playerY
			)
		)
	end
	
	function spec.setUICamera()
		--== Temp ==--
		local w, h = getDim()
		local scale = w * targetPixelRatio
		
		-->> Transform window >>--
		transformGraphics(
			newTransform(
				rshift(w, 1),
				rshift(h, 1),
				0,
				scale,
				scale
			)
		)
	end
end

-->>
return spec
