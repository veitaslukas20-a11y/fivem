Character_ESX = {}

local Components = {
	{name = 'tshirt_1',			value = 0,		min = 0,    componentId	= 8},
	{name = 'tshirt_2',			value = 0,		min = 0,    textureof	= 'tshirt_1'},
	{name = 'torso_1',			value = 0,		min = 0,    componentId	= 11},
	{name = 'torso_2',			value = 0,		min = 0,	textureof	= 'torso_1'},
	{name = 'decals_1',			value = 0,		min = 0,	componentId	= 10},
	{name = 'decals_2',			value = 0,		min = 0,	textureof	= 'decals_1'},
	{name = 'arms',				value = 0,		min = 0},
	{name = 'arms_2',			value = 0,		min = 0},
	{name = 'pants_1',			value = 0,		min = 0,	componentId	= 4},
	{name = 'pants_2',			value = 0,		min = 0,	textureof	= 'pants_1'},
	{name = 'shoes_1',			value = 0,		min = 0,	componentId	= 6},
	{name = 'shoes_2',			value = 0,		min = 0,	textureof	= 'shoes_1'},
	{name = 'mask_1',			value = 0,		min = 0,	componentId	= 1},
	{name = 'mask_2',			value = 0,		min = 0,	textureof	= 'mask_1'},
	{name = 'bproof_1',			value = 0,		min = 0,	componentId	= 9},
	{name = 'bproof_2',			value = 0,		min = 0,	textureof	= 'bproof_1'},
	{name = 'chain_1',			value = 0,		min = 0,	componentId	= 7},
	{name = 'chain_2',			value = 0,		min = 0,	textureof	= 'chain_1'},
	{name = 'helmet_1',			value = -1,		min = -1,	componentId	= 0 },
	{name = 'helmet_2',			value = 0,		min = 0,	textureof	= 'helmet_1'},
	{name = 'glasses_1',		value = 0,		min = 0,	componentId	= 1},
	{name = 'glasses_2',		value = 0,		min = 0,	textureof	= 'glasses_1'},
	{name = 'watches_1',		value = -1,		min = -1,	componentId	= 6},
	{name = 'watches_2',		value = 0,		min = 0,	textureof	= 'watches_1'},
	{name = 'bracelets_1',		value = -1,		min = -1,	componentId	= 7},
	{name = 'bracelets_2',		value = 0,		min = 0,	textureof	= 'bracelets_1'},
	{name = 'bags_1',			value = 0,		min = 0,	componentId	= 5},
	{name = 'bags_2',			value = 0,		min = 0,	textureof	= 'bags_1'},
	{name = 'ears_1',			value = -1,		min = -1,	componentId	= 2},
	{name = 'ears_2',			value = 0,		min = 0,	textureof	= 'ears_1'},
}

for i=1, #Components, 1 do
	Character_ESX[Components[i].name] = Components[i].value
end

function refreshValues()
	Character_ESX = {}
	for i=1, #Components, 1 do
		Character_ESX[Components[i].name] = Components[i].value
	end
end

function getMaxValues()
    local components = json.decode(json.encode(Components))
	for k,v in pairs(Character_ESX) do
		for i=1, #components, 1 do
			if k == components[i].name then
				components[i].value = v
			end
		end
	end
	return components, GetMaxVals()
end

