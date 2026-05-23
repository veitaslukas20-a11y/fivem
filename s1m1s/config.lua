Config = {}

Config.UseESX = true						-- Use ESX Framework

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.

RegisterNetEvent('gk-carflip:CustomNotify')
AddEventHandler('gk-carflip:CustomNotify', function(message, type)
end)

Config.TimetoFlip = 30 						-- How long, in seconds, to flip the car.
Config.Jobs = {}
Config.UseThirdEye = true 					-- Enables using a third eye (depending on version will need to update export to target all vehicles)
Config.ThirdEyeName = 'qtarget' 			-- Name of third eye aplication
Config.UseChatCommand = false                -- Enables using chat command to flip vehicle. Must be true if Config.UseThirdEye=false.
Config.ChatCommand = 'flipcar'              -- When Config.UseChatCommand = true, is the phrase used to flip vehicle.

Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'inform'
}

Config.Lang = {
	['flipped'] = 'Apvertei tr. priemonę!',
    ['in_vehicle'] = '',
    ['far_away'] = '',
    ['not_allowed'] = 'You don\'t have the training or tools to flip a vehicle!',
}
