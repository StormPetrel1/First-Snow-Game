
--== Function caches ==--
local newImage = love.graphics.newImage
local sub = string.sub

--== Packages ==--
local sprite = {}

-->> Get image objects from files >>--
for _, spriteName in ipairs(love.filesystem.getDirectoryItems 'image') do
	-- Remove .png postfix
	sprite[sub(spriteName, 1, -5)] = newImage('image/' .. spriteName)
end

-->>
return sprite
