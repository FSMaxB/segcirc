helpers = {} 

helpers.color = {}

--table to save all fonts in
helpers.font = {
	setFont =
		function( filename )
			helpers.font.filename = filename
			for index, value in pairs(helpers.font.fontTable) do
				helpers.font.fontTable[index] = love.graphics.newFont( filename, index )
			end
		end,
	setFontSize =
		function( size )
			if helpers.font.fontTable[size] == nil then
				if helpers.font.filename == nil then
					helpers.font.fontTable[size] = love.graphics.newFont( size )
				else
					helpers.font.fontTable[size] = love.graphics.newFont( helpers.font.filename, size )
				end
			end

			love.graphics.setFont( helpers.font.fontTable[size] )
		end,
	getWidth =
		function( text, size )
			if helpers.font.fontTable[size] == nil then
				if helpers.font.filename == nil then
					helpser.font.fontTable[size] = love.graphics.newFont( size )
				else
					helpers.font.fontTable[size] = love.graphics.newFont( helpers.font.filename, size )
				end
			end

			return helpers.font.fontTable[size]:getWidth( text )
		end,
	getHeight =
		function( size )
			if helpers.font.fontTable[size] == nil then
				if helpers.font.filename == nil then
					helpers.font.fontTable[size] = love.graphics.newFont( size )
				else
					helpers.font.fontTable[size] = love.graphics.newFont( helpers.font.filename, size )
				end
			end

			return helpers.font.fontTable[size]:getHeight()
		end,
	fontTable = {}
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
