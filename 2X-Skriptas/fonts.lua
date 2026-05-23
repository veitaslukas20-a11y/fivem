local AddonFonts = {
    {"RobotoRegular", "Roboto"},  
}

function CreateFonts()
	for k,v in pairs(AddonFonts) do
		RegisterFontFile(v[1])
		local Id = RegisterFontId(v[2])
		print(v[2] .. ' | ' .. Id)
	end
end