local menu = false
local first = false
local inside = false
local currentProperty = nil

----- Furniture -----

local drawing = false
local forward = 2.0
local up = 0.0
local rotate = 0.0
local upPress = false
local downPress = false
local props = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent("SM_Properties:Option")
AddEventHandler("SM_Properties:Option", function(option, coords, distanceAmount, cb)
	cb(Menu.Option(option, coords, distanceAmount))
end)

RegisterNetEvent("SM_Properties:Update")
AddEventHandler("SM_Properties:Update", function()
	Menu.updateSelection()
end)

RegisterNetEvent("SM_Properties:UpdateOption")
AddEventHandler("SM_Properties:UpdateOption", function()
    Menu.UpdateOption() 
end)

RegisterNetEvent('dooranim')
AddEventHandler('dooranim', function()
    ClearPedSecondaryTask(GetPlayerPed(-1))
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 16, 0, 0, 0, 0)
    Citizen.Wait(850)
    ClearPedTasks(GetPlayerPed(-1))
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	TriggerServerEvent('SM_Properties:updateSpawned')
	ESX.TriggerServerCallback('SM_Properties:GetEmpty', function(result)
		for k,v in pairs(result) do
			if v.empty == 1 then
				for i,j in pairs(properties) do
					for w,x in pairs(j.locations) do
						if v.name == x.name then
							x.empty = true
						else
							x.empty = false
						end
					end
				end
			end
		end
	end)
end)

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end

properties = {
	{tier = "low", locations = {
		{label = "123 Brouge Avenue", name = "123BrougeAvenue", enter = {x = 197.3, y = -1725.9, z = 29.66, h = 265.12}, inside = {x = 191.51, y = -1724.2, z = 21.92, h = 289.03}, exit = {x = 191.09, y =-1724.34, z = 22.96}, outside = {x = 198.23, y = -1725.48, z = 28.66, h = 258.94}, empty = true, owner = false, locked = false, haskey = false, max = 2, price = 150000}
	}},
}

function checkOwned()
	ESX.TriggerServerCallback('SM_Properties:GetOwned', function(result)
		for i = 1, #result, 1 do
			if result[i].owner == ESX.GetPlayerData().identifier then
				for j = 1, #properties, 1 do
					for x = 1, #properties[j].locations, 1 do
						if result[i].name == properties[j].locations[x].name then
							properties[j].locations[x].owner = true
						else
							properties[j].locations[x].owner = false
						end
					end
				end
			end
		end
	end)
end

RegisterNetEvent('checkOwned')
AddEventHandler('checkOwned', function()
	checkOwned()
end)

RegisterNetEvent('checkEmpty')
AddEventHandler('checkEmpty', function()
	checkEmpty()
end)

RegisterNetEvent('checkLock')
AddEventHandler('checkLock', function()
	checkLock()
end)

RegisterNetEvent('updateEmpty')
AddEventHandler('updateEmpty', function(propertyName, to)
	for k,v in pairs(properties) do
		for i,j in pairs(v.locations) do
			if j.name == propertyName then
				j.empty = to
			end
		end
	end
end)

RegisterNetEvent('updateOwned')
AddEventHandler('updateOwned', function(propertyName, to)
	for k,v in pairs(properties) do
		for i,j in pairs(v.locations) do
			if j.name == propertyName then
				j.owner = to
			end
		end
	end
end)

function checkLock()
	ESX.TriggerServerCallback('SM_Properties:GetOwned', function(result)
		for k,v in pairs(result) do
			if v.locked == 1 then
				for i,j in pairs(properties) do
					for w,x in pairs(j.locations) do
						if v.name == x.name then
							x.locked = true
						end
					end
				end
			elseif v.locked == 0 then
				for i,j in pairs(properties) do
					for w,x in pairs(j.locations) do
						if v.name == x.name then
							x.locked = false
						end
					end
				end
			end
		end
	end)
end

function checkEmpty()
	ESX.TriggerServerCallback('SM_Properties:GetEmpty', function(result)
		if #result >= 1 then
			for k,v in pairs(result) do
				if v.empty == 1 then
					for i,j in pairs(properties) do
						for w,x in pairs(j.locations) do
							if v.name == x.name then
								x.empty = true
							end
						end
					end
				elseif v.empty == 0 then
					for i,j in pairs(properties) do
						for w,x in pairs(j.locations) do
							if v.name == x.name then
								x.empty = false
							end
						end
					end
				end
			end
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		if first then
			checkOwned()
			checkEmpty()
			checkLock()
			checkLock2()
			first = false
		end
		Citizen.Wait(500)
	end
end)