function GetMaxVal(item)
	local myPed = PlayerPedId()
	local maxVals = GetMaxVals()
	if item == 'tshirt_1' then
		return 'tshirt_2', maxVals['tshirt_2']
	elseif item == 'torso_1' then
		return 'torso_2', maxVals['torso_2']
	elseif item == 'helmet_1' then
		return 'helmet_2', maxVals['helmet_2']
	elseif item == 'pants_1' then
		return 'pants_2', maxVals['pants_2']
	elseif item == 'shoes_1' then
		return 'shoes_2', maxVals['shoes_2']
	elseif item == 'mask_1' then
		return 'mask_2', maxVals['mask_2']
	elseif item == 'decals_1' then
		return 'decals_2', maxVals['decals_2']
	elseif item == 'chain_1' then
		return 'chain_2', maxVals['chain_2']
	elseif item == 'glasses_1' then
		return 'glasses_2', maxVals['glasses_2']
	elseif item == 'watches_1' then
		return 'watches_2', maxVals['watches_2']
	elseif item == 'bracelets_1' then
		return 'bracelets_2', maxVals['bracelets_2']
	elseif item == 'bags_1' then
		return 'bags_2', maxVals['bags_2']
	elseif item == 'ears_1' then
		return 'ears_2', maxVals['ears_2']
	elseif item == 'bproof_1' then
		return 'bproof_2', maxVals['bproof_2']
	end
end

function GetMaxVals()
	local myPed = PlayerPedId()
	local data = {
		ears_1			= GetNumberOfPedPropDrawableVariations(myPed, 2) - 1,
		ears_2			= GetNumberOfPedPropTextureVariations(myPed, 2, Character_ESX['ears_1'] - 1),
		tshirt_1		= GetNumberOfPedDrawableVariations(myPed, 8) - 1,
		tshirt_2		= GetNumberOfPedTextureVariations(myPed, 8, Character_ESX['tshirt_1']) - 1,
		torso_1			= GetNumberOfPedDrawableVariations(myPed, 11) - 1,
		torso_2			= GetNumberOfPedTextureVariations(myPed, 11, Character_ESX['torso_1']) - 1,
		decals_1		= GetNumberOfPedDrawableVariations(myPed, 10) - 1,
		decals_2		= GetNumberOfPedTextureVariations(myPed, 10, Character_ESX['decals_1']) - 1,
		arms			= GetNumberOfPedDrawableVariations(myPed, 3) - 1,
		arms_2			= 10,
		pants_1			= GetNumberOfPedDrawableVariations(myPed, 4) - 1,
		pants_2			= GetNumberOfPedTextureVariations(myPed, 4, Character_ESX['pants_1']) - 1,
		shoes_1			= GetNumberOfPedDrawableVariations(myPed, 6) - 1,
		shoes_2			= GetNumberOfPedTextureVariations(myPed, 6, Character_ESX['shoes_1']) - 1,
		mask_1			= GetNumberOfPedDrawableVariations(myPed, 1) - 1,
		mask_2			= GetNumberOfPedTextureVariations(myPed, 1, Character_ESX['mask_1']) - 1,
		bproof_1		= GetNumberOfPedDrawableVariations(myPed, 9) - 1,
		bproof_2		= GetNumberOfPedTextureVariations(myPed, 9, Character_ESX['bproof_1']) - 1,
		chain_1			= GetNumberOfPedDrawableVariations(myPed, 7) - 1,
		chain_2			= GetNumberOfPedTextureVariations(myPed, 7, Character_ESX['chain_1']) - 1,
		bags_1			= GetNumberOfPedDrawableVariations(myPed, 5) - 1,
		bags_2			= GetNumberOfPedTextureVariations(myPed, 5, Character_ESX['bags_1']) - 1,
		helmet_1		= GetNumberOfPedPropDrawableVariations(myPed, 0) - 1,
		helmet_2		= GetNumberOfPedPropTextureVariations(myPed, 0, Character_ESX['helmet_1']) - 1,
		glasses_1		= GetNumberOfPedPropDrawableVariations(myPed, 1) - 1,
		glasses_2		= GetNumberOfPedPropTextureVariations(myPed, 1, Character_ESX['glasses_1'] - 1),
		watches_1		= GetNumberOfPedPropDrawableVariations(myPed, 6) - 1,
		watches_2		= GetNumberOfPedPropTextureVariations(myPed, 6, Character_ESX['watches_1']) - 1,
		bracelets_1		= GetNumberOfPedPropDrawableVariations(myPed, 7) - 1,
		bracelets_2		= GetNumberOfPedPropTextureVariations(myPed, 7, Character_ESX['bracelets_1'] - 1)
	}
	return data
end