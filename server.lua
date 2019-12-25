print( '\x1b[31m[ELRP_HorseDealer]\x1b[0m : ' .. Config.Version )

local function GetAmmoutHorses( Player_ID, Character_ID )
    local HasHorses = MySQL.Sync.fetchAll( "SELECT * FROM horses WHERE identifier = @identifier AND charid = @charid ", {
        ['identifier'] = Player_ID,
        ['charid'] = Character_ID
    } )
    if #HasHorses > 0 then return true end
    return false
end

RegisterServerEvent('elrp:buyhorse')
AddEventHandler( 'elrp:buyhorse', function ( args )

    local _src   = source
    local _price = args['Price']
    local _level = args['Level']
    local _model = args['Model']


	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
        u_identifier = user.getIdentifier()
        u_level = user.getLevel()
        u_charid = user.getSessionVar("charid")
        u_money = user.getMoney()
    end)

    local _resul = GetAmmoutHorses( u_identifier, u_charid )

    if u_money <= _price then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.NoMoney )
        return
    end

    if u_level <= _level then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.LevelMissing )
        return
    end

	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
        user.removeMoney(_price)
    end)

    TriggerClientEvent('elrp:spawnHorse', _src, _model, true)


    if _resul ~= true then
        local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['horse'] = _model }
        MySQL.Async.execute("INSERT INTO horses ( `identifier`, `charid`, `horse` ) VALUES ( @identifier, @charid, @horse )", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, 'You got a new horse !' )
    else
        local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['horse'] = _model }
        MySQL.Async.execute(" UPDATE horses SET horse = @horse WHERE identifier = @identifier AND charid = @charid ", Parameters)
        TriggerClientEvent( 'UI:DrawNotification', _src, 'You update the horse !' )
    end

end)

RegisterServerEvent( 'elrp:loadhorse' )
AddEventHandler( 'elrp:loadhorse', function ( )

    local _src = source

	TriggerEvent('redemrp:getPlayerFromId', _src, function(user)
	    u_identifier = user.getIdentifier()
	    u_charid = user.getSessionVar("charid")
	end)

    local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid }
    local HasHorses = MySQL.Sync.fetchAll( "SELECT * FROM horses WHERE identifier = @identifier AND charid = @charid ", Parameters )

    if HasHorses[1] then
        local horse = HasHorses[1].horse
        print(horse)
        TriggerClientEvent("elrp:spawnHorse", _src, horse, false)
    end

end )