local keys = { ['G'] = 0x760A9C6F, ['S'] = 0xD27782E3, ['W'] = 0x8FD015D8, ['H'] = 0x24978A28, ['G'] = 0x5415BE48, ["ENTER"] = 0xC7B5340A, ['E'] = 0xDFF812F9 }

local pressTime = 0
local pressLeft = 0

local recentlySpawned = 0

local horseModel;
local horseSpawn = {}
local NumberHorseSpawn = 0

local CurrentZoneActive = 0

local Horses = {
	{
		['Text'] = "$20 - Tennesseewalker Chestnut",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~0",
		['Param'] = {
			['Price'] = 20,
			['Model'] = "A_C_HORSE_TENNESSEEWALKER_CHESTNUT",
			['Level'] = 0
		}
	},
	{
		['Text'] = "$35 - SHIRE RAVENBLACK",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~3",
		['Param'] = {
			['Price'] = 35,
			['Model'] = "A_C_HORSE_SHIRE_RAVENBLACK",
			['Level'] = 0
		}
	},
	{
		['Text'] = "$45 - APPALOOSA LEOPARD",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~6",
		['Param'] = {
			['Price'] = 35,
			['Model'] = "A_C_HORSE_APPALOOSA_LEOPARD",
			['Level'] = 6
		}
	},
	{
		['Text'] = "$60 - Mr Bill W",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~9",
		['Param'] = {
			['Price'] = 60,
			['Model'] = "A_C_HORSE_GANG_BILL",
			['Level'] = 9
		}
	},
	{
		['Text'] = "$70 - Kentuckysaddle Black",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~13",
		['Param'] = {
			['Price'] = 70,
			['Model'] = "A_C_HORSE_KENTUCKYSADDLE_BLACK",
			['Level'] = 13
		},
	},
	{
		['Text'] = "$150 - THOROUGHBRED BRINDLE",
		['SubText'] = "",
		['Desc'] = "Level Require : ~pa~16",
		['Param'] = {
			['Price'] = 150,
			['Model'] = "A_C_HORSE_THOROUGHBRED_BRINDLE",
			['Level'] = 16
		}
	}
}

local function CreateBlips ( )
	for k,v in pairs(Config.Coords) do
		local blip = Citizen.InvokeNative( 0x554d9d53f696d002, 564457427, v.x, v.y, v.z)
	end
end

local function GiveAllAttitude( entity )
    -- | SET_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 0, 1100 )
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 1, 1100 )
    Citizen.InvokeNative( 0x09A59688C26D88DF, entity, 2, 1100 )
    -- | ADD_ATTRIBUTE_POINTS | --
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 0, 1100 )
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 1, 1100 )
    Citizen.InvokeNative( 0x75415EE0CB583760, entity, 2, 1100 )
    -- | SET_ATTRIBUTE_BASE_RANK | --
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 0, 10 )
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 1, 10 )
    Citizen.InvokeNative( 0x5DA12E025D47D4E5, entity, 2, 10 )
    -- | SET_ATTRIBUTE_BONUS_RANK | --
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 0, 10 )
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 1, 10 )
    Citizen.InvokeNative( 0x920F9488BD115EFB, entity, 2, 10 )
    -- | SET_ATTRIBUTE_OVERPOWER_AMOUNT | --
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 0, 5000.0, false )
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 1, 5000.0, false )
    Citizen.InvokeNative( 0xF6A7C08DF2E28B28, entity, 2, 5000.0, false )
	-- accs
	Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0x20359E53,true,true,true) --saddle
    Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0x508B80B9,true,true,true) --blanket
   -- Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0x16923E26,true,true,true) --mane
    --Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0xF867D611,true,true,true) --tail
    Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0xF0C30271,true,true,true) --bag
    Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0x12F0DF9F,true,true,true) --bedroll
    Citizen.InvokeNative(0xD3A7B003ED343FD9, entity,0x67AF7302,true,true,true) --stirups
end

local function IsNearZone ( location )

	local player = PlayerPedId()
	local playerloc = GetEntityCoords(player, 0)

	for i = 1, #location do
		if #(playerloc - location[i]) < 1.0 then
			return true, i
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
	repeat
		if WarMenu.IsMenuOpened('id_Horse') then
			for i = 1, #Horses do
				if WarMenu.Button(Horses[i]['Text'], Horses[i]['SubText'], Horses[i]['Desc']) then
					TriggerServerEvent('elrp:buyhorse', Horses[i]['Param'])
					WarMenu.CloseMenu()
				end
			end
			WarMenu.Display()
		end
		Citizen.Wait(0)
	until false
