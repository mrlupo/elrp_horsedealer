local keys = { ['G'] = 0x760A9C6F, ['S'] = 0xD27782E3, ['W'] = 0x8FD015D8, ['H'] = 0x24978A28, ['G'] = 0x5415BE48, ["ENTER"] = 0xC7B5340A, ['E'] = 0xDFF812F9 }

local pressTime = 0
local pressLeft = 0

local recentlySpawned = 0

local horseModel;
local horseSpawn = {}
local NumberHorseSpawn = 0

local Horses = {
	[1] = {
		['Text'] = "$20 Tennesseewalker Chestnut level require [0]",
		['SubText'] = "",
		['Desc'] = "level require [0]",
		['Param'] = {
			['Price'] = 20,
			['Model'] = "A_C_HORSE_TENNESSEEWALKER_CHESTNUT",
			['Level'] = 0
		}
	},
	[2] = {
		['Text'] = "$35 SHIRE RAVENBLACK level require [3]",
		['SubText'] = "",
		['Desc'] = "level require [0]",
		['Param'] = {
			['Price'] = 35,
			['Model'] = "A_C_HORSE_SHIRE_RAVENBLACK",
			['Level'] = 0
		}
	},
	[3] = {
		['Text'] = "$45 APPALOOSA LEOPARD level require [6]",
		['SubText'] = "",
		['Desc'] = "level require [0]",
		['Param'] = {
			['Price'] = 35,
			['Model'] = "A_C_HORSE_APPALOOSA_LEOPARD",
			['Level'] = 6
		}
	},
	[4] = {
		['Text'] = "$60 Mr Bill W level require [9]",
		['SubText'] = "",
		['Desc'] = "level require [9]",
		['Param'] = {
			['Price'] = 60,
			['Model'] = "A_C_HORSE_GANG_BILL",
			['Level'] = 9
		}
	},
	[5] = {
		['Text'] = "$70 Kentuckysaddle Black level require [13]",
		['SubText'] = "",
		['Desc'] = "level require [5]",
		['Param'] = {
			['Price'] = 70,
			['Model'] = "A_C_HORSE_KENTUCKYSADDLE_BLACK",
			['Level'] = 13
		},
	},
	[6] = {
		['Text'] = "$150 THOROUGHBRED BRINDLE level require [16]",
		['SubText'] = "",
		['Desc'] = "level require [9]",
		['Param'] = {
			['Price'] = 150,
			['Model'] = "A_C_HORSE_THOROUGHBRED_BRINDLE",
			['Level'] = 16
		}
	}
}

local function CreateBlips ( )
	for k,v in pairs(Config.Coords) do
		local blip = Citizen.InvokeNative( 0x554d9d53f696d002, -515518185, v.x, v.y, v.z)
	end
end

local function IsNearZone ( location )

	local player = PlayerPedId()
	local playerloc = GetEntityCoords(player, 0)

	for i=1,#location do
		if #(playerloc - location[i]) < 1.0 then
			return true
		end
	end

end

local function DisplayHelp( _message, x, y, w, h, enableShadow, col1, col2, col3, a, centre )

	local str = CreateVarString(10, "LITERAL_STRING", _message, Citizen.ResultAsLong())

	SetTextScale(w, h)
	SetTextColor(col1, col2, col3, a)

	SetTextCentre(centre)

	if enableShadow then
		SetTextDropshadow(1, 0, 0, 0, 255)
	end

	Citizen.InvokeNative(0xADA9255D, 10);

	DisplayText(str, x, y)

end

local function ShowNotification( _message )
	local timer = 200
	while timer > 0 do
		DisplayHelp(_message, 0.50, 0.90, 0.6, 0.6, true, 161, 3, 0, 255, true, 10000)
		timer = timer - 1
		Citizen.Wait(0)
	end
end

