
-- Default options are commented out

function love.conf(t)
	t.appendidentity = true
	t.version = '11.5'
	t.accelerometerjoystick = false
	t.gammacorrect = true
	
	t.window.title = 'First Snow'
	t.window.icon = 'icon.png'
	t.window.width = 0
	t.window.height = 0
	--t.window.minwidth = 1
	--t.window.minheight = 1
	t.window.resizable = true
	t.window.vsync = 0
	
	--t.modules.audio = true
	--t.modules.event = true
	--t.modules.font = true
	--t.modules.graphics = true
	--t.modules.image = true
	t.modules.joystick = false
	--t.modules.keyboard = true
	--t.modules.math = true
	--t.modules.mouse = true
	t.modules.physics = false
	--t.modules.sound = true
	t.modules.system = false
	t.modules.thread = false
	--t.modules.timer = true
	t.modules.touch = false
	t.modules.video = false
	--t.modules.window = true
end
