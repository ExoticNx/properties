GUI = {}
Menu = {}

Menus = {}

GUI.maxVisOptions = 10

GUI.titleText = {255, 255, 255, 255, 7}
GUI.titleRect = {52, 73, 94, 255}
GUI.optionRect = {40, 40, 40, 190}

GUI.optionText = {255,255,255, 255}
GUI.scroller = {70, 130, 180, 240}

local menuOpen = false
local prevMenu = nil
local curMenu = nil
local titleTextSize = {0.85, 0.85}
local titleRectSize = {0.23, 0.085}
local optionTextSize = {0.5, 0.5}
local optionRectSize = {0.23, 0.035}
local menuX = 0.7
local menuYModify = 0.3174 -- Default: 0.1174
local menuYOptionDiv = 9.1 -- Default: 3.56
local menuYOptionAdd = 0.342 -- Default: 0.142
local selectPressed = false
local leftPressed = false
local rightPressed = false
local currentOption = 1
local optionCount = 0

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function Menu.IsOpen() 
	return menuOpen == true
end

function Menu.UpdateOption() 
	CurrentOption = 1
end

function Menu.SetupMenu(menu, title)
	Menus[menu] = {}
	Menus[menu].title = title
	Menus[menu].optionCount = 0
	Menus[menu].options = {}
	currentOption = 1
end

function Menu.addOption(menu, option)
	if not (Menus[menu].title == nil) then
		Menus[menu].optionCount = Menus[menu].optionCount + 1
		Menus[menu].options[Menus[menu].optionCount] = option
	end
end

function Menu.Switch(prevmenu, menu)
	curMenu = menu
	prevMenu = prevmenu
end

function Menu.DisplayCurMenu()
	if not (curMenu == "") then
		menuOpen = true
		Menu.Title(Menus[curMenu].title)
		for k,v in pairs(Menus[curMenu].options) do
			v()
		end
		Menu.updateSelection()
	end
end

function GUI.Text(text, color, position)
	--print("option count : " .. optionCount .. " Current Option : " .. currentOption)
    local onScreen,_x,_y=World3dToScreen2d(position[1],position[2],position[3])
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.40, 0.40)
    SetTextFont(1)
    SetTextProportional(1)
    SetTextDropshadow(500, 255, 255, 255, 255)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
end

function Menu.Option(option, coords, distanceAmount)
	optionCount = optionCount + 1
	local playerpos = GetEntityCoords(GetPlayerPed(-1), 1)
	local distance = GetDistanceBetweenCoords(coords[1], coords[2], coords[3], playerpos.x, playerpos.y, playerpos.z, 1)
	if distance < distanceAmount then

		local thisOption = nil
		if(currentOption == optionCount) then
			thisOption = true
		else
			thisOption = false
		end

		if (optionCount > currentOption - GUI.maxVisOptions and optionCount <= currentOption) then
			GUI.Text(option, GUI.scroller, {coords[1], coords[2], coords[3] + 0.3 - (optionCount * 0.10)})
			if(thisOption) then
				GUI.Text(option, GUI.optionText, {coords[1], coords[2], coords[3] + 0.3 - (optionCount * 0.10)})
			end
		elseif(currentOption <= GUI.maxVisOptions and optionCount <= GUI.maxVisOptions) then
			GUI.Text(option, GUI.scroller, {coords[1], coords[2], coords[3] + 0.3 - (optionCount * 0.10)})
			if(thisOption) then
				GUI.Text(option, GUI.optionText, {coords[1], coords[2], coords[3] + 0.3 - (optionCount * 0.10)})
			end
		end

		if (optionCount == currentOption and selectPressed) then
			return true
		end

		return false
	end
end

