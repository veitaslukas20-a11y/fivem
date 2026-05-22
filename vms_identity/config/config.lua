Config                  = {}

Config.MaxNameLength = 16 -- Max Name Length.
Config.LimitHeight = {120, 220} -- minimum and maximum
Config.LimitYear = {1900, 2010} -- minimum and maximum

Config.EnableBlur = true

Config.Multichars = true
Config.UseCustomSkinCreator = false -- If you want this you must set Config.Multichars = false 

-- @UseLatinAlphabetChecker: If you are using other alphabet than Latin, like Arabic, Japanese, Cyrillic etc. set false
Config.UseLatinAlphabetChecker = true

Config.UseNationalityOption = false

Config.DateFormat = 'yyyy/mm/dd'

Config.Notification = function(title, message, type)
	if type == "success" then
		--exports["vms_notify"]:Notification(title, message, 4000, "#58c431", "fa-solid fa-fingerprint")
		TriggerEvent('esx:showNotification', message)
	elseif type == "error" then
		--exports["vms_notify"]:Notification(title, message, 4000, "#c43131", "fa-solid fa-fingerprint")
		TriggerEvent('esx:showNotification', message)
	elseif type == "info" then
		--exports["vms_notify"]:Notification(title, message, 4000, "#4287f5", "fa-solid fa-fingerprint")
		TriggerEvent('esx:showNotification', message)
	end
end

Config.Hud = {
    Enable = function()
        -- exports['vms_hud']:Display(true)
    end,
    Disable = function()
        -- exports['vms_hud']:Display(false)
    end
}

Config.Translate = {
    ['cmd.opened_register'] = 'Sėkmingai atidarytas žaidėjo registravimo meniu %s',
    ['cmd.help_id'] = 'id',
    ['cmd.help_register'] = 'Atidarykite žaidėjo registro meniu',

    ['register_notify'] = 'Registracija',
	['register_success'] = 'Sėkminga registracija!',
	['already_registered'] = 'Esate jau užsiregstravęs.',
	['invalid_firstname'] = 'Netinkamas formatas <b>Vardas</b>.',
	['invalid_lastname'] = 'Netinkamas formatas <b>Pavardė</b>.',
	['invalid_sex'] = 'Netinkamas formatas <b>lytis</b>.',
	['invalid_dob'] = 'Netinkamas formatas <b>Gimimo data</b>.',
	['invalid_height'] = 'Netinkamas formatas <b>Ūgis</b>.',
}