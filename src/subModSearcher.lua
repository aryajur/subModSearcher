--[[
The MIT License (MIT)
Copyright (c) 2016, Milind Gupta

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
--[[
	Searcher for nested lua modules
	This module makes searching for nested modules cleaner for complex search paths.

	For example is the search path is a/b/?/c/?.lua
	The the normal search for module mod.submod searches this path:
	a/b/mod/submod/c/mod/submod.lua			-- This does not comply with good hierarchical representation of mod module
	
	After this searcher is included it will also search for the module in the path:
	
	a/b/mod/c/mod/submod.lua
	
	For mod.subMod.subMod1 it will search:
	a/b/mod/c/mod/subMod/subMod1.lua
	
	Same for the C modules

]]
package.searchers[#package.searchers + 1] = function(mod)
	-- Check if this is a multi hierarchy module
	if mod:find(".",1,true) then
		-- Get the top most name 
		local totErr = ""
		local top = mod:sub(1,mod:find(".",1,true)-1)
		local sep = package.config:match("(.-)%s")
		local delim = package.config:match(".-%s+(.-)%s")
		local subst = mod:gsub("%.",sep)			-- The whole module name separated by the system separator instead of dots
		local subst1 = mod:match("^.-%.(.+)$"):gsub("%.",sep)	-- The subsequent names separated by the system separator instead of dots
		--print("subst1="..subst1)
		-- Now loop through all the lua module paths
		for path in package.path:gmatch("(.-)"..delim) do
			local pathBac = path
			-- Substitute the last question mark with subst and all before with top
			local _,num = path:gsub("%?","")
			path = path:gsub("%?",top,num-1)
			path = path:gsub("%?",subst)
			--print("Search at..."..path)
			-- try loading this file
			local f,err = loadfile(path)
			if not f then
				totErr = totErr.."\n\tno file '"..path.."'"
			else
				--print("FOUND")
				return f
			end
			
			-- Now try with subst1
			path = pathBac
			_,num = path:gsub("%?","")
			path = path:gsub("%?",top,num-1)
			path = path:gsub("%?",subst1)
			--print("Alternate Search at..."..path)
			-- try loading this file
			local f,err = loadfile(path)
			if not f then
				totErr = totErr.."\n\tno file '"..path.."'"
			else
				--print("FOUND")
				return f
			end
		end
		return totErr
	end	
end

-- Searcher for nested dynamic libraries
package.searchers[#package.searchers + 1] = function(mod)
	-- Check if this is a multi hierarchy module
	if mod:find(".",1,true) then
		-- Get the top most name 
		local totErr = ""
		local top = mod:sub(1,mod:find(".",1,true)-1)
		local sep = package.config:match("(.-)%s")
		local delim = package.config:match(".-%s+(.-)%s")
		local subst = mod:gsub("%.",sep)
		local subst1 = mod:match("^.-%.(.+)$"):gsub("%.",sep)
		--print("subst1="..subst1,"subst="..subst)
		-- Now loop through all the lua module paths
		for path in package.cpath:gmatch("(.-)"..delim) do
			local pathBac = path
			local _,num = path:gsub("%?","")
			path = path:gsub("%?",top,num-1)
			path = path:gsub("%?",subst)
			--print("Search at..."..path)
			-- try loading this file
			--print(path)
			local f,err = package.loadlib(path,"luaopen_"..mod:gsub("%.","_"))
			if not f then
				totErr = totErr.."\n\tno file '"..path.."'"
			else
				--print("FOUND")
				return f
			end
			
			-- Now try with subst1
			path = pathBac
			_,num = path:gsub("%?","")
			path = path:gsub("%?",top,num-1)
			path = path:gsub("%?",subst1)
			--print("Alternate Search at..."..path)
			-- try loading this file
			--print(path)
			local f,err = package.loadlib(path,"luaopen_"..mod:gsub("%.","_"))
			if not f then
				totErr = totErr.."\n\tno file '"..path.."'"
			else
				--print("FOUND")
				return f
			end
		end
		return totErr
	end	
end