Citizen.CreateThread( function()
	WarMenu.CreateMenu('id_Horse', 'Shop Horses')
	while true do
		if WarMenu.IsMenuOpened('id_Horse') then
			for i = 1, #Horses do
				if WarMenu.Button(Horses[i]['Text'], Horses[i]['SubText']) then
					TriggerServerEvent('elrp:buyhorse', Horses[i]['Param'])
				end
			end
			WarMenu.Display()
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do

		if IsNearZone( Config.Coords ) then
			DisplayHelp(Config.Shoptext, 0.50, 0.95, 0.6, 0.6, true, 255, 255, 255, 255, true, 10000)
			if IsControlJustReleased(0, keys['E']) then
				WarMenu.OpenMenu('id_Horse')
			end
		end

		if IsControlJustReleased( 0, keys['H'] ) then
			pressLeft = GetGameTimer()
			pressTime = pressTime + 1
		end

		if pressLeft ~= nil and (pressLeft + 500) < GetGameTimer() and pressTime > 0 and pressTime < 3 then
			pressTime = 0
		end

		if pressTime == 3 then
			if recentlySpawned <= 0 then
				recentlySpawned = 10
				TriggerServerEvent('elrp:loadhorse')
			else
				TriggerEvent('chat:systemMessage', 'Please wait ' .. recentlySpawned .. ' seconds before calling your horse.')
				TriggerEvent('chat:addMessage', {
					color = { 171, 59, 36 },
					multiline = true,
					args = {"Anti-Spam", 'Please wait ' .. recentlySpawned .. ' seconds before calling your horse.'}
				})
			end
			pressTime = 0
		end

		Citizen.Wait(0)
	end
end)

-- | Blips | --

Citizen.CreateThread(function()
	CreateBlips ( )
end)

-- | Notification | --

RegisterNetEvent('UI:DrawNotification')
AddEventHandler('UI:DrawNotification', function( _message )
	ShowNotification( _message )
end)

-- | Spawn Horse | --

RegisterNetEvent( 'elrp:spawnHorse' )
AddEventHandler( 'elrp:spawnHorse', function ( horse )

	local player = PlayerPedId()

	local model = GetHashKey( horse )
	local x,y,z = table.unpack( GetOffsetFromEntityInWorldCoords( player, 0.0, 4.0, 0.5 ) )

	local heading = GetEntityHeading( player ) + 90

	local oldIdOfTheHorse = idOfTheHorse
	
	local idOfTheHorse = NumberHorseSpawn + 1

	RequestModel( model )

	while not HasModelLoaded( model ) do
		Wait(500)
	end

	if ( horseSpawn[idOfTheHorse] ~= oldIdOfTheHorse ) then
		DeleteEntity( horseSpawn[idOfTheHorse].model )
	end

	horseModel = CreatePed( model, x, y, z, heading, 1, 1 )

	SET_PED_RELATIONSHIP_GROUP_HASH( horseModel, model )
	SET_PED_DEFAULT_OUTFIT( horseModel )

	horseSpawn[idOfTheHorse] = { id = idOfTheHorse, model = horseModel }

end )

function SET_ANIMAL_TUNING_BOOL_PARAM ( animal, p1, p2 )
	return Citizen.InvokeNative( 0x9FF1E042FA597187, animal, p1, p2 )
end

function SET_PED_DEFAULT_OUTFIT ( horse )
	return Citizen.InvokeNative( 0x283978A15512B2FE, horse, true )
end

function SET_PED_RELATIONSHIP_GROUP_HASH ( iVar0, iParam0 )
	return Citizen.InvokeNative( 0xC80A74AC829DDD92, iVar0, _GET_DEFAULT_RELATIONSHIP_GROUP_HASH( iParam0 ) )
end

function _GET_DEFAULT_RELATIONSHIP_GROUP_HASH ( iParam0 )
	return Citizen.InvokeNative( 0xC80A74AC829DDD92, iParam0 );
end

-- | Timer | --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
		if recentlySpawned > 0 then
			recentlySpawned = recentlySpawned - 1
		end
    end
end)