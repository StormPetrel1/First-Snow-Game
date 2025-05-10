
--== File caches ==--
local ent = require 'ent'
local spec = require 'spec'
local world = require 'world'

--== Function caches ==--
local cameraToWorld = spec.cameraToWorld
local setHint = world.setHint

--== Constant caches ==--
local player = ent.player
local wood = ent.wood
local tree = ent.tree

--== Packages ==--
local handler = {
	--== Pure ==--
	quit = function()
		return true
	end,
	
	--== Mutations ==--
	keypressed = function(key)
		if key == 'q' then
			-->> Rotate wood >>--
			local id = player.getHolding()
			if id > 0 then
				wood.turn(id)
			end
			
		elseif key == 'e' then
			-->> Use match >>--
			local id = player.getHolding()
			if id > 0 and player.useMatch() then
				wood.light(id)
			else
				setHint 'No matches/wood'
			end
		end
	end,
	
	mousepressed = function(x, y, button)
		if button == 1 then
			-->> Use axe >>--
			local worldX, worldY = cameraToWorld(x, y)
			local id = tree.detectCollisionAt(worldX, worldY)
			if id > 0 then
				tree.cutAt(id, worldY)
			end
			
		elseif button == 2 then
			-->> Grab wood >>--
			local worldX, worldY = cameraToWorld(x, y)
			local id = wood.detectCollisionAt(worldX, worldY)
			player.pickupWood(id)
		end
	end,
}

-->>
return handler
