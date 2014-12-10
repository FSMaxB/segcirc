--First prototype of my own pebble watchface, to test out the basic program structure
--( therefore I shouldn't use programming constructs that aren't available in C )

function round( number )
	return math.floor( number + 0.5 )
end

function drawCircles( number, radius, fillmode )
	local fillstring = "line"
	if fillmode then
		fillstring = "fill"
	end
	local xCoord = width/2 + radius*math.cos(number*math.pi/30)
	local yCoord = height/2 + radius*math.sin(number*math.pi/30)
	love.graphics.circle( fillstring, round(xCoord), round(yCoord), 2.6, 100 )
end

function love.load()
	--helper variables for timer callbacks
	--contain the last time the specific callbacks got triggered
	lastSecond = love.timer.getTime()
	lastMinute = love.timer.getTime()
	lastHour = love.timer.getTime();


	height = love.window.getHeight()
	width = love.window.getWidth()
end

function love.draw()
	for i=0, 59, 5 do
		drawCircles( i, (width-5)/2, true )
	end
	for i=0, 59 do
		drawCircles( i, (width-5)/2 - 8, false )
	end
end

function love.keypressed( key )
	if key == "q" then
		love.event.quit()
	end
end

function everySecond()
	print( "second" )
end

function everyMinute()
	print( "minute" )
end

function everyHour()
	print( "hour" )
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