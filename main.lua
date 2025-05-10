
--== Require files ==--
local bit = require 'bit'

--== Cache functions ==--
local rawget = rawget
local rawset = rawset
local lshift = bit.lshift
local floor = math.floor
local random = math.random
local push = table.insert
local pop = table.remove

--== Pure ==--
-- Logic --
do
	--== Constants ==--
	local lookup = {
		[false] = 0,
		[true] = 0,
	}
	
	--== Pure ==--
	function options(bool, falseVal, trueVal)
		lookup[false] = falseVal
		lookup[true] = trueVal
		return lookup[bool]
	end
end

-- Math --
function dist(x, y)
	return (x * x + y * y)^0.5
end

function normalize(x, y)
	local l = (x * x + y * y)^0.5
	return x/l, y/l, l
end

function randomSign()
	return lshift(floor(random() + 0.5), 1) - 1
end

function round(n)
	return floor(n + 0.5)
end

do
	--== Constants ==--
	local lookup = {
		[false] = 1,
		[true] = -1,
	}
	
	--== Pure ==--
	function sign(n)
		-->> Early exit for zero sign
		if n == 0 then return 0 end
		
		return lookup[n < 0]
	end
	
	function signx0(n)
		return lookup[n < 0]
	end
end

-- Table --
function search(tbl, target)
	for i = 1, #tbl do
		if tbl[i] == target then
			return i
		end
	end
	
	return -1
end

-- Type conversion --
do
	--== Constants ==--
	local lookup = {
		[false] = 0,
		[true] = 1,
	}
	
	--== Pure ==--
	function boolNum(b)
		return lookup[b]
	end
end

-- Environment --
--== Messages ==--
function exists(name)
	return rawget(_G, name) ~= nil
end

--== Mutations ==--
function global(name, value)
	rawset(_G, name, value or 0)
end

-- Table --
function shuffleAt(tbl, idx)
	local val = tbl[idx]
	
	-->> Replace index >>--
	local n = #tbl
	tbl[idx] = tbl[n]
	tbl[n] = nil
	
	return val
end

function shuffleFirst(tbl)
	push(tbl, pop(tbl, 1))
end

function shuffleLast(tbl)
	push(tbl, 1, pop(tbl))
end

-->> Secure globals >>--
do
	--== Mutations ==--
	local function errorGlobal(_, name)
		error('attempt to access undeclared variable: ' .. name, 2)
	end
	
	-->> Fix global metatable >>--
	setmetatable(_G, {
		__metatable = 'secure',
		__index = errorGlobal,
		__newindex = errorGlobal,
	})
end

-->> Collect garbage >>--
love.handlers = nil

--== File caches ==--
-- Load game
love.run = require 'run'
