
--== File caches ==--
local ent = require 'ent'
local world = require 'world'

--== Function caches ==--
local ipairs = ipairs
local pairs = pairs
local checkTent = world.checkTent
local setHint = world.setHint
local updateHint = world.updateHint

--== Constant caches ==--
local player = ent.player

-->>
return function(frame)
	-->> Update hint
	updateHint()
	
	-->> Check for low temp >>--
	local playerTemp = player.getTemp()
	if playerTemp < 30 then
		setHint 'The cold overtakes your body...'
		
		-->> Check for loss >>--
		if playerTemp < 0 then world.lose() end
	end
	
	-->> Check for win condition >>--
	checkTent(player.getPos())
	
	-->> Update entities >>--
	for _, entType in pairs(ent) do
		for _, fn in ipairs(entType) do
			fn()
		end
	end
end
