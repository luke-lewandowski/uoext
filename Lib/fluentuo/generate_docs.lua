arg = {
	"-d", "./docs",
	"--taglet", "luadoc.taglet.openeuo",
	"--nofiles",
	"FluentUO.lua"
}

dofile('./docs/openeuo.taglet.lua')
dofile('./docs/luadoc_start.lua')
