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
	local xCoord = width/2 + radius*math.cos(number*minuteAngle - math.pi/2)
	local yCoord = height/2 + radius*math.sin(number*minuteAngle - math.pi/2)
	love.graphics.circle( fillstring, round(xCoord), round(yCoord), 2.6, 100 )
end

function drawSecondCircle( seconds, radius )
	local x = width/2
	local y = height/2
	love.graphics.arc( "line", x, y, radius, -math.pi/2, seconds*minuteAngle - math.pi/2, 100 )
	helpers.saveColor()
	love.graphics.setColor( 0, 0, 0 )
	love.graphics.circle( "fill", x, y, radius - 1, 100 )
	helpers.resetColor()
end

function drawMinuteCircles( minutes, radius )
	--draw filled circle for each minute
	for i=0, minutes do
		drawCircle( i, radius, true )
	end
	
	--draw empty circles for the remaining hour
	for i=(minutes+1), 59 do
		drawCircle( i, radius, false )
	end
end

function drawHourHand( hours, innerRadius, outerRadius )
	local leftAngle = minuteAngle*5*hours - minuteAngle/2
	local rightAngle = minuteAngle*5*hours + minuteAngle/2
	local innerLeft = {
		x = width/2 + innerRadius*math.cos( leftAngle ),
		y = height/2 + innerRadius*math.sin( leftAngle )
	}
	local innerRight = {
		x = width/2 + innerRadius*math.cos( rightAngle ),
		y = height/2 + innerRadius*math.sin( rightAngle )
	}
	local outerLeft = {
		x = width/2 + outerRadius*math.cos( leftAngle ),
		y = height/2 + outerRadius*math.sin( leftAngle )
	}
	local outerRight = {
		x = width/2 + outerRadius*math.cos( rightAngle ),
		y = height/2 + outerRadius*math.sin( rightAngle )
	}

	love.graphics.point( innerLeft.x, innerLeft.y )
	love.graphics.point( innerRight.x, innerRight.y )
	love.graphics.point( outerLeft.x, outerLeft.y )
	love.graphics.point( outerRight.x, outerRight.y )
	love.graphics.polygon( "fill", innerLeft.x, innerLeft.y, innerRight.x, innerRight.y, outerRight.x, outerRight.y, outerLeft.x, outerLeft.y ) 
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

	--angle of one minute on the clock
	minuteAngle = math.pi/30

	helpers = require "helpers"
end

function love.draw()
	local innerRadius = (width-5)/2 - 18
	local middleRadius = (width-5)/2 - 8
	local outerRadius = (width-5)/2
	for i=0, 59, 5 do
		drawCircle( i, outerRadius, true )
	end
	drawSecondCircle( currentSecond, innerRadius )
	drawMinuteCircles( currentMinute, middleRadius )
	drawHourHand( currentHour, middleRadius-5, outerRadius+5 )
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
