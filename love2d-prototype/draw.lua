--module containing some drawing funtions
draw = {}

function draw.pixel( x, y )
	love.graphics.point( x+0.5, y+0.5 )
end

return draw
