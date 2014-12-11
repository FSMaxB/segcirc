--First prototype of my own pebble watchface, to test out the basic program structure
--( therefore I shouldn't use programming constructs that aren't available in C )

function round( number )
	return math.floor( number + 0.5 )
end

function drawCircle( number, radius, fillmode )
	local fillstring = "line"
	if fillmode then
		fillstring = "fill"
	end
	local xCoord = width/2 + radius*math.cos(number*math.pi/30 - math.pi/2)
	local yCoord = height/2 + radius*math.sin(number*math.pi/30 - math.pi/2)
	love.graphics.circle( fillstring, round(xCoord), round(yCoord), 2.6, 100 )
end

function drawSecondCircle( seconds )
	local x = width/2
	local y = height/2
	local radius = (width-5)/2 - 16
	love.graphics.arc( "line", x, y, radius, -math.pi/2, seconds*math.pi/30 - math.pi/2, 100 )
	helpers.saveColor()
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.circle( "fill", x, y, radius - 1, 100 )
	helpers.resetColor()
end

function drawMinuteCircles( minutes )
	--draw filled circle for each minute
	for i=0, minutes do
		drawCircle( i, (width-5)/2 - 8, true )
	end
	
	--draw empty circles for the remaining hour
	for i=(minutes+1), 59 do
		drawCircle( i, (width-5)/2 - 8, false )
	end
end

--create two digit string from number
function getNumString( number )
	if number < 10 then
		return "0" .. tostring(number)
	end
	return tostring( number )
end

function drawTimeText( hours, minutes, seconds )
	local timeString = getNumString( hours ) .. ":" .. getNumString( minutes )
	local fontSize = 30
	helpers.font.setFont( fontSize )
	local textHeight = helpers.font.getHeight( fontSize )
	local textWidth = helpers.font.getWidth( timeString, fontSize )
	love.graphics.print( timeString, width/2 - textWidth/2, height/2 - textHeight/2 )
end

function love.load()
	--helper variables for timer callbacks
	--contain the last time the specific callbacks got triggered
	local now = love.timer.getTime()
	lastSecond = now
	lastMinute = now
	lastHour = now

	--current time
	currentSecond = 0
	currentMinute = 0
	currentHour = 0

	height = love.window.getHeight()
	width = love.window.getWidth()

	helpers = require "helpers"
end

function love.draw()
	for i=0, 59, 5 do
		drawCircle( i, (width-5)/2, true )
	end
	drawSecondCircle( currentSecond )
	drawMinuteCircles( currentMinute )
	drawTimeText( currentHour, currentMinute, currentSecond )
end

function love.keypressed( key )
	if key == "q" then
		love.event.quit()
	end

	if key == "s" then
		currentSecond = (currentSecond + 1) % 60
	end

	if key == "m" then
		currentMinute = (currentMinute + 1) % 60
	end
	
	if key == "h" then
		currentHour = (currentHour + 1) % 12
	end
end

function everySecond()
	currentSecond = ( currentSecond + 1 ) % 60
	print( currentSecond, " second(s)" )
end

function everyMinute()
	currentMinute = ( currentMinute + 1 ) % 60
	print( currentMinute, " minute(s)" )
end

function everyHour()
	currentHour = ( currentHour + 1 ) % 12
	print( currentHour, " hour(s)" )
end

function love.update( dt )
	local now = love.timer.getTime()

	if (now + 1) >= lastSecond then
		everySecond()
		lastSecond = lastSecond + 1
	end

	if (now + 60 ) >= lastMinute then
		everyMinute()
		lastMinute = lastMinute + 60
	end

	if (now + 3600) >= lastHour then
		everyHour()
		lastHour = lastHour + 3600
	end
end
