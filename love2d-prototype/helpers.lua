helpers = {} 

helpers.color = {}

--table to save all fonts in
helpers.font = {
	setFont =
		function( size )
			if helpers.font[size] == nil then
				helpers.font[size] = love.graphics.newFont( size )
			end

			love.graphics.setFont( helpers.font[size] )
		end,
	getWidth =
		function( text, size )
			if helpers.font[size] == nil then
				helpers.font[size] = love.graphics.newFont( size )
			end

			return helpers.font[size]:getWidth( text )
		end,
	getHeight =
		function( size )
			if helpers.font[size] == nil then
				helpers.font[size] = love.graphics.newFont( size )
			end

			return helpers.font[size]:getHeight()
		end
}


--copies a table
helpers.copyTable = 
	function( table )
		copy = {}
		for key, value in pairs( table ) do
			if type( value ) == "table" then
				copy[key] = helpers.copyTable( value )
			else
				copy[key] = value
			end
		end
		return copy
	end

--prints data structures recursively
helpers.recursivePrint =
	function( table, prefix )
		if prefix == nil then
			prefix = ""
		end

		for key, value in pairs( table ) do
			print( prefix .. "." .. key, "=", value )
			if type( value ) == "table" then
				helpers.recursivePrint( value, prefix .. "." .. key )
			end
		end
	end

helpers.saveColor = 
	function()
		helpers.color.r, helpers.color.g, helpers.color.b = love.graphics.getColor()
	end

helpers.resetColor =
	function()
		love.graphics.setColor( helpers.color.r, helpers.color.g, helpers.color.b )
	end

return helpers