Citizen.CreateThread(function()
	
	while true do
		if IsControlJustPressed(0, 46) then
			first = true
			menu = true
		elseif IsControlJustReleased(0, 46) then
			TriggerEvent('SM_Properties:UpdateOption')
			menu = false
		end
		

		if(menu) then
			for x = 1, #props, 1 do
				local coords = GetEntityCoords(PlayerPedId())
				local distance = GetDistanceBetweenCoords(coords, props[x].x, props[x].y, props[x].z, true)
				if distance <= 2.5 then
					if props[x].locked == 0 or props[x].owner == true then
							TriggerEvent("SM_Properties:Option", "Deposit Item", {props[x].x, props[x].y, props[x].z}, 2.0, function(cb)
							if(cb) then
								OpenPlayerInventoryMenu()
							else
							end
						end)
						TriggerEvent("SM_Properties:Option", "Remove Item", {props[x].x, props[x].y, props[x].z}, 2.0, function(cb)
							if(cb) then
								OpenRoomInventoryMenu()
							else
							end
						end)
					end
					if props[x].owner == true then
						if props[x].locked == 1 then
							TriggerEvent("SM_Properties:Option", "Unlock", {props[x].x, props[x].y, props[x].z}, 2.0, function(cb)
								if(cb) then
									TriggerServerEvent('SM_Properties:UpdateStorageLock', {x = props[x].x, y = props[x].y, z = props[x].z}, 0)
									props[x].locked = 0
								else
								end
							end)
						elseif props[x].locked == 0 then
							TriggerEvent("SM_Properties:Option", "Lock", {props[x].x, props[x].y, props[x].z}, 2.0, function(cb)
								if(cb) then
									TriggerServerEvent('SM_Properties:UpdateStorageLock', {x = props[x].x, y = props[x].y, z = props[x].z}, 1)
									props[x].locked = 1
								else
								end
							end)
						end
					end
				end
			end

			for i = 1, #properties, 1 do
				for j = 1, #properties[i].locations do

					local coords = GetEntityCoords(PlayerPedId())
					local distanceEnter = GetDistanceBetweenCoords(coords, properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z, true)
					local distanceExit = GetDistanceBetweenCoords(coords, properties[i].locations[j].exit.x, properties[i].locations[j].exit.y, properties[i].locations[j].exit.z, true)

					if properties[i].locations[j].owner or properties[i].locations[j].locked == false and properties[i].locations[j].empty == false then
						if distanceEnter <= 5.0 then
							TriggerEvent("SM_Properties:Option", "Enter", {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
								if(cb) then
									inside = true
									currentProperty = properties[i].locations[j].name
									TriggerEvent("dooranim")
									Wait(750)
									DoScreenFadeOut(1)
									Citizen.Wait(1500)
									SetEntityCoords(GetPlayerPed(-1), properties[i].locations[j].inside.x, properties[i].locations[j].inside.y, properties[i].locations[j].inside.z)
									SetEntityHeading(GetPlayerPed(-1), properties[i].locations[j].inside.h)
									SetEntityVisible(GetPlayerPed(-1), true)
									SetEntityAlpha(PlayerPedId(), 255, false)
									TriggerServerEvent('SM_Properties:updateSpawned')
									DoScreenFadeIn(1)
								else
								end
							end)
						end
					end

					if properties[i].locations[j].owner then				
						if distanceEnter <= 5.0 then
							if properties[i].locations[j].locked == true then 
								TriggerEvent("SM_Properties:Option", "Unlock Door ", {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
									if(cb) then
										TriggerEvent("dooranim")
										Wait(750)
										properties[i].locations[j].locked = false
										TriggerServerEvent('SM_Properties:UpdatePropertyLock', properties[i].locations[j].name, 0)
									else
									end
								end)
							elseif properties[i].locations[j].locked == false then
								TriggerEvent("SM_Properties:Option", "Lock Door", {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
									if(cb) then
										TriggerEvent("dooranim")
										Wait(750)
										properties[i].locations[j].locked = true
										TriggerServerEvent('SM_Properties:UpdatePropertyLock', properties[i].locations[j].name, 1)
									else
									end
								end)
							end
							if properties[i].tier == "low" then
								TriggerEvent("SM_Properties:Option", "Sell house", {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
									if(cb) then
										menu = false
										TriggerEvent('SM_Properties:UpdateOption')
										AddTextEntry('FMMC_KEY_TIP1', "Are you sure you wanna sell your home? This will remove all furniture in the house.")
										DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 3)
										blockinput = true
										
										while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
											Citizen.Wait(0)
										end
											
										if UpdateOnscreenKeyboard() ~= 2 then
											local result = GetOnscreenKeyboardResult()
											Citizen.Wait(500)
											if result == "y" or result == "yes" or result == "ye" then
												TriggerEvent("dooranim")
												Wait(750)
												TriggerServerEvent('SM_Properties:SellProperty', properties[i].locations[j].name)
												exports['mythic_notify']:DoHudText('error', 'We are sad to see you go.')
												blockinput = false
											elseif result == "n" or result == "no" then
												exports['mythic_notify']:DoHudText('error', 'We are glad to see you stay.')
												blockinput = false
											end
										else
											Citizen.Wait(500)
											blockinput = false
											exports['mythic_notify']:DoHudText('error', 'We are glad to see you stay.')
										end
									else
									end
								end)
							end
						end
					end

					if properties[i].locations[j].empty then
						if distanceEnter <= 5.0 then
							TriggerEvent("SM_Properties:Option", "Look at place", {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
								if(cb) then
									TriggerEvent("dooranim")
									Wait(750)
									DoScreenFadeOut(1)
									Citizen.Wait(1500)
									SetEntityCoords(GetPlayerPed(-1), properties[i].locations[j].inside.x, properties[i].locations[j].inside.y, properties[i].locations[j].inside.z)
									SetEntityHeading(GetPlayerPed(-1), properties[i].locations[j].inside.h)
									DoScreenFadeIn(1)
								else
								end
							end)
							TriggerEvent("SM_Properties:Option", "Buy $" .. properties[i].locations[j].price, {properties[i].locations[j].enter.x, properties[i].locations[j].enter.y, properties[i].locations[j].enter.z}, 2.0, function(cb)
								if(cb) then
									TriggerServerEvent('SM_Properties:BuyProperty', properties[i].locations[j].name)
									TriggerEvent('SM_Properties:UpdateOption')
								else
								end
							end)
						end
					end

					if distanceExit <= 3.0 then
						TriggerEvent("SM_Properties:Option", "Exit", {properties[i].locations[j].exit.x, properties[i].locations[j].exit.y, properties[i].locations[j].exit.z}, 2.0, function(cb)
							if(cb) then
								inside = false
								currentProperty = nil
								TriggerEvent("dooranim")
								Wait(750)
								DoScreenFadeOut(1)
								Citizen.Wait(1500)
								SetEntityCoords(GetPlayerPed(-1), properties[i].locations[j].outside.x, properties[i].locations[j].outside.y, properties[i].locations[j].outside.z)
								SetEntityHeading(GetPlayerPed(-1), properties[i].locations[j].outside.h)
								for k, v in pairs(props) do
									if v.property == currentProperty then
										DeleteObject(Prop)
									end
									currentProperty = nil
								end
								DoScreenFadeIn(1)
							else
							end
						end)
						if properties[i].locations[j].owner then				
							if properties[i].locations[j].locked == true then 
								TriggerEvent("SM_Properties:Option", "Unlock Door", {properties[i].locations[j].exit.x, properties[i].locations[j].exit.y, properties[i].locations[j].exit.z}, 2.0, function(cb)
									if(cb) then
										TriggerEvent("dooranim")
										Wait(750)
										properties[i].locations[j].locked = false
										TriggerServerEvent('SM_Properties:UpdatePropertyLock', properties[i].locations[j].name, 0)
									else
									end
								end)
							elseif properties[i].locations[j].locked == false then
								TriggerEvent("SM_Properties:Option", "Lock Door", {properties[i].locations[j].exit.x, properties[i].locations[j].exit.y, properties[i].locations[j].exit.z}, 2.0, function(cb)
									if(cb) then
										TriggerEvent("dooranim")
										Wait(750)
										properties[i].locations[j].locked = true
										TriggerServerEvent('SM_Properties:UpdatePropertyLock', properties[i].locations[j].name, 1)
									else
									end
								end)
							end
						end
					end
				end
			end
			TriggerEvent("SM_Properties:Update")
		end

		Wait(0)
	end
end)


----- Furniture -----

local update = false

Furniture = {
	{type = "Storage", items = {
		{name = "safe", maxAmount = 10, propName = "p_v_43_safe_s"}
	}},
}

RegisterNetEvent('spawnCheck')
AddEventHandler('spawnCheck', function(name, x, y, z, r, currentAmount, selected, owner, locked, property)
	local prop = CreateObject(GetHashKey(name), x, y, z - 0.75, false, true, false)
	FreezeEntityPosition(prop, true)
	SetEntityHeading(prop, ToFloat(r))
	local test = GetEntityCoords(prop, false)
	if owner == ESX.GetPlayerData().identifier then
		table.insert(props, {Prop = prop, name = name, x = x, y = y, z = z, rotation = r, owner = true, selected = false, currentAmount = currentAmount, locked = locked, property = property})
	else
		table.insert(props, {Prop = prop, name = name, x = x, y = y, z = z, rotation = r, owner = false, selected = false, currentAmount = currentAmount, locked = locked, property = property})
	end
end)

RegisterNetEvent('SM_Properties:updateStorageLock')
AddEventHandler('SM_Properties:updateStorageLock', function(coords, to)
	for f,L in pairs (props) do
		local coords = GetEntityCoords(PlayerPedId())
		local distance = GetDistanceBetweenCoords(coords, L.x, L.y, L.z, true)
		if distance <= 1.25 then
			L.locked = to
		end
	end
end)

local function removeKey(table, key)
 
	table[key] = nil
   
end

RegisterNetEvent('SM_Properties:deleteObjectsOnSell')
AddEventHandler('SM_Properties:deleteObjectsOnSell', function(propertyName)
	for f,L in pairs (props) do
		if L.property == propertyName then
			DeleteObject(L.Prop)
			removeKey(props, f)
		end
	end
end)

function pickup()
	for k,v in pairs (props) do
		for q,r in pairs (Furniture) do
			for t,y in pairs (r.items) do
				local coords = GetEntityCoords(PlayerPedId())
				local distance = GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true)

				if distance <= 2 then
					v.selected = true
					TriggerServerEvent('SM_Properties:updateSelected', { x = v.x, y = v.y, z = v.z, r = v.rotation}, y.name, 1)
					SetEntityAlpha(v.Prop, 120)
					SetEntityCollision(v.Prop, false, false)
					drawing = true
					update = true
				end
			end
		end
	end
end

function create(propName, spawnName)
	local userCoords = GetEntityCoords(GetPlayerPed(-1))
	local heading = GetEntityHeading(GetPlayerPed(-1))
	local xVector = forward * math.sin(math.rad(heading)) * -1.0000
	local yVector = forward * math.cos(math.rad(heading))
	local u, Z = GetGroundZFor_3dCoord(userCoords.x + xVector, userCoords.y + yVector, 300.0,0)
	local prop = CreateObject(GetHashKey(propName), userCoords.x + xVector, userCoords.y + yVector, userCoords.z, true, true, true)

	SetEntityAlpha(prop, 120)
	SetEntityCollision(prop, false, true)
	table.insert(props, {Prop = prop, spawnname = spawnName, name = propName, x = userCoords.x + xVector, y =userCoords.y + yVector, z = userCoords.z, rotation = 0.0, owner = true, selected = true, currentAmount = 0, locked = 1, property = currentProperty})
	drawing = true
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if drawing then
			if inside then
				local userCoords = GetEntityCoords(GetPlayerPed(-1))
				local heading = GetEntityHeading(GetPlayerPed(-1))
				local xVector = forward * math.sin(math.rad(heading)) * -1.0000
				local yVector = forward * math.cos(math.rad(heading))

				for k, v in pairs (props) do
					if v.selected == true then
						SetEntityCoords(v.Prop, userCoords.x + xVector, userCoords.y + yVector, userCoords.z + up)
						SetEntityHeading(v.Prop, rotate)

						Draw3DText(userCoords.x + xVector, userCoords.y + yVector, userCoords.z + up, "Press ~g~ Enter ~w~ to place.")
						Draw3DText(userCoords.x + xVector, userCoords.y + yVector, userCoords.z + 0.3 + up, "Press ~g~ ESC ~w~ to cancel.")
					end
				end

				if IsControlJustPressed(0, 191) then
					for k, v in pairs (props) do
						for q,r in pairs (Furniture) do
							for t,y in pairs (r.items) do
								if v.selected == true then
									drawing = false
									SetEntityAlpha(v.Prop, 255)
									FreezeEntityPosition(v.Prop, true)
									SetEntityCollision(v.Prop, true, true)
									SetEntityHeading(v.Prop, rotate)
									v.x = userCoords.x + xVector
									v.y = userCoords.y + yVector
									v.z = userCoords.z + up
									v.rotation = rotate
									if update == true then
										if v.selected == true then
											TriggerServerEvent('SM_Properties:updateProp', { x = v.x, y = v.y, z = v.z, r = v.rotation}, 0)
											v.selected = false
											update = false
										end
									elseif update == false then
										TriggerServerEvent('SM_Properties:addProp', v.name, { x = v.x, y = v.y, z = v.z, r = v.rotation}, 0, "{}", 0, 0, currentProperty)
										v.selected = false
									end
								end
							end
						end
					end
				elseif IsControlJustPressed(0, 200) then
					for k, v in pairs (props) do
						for q,r in pairs (Furniture) do
							for t,y in pairs (r.items) do
								if v.selected == true then
									if update == true then
										drawing = false
										SetEntityCoords(v.Prop, v.x, v.y, v.z)
										SetEntityAlpha(v.Prop, 255)
										FreezeEntityPosition(v.Prop, true)
										SetEntityCollision(v.Prop, true, true)
										SetEntityHeading(v.Prop, v.rotation)
										v.selected = false
										update = false
										TriggerServerEvent('SM_Properties:updateSelected', { x = v.x, y = v.y, z = v.z, r = v.rotation}, y.name, 0)
									else
										TriggerServerEvent('SM_Properties:addPropBack', v.spawnname)
										drawing = false
										DeleteObject(v.Prop)
										table.remove(props, k)
									end
								end
							end
						end
					end
				end
			end
        end
    end
end)

RegisterNetEvent('createClient')
AddEventHandler('createClient', function(name, spawnName)
	create(name, spawnName)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if drawing then   
            if IsControlJustPressed(0, 111) then
                if forward >= 0 and forward < 2.0 then
                    forward = forward + 0.25
                elseif forward == 2.0 then
                    forward = 0
                end
            elseif IsControlJustPressed(0, 126) then
                if forward > 0 then
                    forward = forward - 0.25
                elseif forward == 0 then
                    forward = 2.0
				end
			elseif IsControlJustPressed(0, 174) then
                if rotate < 360 then
					rotate = rotate + 2.5
				end
			elseif IsControlJustPressed(0, 175) then
				if rotate > -360 then
                    rotate = rotate - 2.5
				end
			elseif IsControlJustPressed(0, 172) then
				if up < 1.25 then
					up = up + 0.125
				elseif up == 1.25 then
					up = -1
				end
			end
        end
    end
end)

function checkLock2()
	ESX.TriggerServerCallback('SM_Properties:GetLock', function(result)
		for k, v in pairs(props) do
			for j, i in pairs(result) do
				if i.x == v.x and i.y == v.y and i.z == v.z then
					if v.locked ~= i.locked then
						v.locked = i.locked
					end
				end
			end
		end
	end)
end

--[[RegisterCommand('helloooo', function()
	TriggerServerEvent('SM_Properties:updateSpawned')
end)]]

---- inventorys ----
function OpenPlayerInventoryMenu()
	ESX.TriggerServerCallback('SM_Properties:getPlayerInventory', function(inventory)
		for k,v in pairs(properties) do
			for i,j in pairs(v.locations) do
				for x,w in pairs(props) do
					local coords = GetEntityCoords(PlayerPedId())
					local distance = GetDistanceBetweenCoords(coords, w.x, w.y, w.z, true)
	
					if distance <= 2 then
						local elements = {}

						if inventory.money > 0 then
							table.insert(elements, {
								label = 'Cash $' .. ESX.Math.GroupDigits(inventory.money),
								type  = 'item_money',
								label2 = 'Cash',
								value = 'cash'
							})
						end

						for i=1, #inventory.items, 1 do
							local item = inventory.items[i]

							if item.count > 0 then
								table.insert(elements, {
									label = item.label .. ' x' .. item.count,
									type  = 'item_standard',
									label2 = item.label,
									value = item.name
								})
							end
						end

						for i=1, #inventory.weapons, 1 do
							local weapon = inventory.weapons[i]

							table.insert(elements, {
								label = weapon.label .. ' [' .. weapon.ammo .. ']',
								type  = 'item_weapon',
								value = weapon.name,
								label2 = weapon.label,
								ammo  = weapon.ammo
							})
						end

						ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_inventory', {
							title    = j.name .. ' - ' .. 'inventory',
							align    = 'top-right',
							elements = elements
						}, function(data, menu)

							if data.current.type == 'item_weapon' then
								menu.close()
								TriggerServerEvent('SM_Properties:putItem', {x = w.x, y = w.y, z = w.z}, data.current.type, data.current.value, data.current.label2, data.current.ammo)
							else
								ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'put_item_count', {
									title = 'amount'
								}, function(data2, menu2)
									local quantity = tonumber(data2.value)

									if quantity == nil then
										ESX.ShowNotification('amount_invalid')
									else
										menu2.close()
										TriggerServerEvent('SM_Properties:putItem', {x = w.x, y = w.y, z = w.z}, data.current.type, data.current.value, data.current.label2, tonumber(data2.value))
									end
								end, function(data2, menu2)
									menu2.close()
								end)
							end
						end, function(data, menu)
							menu.close()
						end)
					end
				end
			end
		end
	end)