function Menu.changeMenu(option, menu)
	if (Menu.Option(option)) then
		Menu.Switch(curMenu, menu)
	end

	if(currentOption <= GUI.maxVisOptions and optionCount <= GUI.maxVisOptions) then
		GUI.Text(">>", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + (optionCount / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	elseif(optionCount > currentOption - GUI.maxVisOptions and optionCount <= currentOption) then
		GUI.Text(">>", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + ((optionCount - (currentOption - GUI.maxVisOptions)) / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	end

	if (optionCount == currentOption and selectPressed) then
		return true
	end

	return false
end

function Menu.Bool(option, bool, cb)
	Menu.Option(option)

	if(currentOption <= GUI.maxVisOptions and optionCount <= GUI.maxVisOptions) then
		if(bool) then
			GUI.Text("~g~ON", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + (optionCount / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
		else
			GUI.Text("~r~OFF", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + (optionCount / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
		end
	elseif(optionCount > currentOption - GUI.maxVisOptions and optionCount <= currentOption) then
		if(bool) then
			GUI.Text("~g~ON", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + ((optionCount - (currentOption - GUI.maxVisOptions)) / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
		else
			GUI.Text("~r~OFF", GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + ((optionCount - (currentOption - GUI.maxVisOptions)) / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
		end
	end

	if (optionCount == currentOption and selectPressed) then
		cb(not bool)
		return true
	end

	return false
end

function Menu.Int(option, int, min, max, cb)
	Menu.Option(option);

	if (optionCount == currentOption) then
		if (leftPressed) then
			if(int > min) then int = int - 1 else int = max end-- : _int = max;
		end
		if (rightPressed) then
			if(int < max) then int = int + 1 else int = min end
		end
	end

	if (currentOption <= GUI.maxVisOptions and optionCount <= GUI.maxVisOptions) then
		GUI.Text(tostring(int), GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + (optionCount / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	elseif (optionCount > currentOption - GUI.maxVisOptions and optionCount <= currentOption) then
		GUI.Text(tostring(int), GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + ((optionCount - (currentOption - GUI.maxVisOptions)) / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	end

	if (optionCount == currentOption and selectPressed) then cb(position) return true
    elseif (optionCount == currentOption and leftPressed) then cb(position)
    elseif (optionCount == currentOption and rightPressed) then cb(position) end

	return false
end

function Menu.StringArray(option, array, position, cb)

	Menu.Option(option);

	if (optionCount == currentOption) then
		local max = tablelength(array)
		local min = 1
		if (leftPressed) then
			if(position > min) then position = position - 1 else position = max end
		end
		if (rightPressed) then
			if(position < max) then position = position + 1 else position = min end
		end
	end

	if (currentOption <= GUI.maxVisOptions and optionCount <= GUI.maxVisOptions) then
		GUI.Text(array[position], GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + (optionCount / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	elseif (optionCount > currentOption - GUI.maxVisOptions and optionCount <= currentOption) then
		GUI.Text(array[position], GUI.optionText, { menuX + 0.068, ((menuYOptionAdd - 0.018) + ((optionCount - (currentOption - GUI.maxVisOptions)) / menuYOptionDiv) * menuYModify)}, optionTextSize, true)
	end

	if (optionCount == currentOption and selectPressed) then cb(position) return true
    elseif (optionCount == currentOption and leftPressed) then cb(position)
    elseif (optionCount == currentOption and rightPressed) then cb(position) end

	return false
end


function Menu.updateSelection()
	selectPressed = false;
	leftPressed = false;
	rightPressed = false;

	if IsControlJustPressed(1, 173)  then
		if(currentOption < optionCount) then
			currentOption = currentOption + 1
		else
			currentOption = 1
		end
	elseif IsControlJustPressed(1, 172) then
		if(currentOption > 1) then
			currentOption = currentOption - 1
		else
			currentOption = optionCount
		end
	elseif IsControlJustPressed(1, 174) then
		leftPressed = true
	elseif IsControlJustPressed(1, 175) then
		rightPressed = true
	elseif IsControlJustPressed(1, 176)  then
		selectPressed = true
	elseif IsControlJustPressed(1, 177) then
		if (prevMenu == nil) then
			Menu.Switch(nil, "")
			menuOpen = false
		end
		if not (prevMenu == nil) then
			Menu.Switch(nil, prevMenu)
		end
	end
	optionCount = 0
end