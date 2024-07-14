build_options = {} -- populated by builder.exe with the command line args.

local TF = { BC1 = 0, BC2 = 1, BC3 = 2, PVRTC_4BPP_RGBA = 3, PVRTC_4BPP_RGB = 4, PVRTC_2BPP_RGBA = 5, PVRTC_2BPP_RGB = 6, RGBA8 = 7, BGRA8 = 8 }
local AtlasStyle = { Decreasing = 0, Increasing = 1, Random = 2 }

local MaxPackageSize = 1024 * 1024 * 1024	--bytes
local MaxTextureWidth = 4096 --2048
local MaxTextureHeight = 4096 --2048

function CreateOptionsTBL( textureformat, quality, premul, underpaint, mipmap )
	local tbl =
	{
		platform = build_options.platform,			--used internally
		quality = quality,							--not used
		premul = premul,							--controls if we pre-multiply by the alpha channel
		underpaint = underpaint and not premul,		--controls if we underpaint around alpha edges, disabled if pre-multiplying is enabled
		genmipmap = mipmap,							--generate mipmaps
		textureformat = textureformat,				--texture format when atlas not created
		twidth = MaxTextureWidth,					--max texture width when not atlasing (any texture larger will be shrunk)
		theight = MaxTextureHeight,					--max texture height when not atlasing
		--debug_atlas = "c:/atlases",				--currently not implemented as of going to nvtt for BC[N] compression
	}
	return tbl
end

function PackageFolder( package, path, recursive )
	local filepaths = {}
	package:ListFiles( path, filepaths, recursive )
	for _,srcpath in ipairs( filepaths ) do
		dstpath = srcpath
		package:LoadResource( srcpath, dstpath )
	end
	return package
end

function PackageExample()
	--Setup the options for this kwad, RGBA8
	local options = CreateOptionsTBL( TF.RGBA8, 1.0, true, true, false )
	
	local package = Package:new( "gui", MaxPackageSize, options )

	--Create an atlaser for this kwad, 4k textures with BC3 compression, this overrides the RGBA8 format above as ALL textures get atlased.
	--atlas is optional
	package:CreateAtlas( TF.BC3, 4096, 4096, AtlasStyle.Increasing ) --BC3 (DXT5) 4kx4k texture atlased using the Increasing size rule (max DIM is 16kx16k)
	

	--Add some folders to the kwad
	PackageFolder( package, "./gui", true )
	--PackageFolder( package, "./more_stuff", true ) --put another folder into the kwad

	package:Save( build_options.outputpath, "gui.kwad" )
end


function run( )
	PackageExample()
end