end

function distanceCheck()
	for i = 1, #props, 1 do
		local coords = GetEntityCoords(PlayerPedId())
		local distance = GetDistanceBetweenCoords(coords, props[i].x, props[i].y, props[i].z, true)

		if distance <= 1.5 then
			local coords2send = {x = props[i].x, y = props[i].y, z = props[i].z}
			return coords2send
		end
	end
end

function OpenRoomInventoryMenu()
	ESX.TriggerServerCallback('SM_Properties:getPropertyInventory', function(inventory)
		for k,v in pairs(properties) do
			for i,j in pairs(v.locations) do
				for x,w in pairs(props) do
						local coords = GetEntityCoords(PlayerPedId())
						local distance = GetDistanceBetweenCoords(coords, w.x, w.y, w.z, true)
		
						if distance <= 2 then
							local elements = {}

							if inventory.money > 0 then
								table.insert(elements, {
									label = "Cash $" .. ESX.Math.GroupDigits(inventory.money),
									type = 'item_money',
									value = "cash"
								})
							end

							for i=1, #inventory.items, 1 do
								local item = inventory.items[i]

								if item.count > 0 then
									table.insert(elements, {
										label = item.label .. ' x' .. item.count,
										type = 'item_standard',
										value = item.name
									})
								end
							end

							for i=1, #inventory.weapons, 1 do
								local weapon = inventory.weapons[i]

								table.insert(elements, {
									label = ESX.GetWeaponLabel(weapon.name) .. " x" .. weapon.amount .. ' [' .. weapon.ammo .. ']',
									type  = 'item_weapon',
									value = weapon.name,
								})
							end

							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room_inventory', {
								title    = j.name .. ' - ' .. 'inventory',
								align    = 'top-right',
								elements = elements
							}, function(data, menu)

								if data.current.type == 'item_weapon' then
									menu.close()

									TriggerServerEvent('SM_Properties:getItem', {x = w.x, y = w.y, z = w.z}, data.current.type, data.current.value, data.current.index)
									ESX.SetTimeout(300, function()
										OpenRoomInventoryMenu()
									end)
								else
									ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'get_item_count', {
										title = 'amount'
									}, function(data2, menu)

										local quantity = tonumber(data2.value)
										if quantity == nil then
											ESX.ShowNotification('amount_invalid')
										else
											menu.close()

											TriggerServerEvent('SM_Properties:getItem', {x = w.x, y = w.y, z = w.z}, data.current.type, data.current.value, quantity)
											ESX.SetTimeout(300, function()
												OpenRoomInventoryMenu()
											end)
										end
									end, function(data2,menu)
										menu.close()
									end)
								end
							end, function(data, menu)
								menu.close()
							end)	
						end
					end
				end
			end
		end, distanceCheck())
end
----------------------------

function Draw3DText(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
	if onScreen then
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextDropShadow(0, 0, 0, 55)
		SetTextEdge(0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

-- Create Blips
Citizen.CreateThread(function()
	for k,v in pairs(properties) do
		for i,j in pairs(v.locations) do
			local blip = AddBlipForCoord(j.enter.x, j.enter.y, j.enter.z)

			SetBlipSprite (blip, 357)
			SetBlipScale  (blip, 1.0)
			SetBlipColour (blip, 2)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(j.label)
			EndTextCommandSetBlipName(blip)
		end
	end
end)