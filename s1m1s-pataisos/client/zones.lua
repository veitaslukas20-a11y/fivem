local Target = exports.ox_target

local zones = {}

local jobs = require('client.jobs') 
local questions = require('client.questions') 

local function addZones()
	local jacuzziCoords = {
		vector3(935.5562, 24.2183, 111.6687),
		vector3(941.7786, 33.9066, 111.6674),
		vector3(947.7785, 43.8545, 111.6688),
		vector3(953.9399, 53.5784, 111.6675),
		vector3(953.9399, 53.5784, 111.6675),
	}

	for _, coords in pairs(jacuzziCoords) do
		local zoneKey = ('jacuzzi:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)
		local zoneId = Target:addBoxZone({
			coords = coords,
			size = vec3(3.5, 3.5, 3.5),
			rotation = 0.0,
			options = {
				{
					icon = "fa-solid fa-water-ladder",
					label = "Valyti džiakuzi",
					name = 'pataisos:baseinas',
					distance = 1.0,
					onSelect = function(data)
						if jobs.startJob('Valote džiakuzi...', {
							dict = 'timetable@floyd@clean_kitchen@base',
							clip = 'base'
						}, zoneKey) then
                            questions.showQuestion()
                        end
					end,
				}
			}
		})
		table.insert(zones, zoneId)
	end

	Target:addModel({`prop_patio_lounger1b`, `prop_patio_lounger1`}, {
		{
			icon = "fa-solid fa-umbrella-beach",
			label = "Valyti gultus",
			name = 'pataisos:gultai',
			distance = 1.0,
			onSelect = function(data)
				if jobs.startJob('Valote gultą...', {
					dict = 'timetable@floyd@clean_kitchen@base',
					clip = 'base'
				}, data.entity) then
                    questions.showQuestion()
                end
			end,
		}
	})

	local sofasCoords = {
		vector3(932.0294, 40.1446, 113.4100),
		vector3(925.9039, 30.4613, 113.4099),
		vector3(938.0698, 50.0829, 113.4100),
		vector3(944.1802, 59.8174, 113.4101),
	}

	for _, coords in pairs(sofasCoords) do
		local zoneKey = ('sofa:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)
		local zoneId = Target:addBoxZone({
			coords = coords,
			size = vec3(3.5, 3.5, 3.5),
			rotation = 0.0,
			options = {
				{
					icon = "fa-solid fa-couch",
					label = "Valyti sofą",
					name = 'pataisos:sofa',
					distance = 2.0,
					onSelect = function(data)
						if jobs.startJob('Valote sofą...', {
							dict = 'timetable@floyd@clean_kitchen@base',
							clip = 'base'
						}, zoneKey) then
                            questions.showQuestion()
                        end
					end,
				}
			}
		})
		table.insert(zones, zoneId)
	end

	local groundCoords = {
		vector3(921.6205, 46.8908, 111.6615),
		vector3(960.3195, 61.1788, 111.5529),
		vector3(932.2241, 17.4740, 111.5529)
	}

	for _, coords in pairs(groundCoords) do
		local zoneKey = ('ground:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)
		local zoneId = Target:addBoxZone({
			coords = coords,
			size = vec3(3.0, 3.0, 3.0),
			rotation = 0.0,
			options = {
				{
					icon = "fa-solid fa-broom",
					label = "Šluoti grindis",
					name = 'pataisos:grindys',
					distance = 1.0,
					onSelect = function(data)
						if jobs.startJob('Valote grindis...', {
							scenario = 'WORLD_HUMAN_JANITOR'
						}, zoneKey) then
                            questions.showQuestion()
                        end
					end,
				}
			}
		})
		table.insert(zones, zoneId)
	end

	local palmCoords = {
		vector3(929.2624, 50.5359, 111.6615),
		vector3(932.0535, 54.5740, 111.6615),
		vector3(946.6062, 51.3191, 113.3598),
		vector3(952.7486, 60.8352, 113.3579),
		vector3(940.5599, 41.2863, 113.3615),
		vector3(928.2511, 21.8362, 113.3574),
	}

	for _, coords in pairs(palmCoords) do
		local zoneKey = ('palm:%.1f:%.1f:%.1f'):format(coords.x, coords.y, coords.z)
		local zoneId = Target:addBoxZone({
			coords = coords,
			size = vec3(1.5, 1.5, 1.5),
			rotation = 0.0,
			options = {
				{
					icon = "fa-solid fa-scissors",
					label = "Genėti palmę",
					name = 'pataisos:palme',
					distance = 1.0,
					onSelect = function(data)
						if jobs.startJob('Genite medį...', {
							dict = 'amb@prop_human_movie_bulb@idle_a',
							clip = 'idle_a'
						}, zoneKey) then
                            questions.showQuestion()
                        end
					end,
				}
			}
		})
		table.insert(zones, zoneId)
	end
end

local function removeZones()
    Target:removeModel({`prop_patio_lounger1b`, `prop_patio_lounger1`}, 'pataisos:gultai')
    for _, zoneId in pairs(zones) do
        Target:removeZone(zoneId)
    end
    zones = {}
end

return {
    addZones = addZones,
    removeZones = removeZones
}