end)

Citizen.CreateThread(function()
	while true do

		local IsZone, IdZone = IsNearZone( Config.Coords )

		if IsZone then
			DisplayHelp(Config.Shoptext, 0.50, 0.95, 0.6, 0.6, true, 255, 255, 255, 255, true, 10000)
			if IsControlJustReleased(0, keys['G']) then
				WarMenu.OpenMenu('id_Horse')
				CurrentZoneActive = IdZone
			end
		end

		if IsControlJustReleased( 0, keys['H'] ) then
			pressLeft = GetGameTimer()
			pressTime = pressTime + 1
		end

		if pressLeft ~= nil and (pressLeft + 500) < GetGameTimer() and pressTime > 0 and pressTime < 1 then
			pressTime = 0
		end

		if pressTime == 1 then
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
AddEventHandler( 'elrp:spawnHorse', function ( horse, isInShop )

	local player = PlayerPedId()

	local model = GetHashKey( horse )
	local x, y, z, heading, a, b

	if isInShop then
		x, y, z, heading = -373.302, 786.904, 116.169, 273.18
	else
		x, y, z = table.unpack( GetOffsetFromEntityInWorldCoords( player, 0.0, -100.0, 0.3 ) )
		a, b = GetGroundZAndNormalFor_3dCoord( x, y, z + 10 )
	end

	local idOfTheHorse = NumberHorseSpawn + 1

	RequestModel( model )

	while not HasModelLoaded( model ) do
		Wait(500)
	end

	if horseSpawn[idOfTheHorse] == nil then

		horseModel = CreatePed( model, x, y, z, heading, 1, 1 )

		SET_PED_RELATIONSHIP_GROUP_HASH( horseModel, model )
		SET_PED_DEFAULT_OUTFIT( horseModel )
		SET_BLIP_TYPE( horseModel )
		GiveAllAttitude( horseModel )

		TaskGoToEntity( idOfTheHorse, player, -1, 7.2, 2.0, 0, 0 )

		horseSpawn[idOfTheHorse] = { id = idOfTheHorse, model = horseModel }

	end

	if horseSpawn[idOfTheHorse] then

		if isInShop then

			local x, y, z, w = table.unpack( Config.SpawnHorse[CurrentZoneActive] )

			DeleteEntity(horseSpawn[idOfTheHorse].model)

			horseSpawn[idOfTheHorse].model = CreatePed( model, x, y, z, w, 1, 1 )
			horseSpawn[idOfTheHorse].id = idOfTheHorse

			SET_PED_RELATIONSHIP_GROUP_HASH( horseSpawn[idOfTheHorse].model, model )
			SET_PED_DEFAULT_OUTFIT( horseSpawn[idOfTheHorse].model )
			SET_BLIP_TYPE( horseSpawn[idOfTheHorse].model )
			GiveAllAttitude( horseSpawn[idOfTheHorse].model )
			
			
		else

			local EntityIsDead = IsEntityDead( horseSpawn[idOfTheHorse].model )

			if EntityIsDead then

				ShowNotification( " your horse is being treated he wasn't well..." )

				horseSpawn[idOfTheHorse].model = CreatePed( model, x, y, b, heading, 1, 1 )
				horseSpawn[idOfTheHorse].id = idOfTheHorse

			end

			local EntityPedCoord = GetEntityCoords( player )
			local EntityHorseCoord = GetEntityCoords( horseSpawn[idOfTheHorse].model )

			if #( EntityPedCoord - EntityHorseCoord ) > 100.0 then

				DeleteEntity(horseSpawn[idOfTheHorse].model)

				horseSpawn[idOfTheHorse].model = CreatePed( model, x, y, b, heading, 1, 1 )
				horseSpawn[idOfTheHorse].id = idOfTheHorse

				SET_PED_RELATIONSHIP_GROUP_HASH( horseSpawn[idOfTheHorse].model, model )
				SET_PED_DEFAULT_OUTFIT( horseSpawn[idOfTheHorse].model )
				SET_BLIP_TYPE( horseSpawn[idOfTheHorse].model )

				GiveAllAttitude( horseSpawn[idOfTheHorse].model )
				
		
			end

			TaskGoToEntity( horseSpawn[idOfTheHorse].model, player, -1, 7.2, 2.0, 0, 0 )

		end

	end

end )

function SET_BLIP_TYPE ( animal )
	return Citizen.InvokeNative(0x23f74c2fda6e7c61, -1230993421, animal)
end

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