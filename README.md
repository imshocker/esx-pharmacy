# Pharmacy

A simple Pharmacy Script for fivem which uses prescriptions converted from QB-Core to ESX. There is an option for players without ambulance job to also use the `prescriptionpad` item, but only once. Just change a few lines in server/main.lua (lines provided in README)

## Dependecies
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- [esx-framework](https://github.com/esx-framework)

## Installation

- Add this to `ox_inventory\data\items.lua`
```lua
	['prescription'] = {
		label = 'Prescription',
		weight = 300,
		stack = false,
		close = true,
		description = "A piece of paper used for pharmacies"
	},
	['prescriptionpad'] = {
		label = 'Prescription Pad',
		weight = 300,
		stack = false,
		close = true,
		description = "A prescription pad used by doctors to write prescriptions"
	},
```

- Optional feature: Replace line 110 in `esx-pharmacy/server/main.lua`
```lua
 -- Remove 'prescriptionpad' from the player's inventory
        xPlayer.removeInventoryItem('prescriptionpad', 1)

        -- Notify the player about forging the prescription signature
        TriggerClientEvent('esx:showNotification', src, '*Forging prescription signature*')

        -- Trigger the client events
        TriggerClientEvent('rj-pharmacy:client:RxAnimation', src)
        TriggerClientEvent('rj-pharmacy:client:WriteRx', src)
```
 With this ^

 
- Drop resource into your server directory and add `ensure esx-pharmacy` to your `server.cfg`
- Enjoy

# credit

- credit to `RijayJH` for the original script. I only converted it to work with ESX.
