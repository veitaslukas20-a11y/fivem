Config = {}

Config.Locale = 'en'

--Base
Config.LighterItem = 'lighter' -- Lighter item
Config.Smoke = 38 -- draw smoke from a cigarette, cigar, joint  -- https://docs.fivem.net/docs/game-references/controls/
Config.Throw = 105 -- throw away a cigarette, cigar, joint
Config.Mouth = 11 -- from hand to mouth
Config.inHand = 10 -- From mouth to hands

----------------------------------------

--Ciggarate
Config.SmokeMouth = 0.1 -- The size of the smoke from the mouth
Config.SmokeSizeCigarette = 0.03 -- The size of cigarette smoke

Config.CigaretteHangTime = 1000 -- smoke exhalation time
Config.CigaretteSmokingTime = 180000 -- After 3 minutes, the character discards the cigarette
Config.CancelSmoke = true  -- If it is false, smoking will last indefinitely; if it is true, it will end after the Config.CigaretteSmokingTime

Config.ItemCigarette = {    -- Cigarette Items
	'cigarette_low'
}

Config.CigarettePack = { -- set the pack items here and which items you get from the pack
    {PackItem = "cigarette_pack",  CigaretteItem = 'cigarette_low', Amount = 20},
}

----------------------------------------

--Cigar
Config.SmokeCigarMouth = 0.2 -- The size of the smoke from the mouth
Config.SmokeSizeCigar = 0.03 -- The size of cigar smoke

Config.CancelSmokeCigar = true -- If it is false, smoking will last indefinitely; if it is true, it will end after the Config.CigarSmokingTime 

Config.CigarHangTime = 1500 -- smoke exhalation time
Config.CigarSmokingTime = 240000 -- After 4 minutes, the character discards the cigar

Config.ItemCigar = {    -- Cigar Items
	'cubancigar',
	'davidoffcigar'
}

----------------------------------------

--Joint
Config.SmokeJointMouth = 0.1 -- The size of the smoke from the mouth
Config.SmokeSizeJoint = 0.04 -- The size of joint smoke

Config.CancelSmokeJoint = true -- If it is false, smoking will last indefinitely; if it is true, it will end after the Config.JointSmokingTime 

Config.JointHangTime = 1000 -- smoke exhalation time
Config.JointSmokingTime = 180000-- After 3 minutes, the character discards the Joint

Config.Rollingpaper = 'ocb_paper'

Config.ItemJoint = {    -- Joint Items
	'og_kush_joint',
	'blue_dream_joint',
	'purple_haze_joint',
	'banana_kush_joint'
}

Config.ItemWeed = {    -- Weed bag
	'banana_kush_bag',
	'blue_dream_bag',
	'og_kush_bag',
	'purple_haze_bag'
}
----------------------------------------