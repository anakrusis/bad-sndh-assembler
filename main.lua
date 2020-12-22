-- Bad .SNDH Assembler by amelia fafafafafafafafafafafafafa
-- i hope this is well commented enough! im coming back to it after abandoning it for a month and it seems pretty legible still...

function love.load()

	assemble("bad-sndh-assembler/main.asm")

end

function assemble(path)

	print("Assembling " .. path)
	file = io.open (path, "r")
	
	-- a table of byte arrays, each array corresponding to a line of assembly
	output_lines = {};
	
	-- a pair of parallel indexes
	label_names = {};
	label_values = {};
	
	-- keeps track of how many bytes each line corresponds to, for calculating the value of each label
	bytes_per_line = {};
	
	-- FIRST PASS
	i = 1
	line = 1
	while line ~= nil do
		line = file:read "*line"
		if line == nil then break end
		
		output_lines[i] = parse_line(line, i);
		bytes_per_line[i] = #output_lines[i];
		i = i + 1;
	end
	
	-- TODO SECOND PASS (branches are given proper offsets based on the labels)
	
	
	
	-- FINAL WRITE TO SNDH
	
	outputfile = io.open("file.sndh", "wb")
	for i = 1, #output_lines do
	
		for j = 1, #output_lines[i] do
		
			local str = string.char( output_lines[i][j] )
			outputfile:write(str)
			
		end
	end
	outputfile:close()
end

-- returns an array of bytes to be written directly to the file

function parse_line(line, line_number)
	
	-- the byte array, empty for now
	output = {};
	
	line = string.upper(line) -- so that, for example, RTS and rts both work
	line = trim_line(line)
	print(line)
	
	-- the first part of the label jumping system is finding labels which are the only thing in this assembly dialect to use colons
	-- if a label is found then its name is added to the list of labels.
	colonindex = string.find(line, ":")
	if colonindex ~= nil then
		
		labelstring = line:sub(1, colonindex-1)
		
		table.insert(label_names, labelstring);
		
		-- now the byte address of the label is calculated here. starts at zero and counts all the bytes before it.
		labeladdr = 0
		for i = 1, #bytes_per_line do
			
			labeladdr = labeladdr + bytes_per_line[i]
		
		end
		
		print("Label found " .. labelstring .. " at address " .. labeladdr );
		
		-- bypasses everything else, returns an empty table. the label doesnt correspond to any hex code.
		return output;
	end
	
	if line:sub(1,3) == "RTS" then -- RTS in hex: 4375
		table.insert(output, 0x43)
		table.insert(output, 0x75)
		
	elseif line:sub(1,3) == ".DB" then
		output = parse_db(line);
	
	elseif line:sub(1,2) == "LD" then
		output = parse_ldx(line);
		
	elseif line:sub(1,3) == "BRA" then
		table.insert(output, 0x60)
		table.insert(output, 0x00)
		table.insert(output, 0x00)
		table.insert(output, 0x00)
		
		-- TODO second pass will replace the branch of 0000 with the proper amount
	end
	
	hexline = ""
	for i = 1, #output do
		hexline = hexline .. string.format("%02x", output[i])
	end

	print(hexline .. "\n")
	
	return output
end

-- functions like parse_line but specialised for LDx instructions

function parse_ldx( line ) 
	
	output = {}
	table.insert(output, 0x70) -- fixed for the ldx function for now
	
	-- for now just immediate loading
	num_start_index = string.find(line, "%$") -- <- dollar sign is a "magic char" in lua so we must use % to escape it(!!)
	numstring = line:sub(num_start_index+1)
	
	print(numstring)
	
	num = tonumber(numstring, 16)
	
	table.insert(output, num)
	return output

end

-- gets rid of the junk before and after
function trim_line( line )

	-- finding the first non-space non-tab character (this is so you can indent your code!)	
	instr_start_index = 0;
	for i = 1, #line do
		current_char = line:sub(i,i);
		
		if current_char ~= "	" and current_char ~= " " and current_char ~= "\n" then
		
			instr_start_index = i;
			break;
			
		end
	end
	
	if instr_start_index == 0 then return line end -- blank lines ignored
	-- instruction begins here
	line = line:sub(instr_start_index);
	
	-- finding the first semicolon (the comment character in our assembly dialect) and ignoring all that cometh afterwards
	colon_start_index = string.find(line, ";")
	if colon_start_index ~= nil then
		line = line:sub(0, colon_start_index - 1);
	end
	
	return line
end

-- raw data to be dumped into the file!
function parse_db( line )
	output = {}
	
	-- dollar sign indicates the hex digits (this could be expanded to do other types of data too like binary '%' and strings? "'")
	next_dolla_index = 0;
	while next_dolla_index ~= nil do
	
		next_dolla_index = string.find(line, "%$");
		if next_dolla_index == nil then return output end
		
		line = line:sub(next_dolla_index + 1)
		
		-- the numerical data is sandwiched between the dolla and the comma
		-- (or if there is no comma, then it's the last item defo)
		next_comma_index = string.find(line, ",");
		if next_comma_index == nil then
			numstring = line
		else
			numstring = line:sub(0, next_comma_index - 1)
		end
		print(numstring)
		
		num = tonumber(numstring, 16)
		table.insert(output, num)
	
	end
	
	return output
end