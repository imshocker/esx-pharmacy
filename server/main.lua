local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterNetEvent('rj-pharmacy:server:CreateRx', function(rx)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local info = {}
    info.rx_patient = rx[1]
    info.rx_quantity = tostring(rx[2])
    info.rx = rx[3]
    info.directions = rx[4]
    info.rx_doctor = xPlayer.getName()
    info.rx_Date = os.date('%d %B %Y')
    info.refilled = '0'
    --print(json.encode(info, {indent=true}))

    if not xPlayer.canCarryItem("prescription", 1, info) then
        TriggerClientEvent('esx:showNotification', source, "Ain't even got space for a note in these pockets, damn bruh.")
        TriggerClientEvent('inventory:client:ItemBox', src, ESX.GetSharedObject().Items["prescription"], "add")
    else
        xPlayer.addInventoryItem("prescription", 1, info)
    end
end)

RegisterNetEvent('rj-pharmacy:server:buymedicine', function()
    local src = source
    local item = exports.ox_inventory:Search(src, 'slots', "prescription")
    
    for k, v in pairs(item) do
        item = v
        break
    end

    local price = 0

    if item and item.metadata and item.metadata.rx then
        for k, v in pairs(item.metadata.rx) do
            local medicine = Config.Prices[item.metadata.rx[k]]
            local quantity = tonumber(item.metadata.rx_quantity)

            if medicine and quantity then
                price = price + medicine * quantity
            else
                print("Warning: Missing funds for prescription item.")
            end
        end
    else
        print("Warning: Missing prescription for the item.")
    end
	if exports.ox_inventory:RemoveItem(src, "money", price) then
		if exports.ox_inventory:RemoveItem(src, "prescription", 1, item.metadata) then
			for k, v in pairs(item.metadata.rx) do
				if exports.ox_inventory:CanCarryItem(src, item.metadata.rx[k], tonumber(item.metadata.rx_quantity)) then
					exports.ox_inventory:AddItem(src, item.metadata.rx[k], tonumber(item.metadata.rx_quantity))
				end
			end
		else
			TriggerClientEvent('ox_lib:notify', src,
				{ type = 'error', description = 'You do not have the a prescription' })
		end
	else
		TriggerClientEvent('ox_lib:notify', src,
			{ type = 'error', description = 'You do not have enough cash' })
	end
end)

RegisterServerEvent('rj-pharmacy:server:GiveRx', function(target, rx)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xOtherPlayer = ESX.GetPlayerFromId(tonumber(target))
    local dist = #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(tonumber(target))))

    local info = {}
    info.rx_patient = rx[1]
    info.rx_quantity = tostring(rx[2])
    info.rx = rx[3]
    info.directions = rx[4]
    info.rx_doctor = xPlayer.getName()
    info.rx_Date = os.date('%d %B %Y')
    info.refilled = '0'

    if xPlayer == xOtherPlayer then
        return TriggerClientEvent('esx:showNotification', src, "You can't give yourself an item?")
    end

    if dist > 2.0 then
        return TriggerClientEvent('esx:showNotification', src, "You are too far away to give items!")
    end

    if xOtherPlayer.canCarryItem("prescription", 1, info) then
        xOtherPlayer.addInventoryItem("prescription", 1, info)
        TriggerClientEvent('esx:showNotification', src, ('You pass %s their prescription.'):format(xOtherPlayer.getName()))
        TriggerClientEvent('esx:showNotification', tonumber(target), ('%s passes you a written prescription.'):format(xPlayer.getName()))
    else
        TriggerClientEvent('esx:showNotification', src, "The other player's inventory is full!", "error")
        TriggerClientEvent('esx:showNotification', tonumber(target), "Your inventory is full!", "error")
    end
end)

ESX.RegisterUsableItem('prescriptionpad', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.job.name == 'ambulance' then
        TriggerClientEvent('rj-pharmacy:client:RxAnimation', src)
        TriggerClientEvent('rj-pharmacy:client:WriteRx', src)
    else
        TriggerClientEvent('esx:showNotification', src, 'Your hand stops and you think to yourself; "Maybe I should put some effort into forging this signature instead of going to jail forever."', "error")
    end
end)

RegisterNetEvent('rj-pharmacy:server:tickRx', function(item)
	local src = source
    local Player = ESX.GetPlayerFromId(src)
	print('rxtick')
	local refilled = tonumber(item.metadata.refilled)
	if Player.PlayerData.job.name == 'ambulance' then
        refilled =refilled + 1
		item.metadata.refilled = tostring(refilled)
        exports.ox_inventory:SetMetadata(src, item.slot, item.metadata)
	end
end)