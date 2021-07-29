# subModSearcher
Searcher for nested lua modules
This module makes searching for nested modules cleaner for complex search paths.

For example if the search path is a/b/?/c/?.lua
The the normal search for module mod.submod searches this path:
a/b/mod/submod/c/mod/submod.lua			-- This does not comply with good hierarchical representation of mod module

After this searcher is included it will also search for the module in the path:

a/b/mod/c/mod/submod.lua

It will also search the alternative path:
a/b/mod/c/submod.lua

For mod.subMod.subMod1 it will search:
a/b/mod/c/mod/subMod/subMod1.lua

It will also search the alternative path:
a/b/mod/c/submod/submod1.lua

Same for the C modules

