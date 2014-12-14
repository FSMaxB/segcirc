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
	local leftAngle = minuteAngle*5*hours - minuteAngle/2 - math.pi/2
	local rightAngle = minuteAngle*5*hours + minuteAngle/2 - math.pi/2
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

	love.graphics.polygon( "fill", innerLeft.x, innerLeft.y, innerRight.x, innerRight.y, outerRight.x, outerRight.y, outerLeft.x, outerLeft.y ) 
end

--create two digit string from number
function getNumString( number )
	if number < 10 then
		return "0" .. tostring(number)
	end
	return tostring( number )
end

function drawTimeText( )
	if hours == 0 then
		hours = 12
	end
	local timeString = getNumString( currentDate.hour ) .. ":" .. getNumString( currentDate.min )
	local fontSize = 30
	helpers.font.setFont( fontSize )
	local textHeight = helpers.font.getHeight( fontSize )
	local textWidth = helpers.font.getWidth( timeString, fontSize )
	love.graphics.print( timeString, width/2 - textWidth/2, height/2 - textHeight/2 )
end

function drawDate()
	local dateString = getNumString( currentDate.day ) .. "."
		.. getNumString( currentDate.month ) .. "."
		.. tostring(currentDate.year)
	local fontSize = 12
	helpers.font.setFont( fontSize )
	local textHeight = helpers.font.getHeight( fontSize )
	local textWidth = helpers.font.getWidth( dateString, fontSize )
	local yPos = height/2 + helpers.font.getHeight(30)/2 
	love.graphics.print( dateString, width/2 - textWidth/2, yPos )
end

function drawWeekday()
	local dayString = weekdays[currentDate.wday]
	local fontSize = 17
	helpers.font.setFont( fontSize )
	local textHeight = helpers.font.getHeight( fontSize )
	local textWidth = helpers.font.getWidth( dayString, fontSize )
	local yPos = height/2 - helpers.font.getHeight(30)/2 - textHeight - 3
	love.graphics.print( dayString, width/2 - textWidth/2, yPos )
end

function love.load()
	--current time
	currentDate = os.date( "*t", os.time() )
	currentSecond = currentDate.sec
	currentMinute = currentDate.min 
	currentHour = currentDate.hour 

	--helper variables for timer callbacks
	--contain the last time the specific callbacks got triggered
	lastSecond = currentSecond
	lastMinute = currentMinute
	lastHour = currentMinute

	--offset ( to test clock )
	secondOffset = 0
	minuteOffset = 0
	hourOffset = 0

	height = love.window.getHeight()
	width = love.window.getWidth()

	weekdays = {
		[1] = "So",
		[2] = "Mo",
		[3] = "Di",
		[4] = "Mi",
		[5] = "Do",
		[6] = "Fr",
		[7] = "Sa"
	}

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
	drawTimeText( )
	drawDate()
	drawWeekday()
end

function love.keypressed( key )
	if key == "q" then
		love.event.quit()
	end

	if key == "s" then
		secondOffset = (secondOffset + 1) % 60
		print( "second offset:", secondOffset )
		everySecond()
	end

	if key == "m" then
		minuteOffset = (minuteOffset + 1) % 60
		print( "minute offset:", minuteOffset )
		everyMinute()
	end
	
	if key == "h" then
		hourOffset = (hourOffset + 1) % 12
		print( "hour offset:", hourOffset )
		everyHour()
	end
end

function everySecond()
	currentSecond = ( currentDate.sec + secondOffset ) % 60
end

function everyMinute()
	currentMinute = ( currentDate.min + minuteOffset ) % 60
end

function everyHour()
	currentHour = ( currentDate.hour + hourOffset ) % 12
end

function love.update( dt )
	currentDate = os.date( "*t", os.time() )

	if not (currentDate.sec == lastSecond) then
		everySecond()
		lastSecond = currentDate.sec
	end

	if not (currentDate.min == lastMinute) then
		everyMinute()
		lastMinute = currentDate.min
	end

	if not (currentDate.hour == lastHour) then
		everyHour()
		lastHour = currentDate.hour
	end
end
