-- Table of all objects that you can interact with
objects = { }

-- Table of all vehicle that can receive object
vehicles = { }

-- Object Variables
ObjectsisBeingHeld = { }
ObjectsRestriction = { }
ObjectsCanDespawn = { }

-- Vehicle Variables
VehiclesStorageObjects = { }
VehiclesRestriction = { }
VehiclesStorageLocationY = { }
VehiclesStorageLocationX = { }
VehiclesStorageLocationXEachLine = { }

-- Player Variables
PlayersSteamAuth = { }

-- If the despawn setting is activated, start the timer that will loop
function OnPackageStart()
	print("NANO's Object Interaction package loaded...")
	if enableObjectDespawn == true then
		local despawnTimer = CreateTimer(function() 
			LookForDespawnableObject()
			print("DespawnObject Event...")
		end, despawnTimerTime)
	end
end
AddEvent("OnPackageStart", OnPackageStart)

function OnPlayerJoin(player)
	-- Set where the player is going to spawn. (TEMPORARY)
	-- Note: you can remove this next line if you have an already set spawn location
	SetPlayerSpawnLocation(player, 125773.000000, 80246.000000, 1645.000000, 90.0)
	-- Set the player objectInHand property value
	SetPlayerPropertyValue(player, "objectInHand", nil)
end
AddEvent("OnPlayerJoin", OnPlayerJoin)

-- Drop the item on the ground when the player leave the server
function OnPlayerQuit(player)
	ForceDrop(player)
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function OnPlayerDeath(player, instigator)
	ForceDrop(player)
	SetPlayerPropertyValue(player, "objectInHand", nil)
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

function ForceDrop(playerid)
	local object = GetPlayerPropertyValue(playerid, "objectInHand")
	if object ~= nil then
		local playerX, playerY, playerZ = GetPlayerLocation(playerid)
		local playerHeading = GetPlayerHeading(playerid)
		local Vx, Vy, Vz = GetPlayerForward(playerid)
		SetObjectDetached(object)
		SetObjectLocation(object, playerX + (Vx * 80), playerY + (Vy * 80), playerZ - 100)
		SetObjectRotation(object, 0, playerHeading, 0)
		ChangeTableRowValue(ObjectsisBeingHeld, object, false)
		if enableObjectDespawn == true then
			EnableObjectDespawn(object)
		end
	end
end

-- If the despawn setting is activated, start the timer that will loop
function OnPlayerSteamAuth(playerid)
	table.insert(PlayersSteamAuth, {playerid, true})
end
AddEvent("OnPlayerSteamAuth", OnPlayerSteamAuth)

-- Client asking the server to pickup an object
AddRemoteEvent("OnClientPickup", function(playerid)
	CanPlayerPickup(playerid)
end)

-- Function that make the player pickup the object
function PickUp(playerid, object)
	SetPlayerPropertyValue(playerid, "objectInHand", object)
	ChangeTableRowValue(ObjectsisBeingHeld, object, true)
	local anim, sizeX, sizeY, sizeZ = GetObjectValue(object)
	local animation = GetAnimationValue(anim)
	local offsetX = animation[2][3]
	local offsetY = animation[2][4]
	local offsetZ = animation[2][5]
	local offsetRx = animation[2][6]
	local offsetRy = animation[2][7]
	local offsetRz = animation[2][8]
	local playerBone = animation[2][9]
	SetAnimation(playerid, animation[1])
	if enableObjectDespawn == true then
		DisableObjectDespawn(object)
	end
	Delay(1000, function() 
		-- Little fix for a bug, when an object is attach it still stays physically at the place before being attached.
		if IsObjectAttached(object) == true then
			SetObjectDetached(object)
		end
		Delay(100, function() SetObjectAttached(object, ATTACH_PLAYER, playerid, offsetX, offsetY, offsetZ, offsetRx, offsetRy, offsetRz, playerBone) end)
		SendClientActivateLoadLocation(playerid)
		SetAnimation(playerid, animation[2])
	end)
end

-- Client asking the server to drop an object
AddRemoteEvent("OnClientDrop", function(playerid)
	CanPlayerDrop(playerid)
end)

-- Function that make the player drop the object
function Drop(playerid, object)
	local playerX, playerY, playerZ = GetPlayerLocation(playerid)
	local playerHeading = GetPlayerHeading(playerid)
	local anim, sizeX, sizeY, sizeZ = GetObjectValue(object)
	local animation = GetAnimationValue(anim)
	local offsetX = animation[3][3]
	local offsetY = animation[3][4]
	local offsetZ = animation[3][5]
	local offsetRx = animation[3][6]
	local offsetRy = animation[3][7]
	local offsetRz = animation[3][8]
	local playerBone = animation[3][9]
	local Vx, Vy, Vz = GetPlayerForward(playerid)
	SetAnimation(playerid, animation[3])
	--SetObjectDetached(object)
	SetObjectAttached(object, ATTACH_PLAYER, playerid, offsetX, offsetY, offsetZ, offsetRx, offsetRy, offsetRz, playerBone)
	Delay(1000, function() 
		SetObjectDetached(object)
		SetObjectLocation(object, playerX + (Vx * 80) + (Vx * (sizeX/2)), playerY + (Vy * 80) + (Vy * (sizeY/2)), playerZ - 100)
		SetObjectRotation(object, 0, playerHeading, 0)
		SetPlayerPropertyValue(playerid, "objectInHand", nil)
		ChangeTableRowValue(ObjectsisBeingHeld, object, false)
		SendClientCancelLoadLocation(playerid)
		if enableObjectDespawn == true then
			EnableObjectDespawn(object)
		end
		SetAnimation(playerid, animation[4])
	end)
end

-- Client asking the server to load an object inside a vehicle
AddRemoteEvent("OnClientLoad", function(playerid)
	CanPlayerLoad(playerid)
end)

-- Client asking the server to unload an object from a vehicle
AddRemoteEvent("OnClientUnload", function(playerid)
    CanPlayerUnLoad(playerid)
end)

-- Called when a player enter a vehicle
AddEvent("OnPlayerEnterVehicle", function(playerid, vehicle, seat)
	-- If the player is holding an object, we force him to drop it.
	if GetPlayerPropertyValue(playerid, "objectInHand") ~= nil then
		ForceDropFromVehicle(playerid, seat)
		AddPlayerChat(playerid, "The object you were holding was dropped on the ground.")
	end
end)

-- We calculate where to drop the object (depending on which seat of the vehicle the player got on)
function ForceDropFromVehicle(playerid, seat)
	local object = GetPlayerPropertyValue(playerid, "objectInHand")
	local playerX, playerY, playerZ = GetPlayerLocation(playerid)
	local vehicle = GetPlayerVehicle(playerid)
	local vehicleHeading = GetVehicleHeading(vehicle)
	local rad
	if seat % 2 ~= 0 then
		rad = math.rad(vehicleHeading - 90)
	else
		rad = math.rad(vehicleHeading + 90)
	end
	local Vx = math.cos(rad)
	local Vy = math.sin(rad)
	SetObjectDetached(object)
	SetObjectLocation(object, playerX + (Vx * 150), playerY + (Vy * 150), playerZ)
	SetObjectRotation(object, 0, 0, 0)
	SetPlayerPropertyValue(playerid, "objectInHand", nil)
	ChangeTableRowValue(ObjectsisBeingHeld, object, false)
	SendClientCancelLoadLocation(playerid)
	if enableObjectDespawn == true then
		EnableObjectDespawn(object)
	end
end

-- We set the player animation to STOP once he is leaving the vehicle (TEMPORARY)
-- Note: This is due to a "bug" that make is so we cannot reset the player animation in the OnPlayerEnterVehicle. 
-- If this next line of code is removed, the player will keep the holding object animation upon leaving the vehicle.
AddEvent("OnPlayerLeaveVehicle", function(playerid, vehicle, seat)
	SetPlayerAnimation(playerid, "STOP")
end)

-- Look if the player has the right to interact.
function RightToInteract(playerid, restriction)
	local allowPlayer = false
	if GetTableRowValue(PlayersSteamAuth, playerid) == true then
		for index, value in pairs(restriction) do
			if value == tostring(GetPlayerSteamId(playerid)) then
				allowPlayer = true
			end
		end
	end
	return allowPlayer
end

-- Function that is called in the despawn timer, we are looking at all the interactable objects to see if they can despawn.
function LookForDespawnableObject()
	local objectsToRemove = { }
	for index, value in pairs(objects) do
		local canDespawn = GetTableRowValue(ObjectsCanDespawn, value)
		if canDespawn[1] == true then
			local time = canDespawn[2] - despawnTimerTime
			if time <= 0 then
				table.insert(objectsToRemove, value)
			else
				ChangeTableRowValue(ObjectsCanDespawn, object, {true, time})
			end
			
		end
	end
	local empty = false
	local length = tablelength(objectsToRemove)
	if length ~= 0 then
		for index, value in pairs(objectsToRemove) do
			print("Removing object: "..value.."")
			RemoveObject(value)
			DestroyObject(value)
		end
	end
end

-- Disable an object despawn
function DisableObjectDespawn(object)
	ChangeTableRowValue(ObjectsCanDespawn, object, {false, objectDespawnTime})
end

-- Enable an object despawn
function EnableObjectDespawn(object)
	local canDespawn = GetTableRowValue(ObjectsCanDespawn, object)
	ChangeTableRowValue(ObjectsCanDespawn, object, {true, canDespawn[2]})
end

-- Send the client the information that he need to show the load location of his vehicle
function SendClientActivateLoadLocation(playerid)
	CallRemoteEvent(playerid, "OnReceivingStartLoadLocation")
end

-- Send the client the information that he need to stop showing the load location of his vehicle
function SendClientCancelLoadLocation(playerid)
	CallRemoteEvent(playerid, "OnReceivingCancelLoadLocation")
end

-- We get the vehicle trunk location by his heading
function GetVehicleLoadLocation(vehicle)
	if vehicle ~= nil then
		local trunkOffset = GetVehiclePropertyValue(vehicle, "trunkOffset")
		local Vx, Vy, Vz = GetVehicleForward(vehicle)
		local x,y,z = GetVehicleLocation(vehicle)
		local trunkLocationX = x + (Vx * trunkOffset)
		local trunkLocationY = y + (Vy * trunkOffset)
		return trunkLocationX, trunkLocationY, z
	end
	return nil
end

-- Return the length of a table
function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
  end

-- Calculate the Vector Forward of the player by his heading
function GetPlayerForward(playerid)
	local deg = GetPlayerHeading(playerid)
	local rad = math.rad(deg)
	local x = math.cos(rad)
	local y = math.sin(rad)
	return x, y, 0
end

-- Calculate the Vector Forward of the vehicle by his heading
function GetVehicleForward(vehicle)
	local deg = GetVehicleHeading(vehicle)
	local rad = math.rad(deg)
	local x = math.cos(rad)
	local y = math.sin(rad)
	return x, y, 0
end

-- Find the nearest object that can be interacted with
function GetNearestObject(player)
	local found = nil
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(player)

	for _,o in pairs(objects) do
		if GetTableRowValue(ObjectsisBeingHeld, o) == false then
			local x2, y2, z2 = GetObjectLocation(o)
			local dist = GetDistance3D(x, y, z, x2, y2, z2)
			if dist < nearest_dist then
				nearest_dist = dist
				found = o
			end
		end
	end
	return found, nearest_dist
end

-- Find the nearest vehicle that can be interacted with
function GetNearestVehicle(player)
	local found = nil
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(player)

	for _,v in pairs(vehicles) do
		local x2, y2, z2 = GetVehicleLocation(v)
		local dist = GetDistance3D(x, y, z, x2, y2, z2)
		if dist < nearest_dist then
			nearest_dist = dist
			found = v
		end
	end
	return found, nearest_dist
end

-- Set the correct animation 
function SetAnimation(playerid, animationName)
	local animation
	if animationName ~= nil then
		animation = animationName[2]
		SetPlayerAnimation(playerid, animation)
		return true
	else
		print("Trying to play an invalid animation for player: "..playerid.."")
	end
end

-- Return the highest value in a table
function GetHighestValueInTable(T)
	local currentHighest = 0
	for index,value in pairs(T) do
	  if value > currentHighest then
		currentHighest = value
	  end
	end
	return currentHighest
  end

-- Find the object value from the objects table list. If the object is not from the list, it will return nil.
function GetObjectValue(object)
    for index, value in pairs(objectsList) do
        if value[1] == GetObjectModel(object) then
            return value[2], value[3], value[4], value[5]
        end
    end
    return nil
end

-- Find the vehicle value from the vehicles table list. If the vehicle is not from the list, it will return nil.
function GetVehicleValue(vehicle)
    local vehicleModel = GetVehicleModel(vehicle)
    for index, value in pairs(vehiclesList) do
        if value[1] == vehicleModel then
            return value[3], value[4], value[5], value[6], value[7], value[8], value[9], value[10]
        end
    end
    return nil
end

-- Find the animation value from the animationSetsList table list. If the animation is not from the list, it will return nil.
function GetAnimationValue(animation)
	local animationSet
	local anim = { }
    for index, value in pairs(animationSetsList) do
        if value[1] == animation then
            animationSet = value
        end
	end
	for index, value in pairs(animationSet) do
		if index ~= 1 then
			for index2, value2 in pairs(animationName) do
				if value == value2[1] then
					table.insert(anim, value2)
				end
			end
		end
	end
    return anim
end

-- Check if the vehicle trunk is open
function GetVehicleTrunk(vehicle)
	return GetVehicleTrunkRatio(vehicle) > 0
end

-- Return the index
function ReturnTableRowIndex(table, object)
	for index, value in pairs(table) do
		if value[1] == object then
			return index
		end
	end
	return nil
end

-- Change the value for the table row
function ChangeTableRowValue(table, object, content)
	for index, value in pairs(table) do
		if value[1] == object then
			value[2] = content
		end
	end
end

-- Return the value for the table row
function GetTableRowValue(table, object)
	for index, value in pairs(table) do
		if value[1] == object then
			return value[2]
		end
	end
	return nil
end

-- Check if the object is a valid object
function IsObjectValid(object)
	local valid = false
	for index, value in pairs(objectsList) do
		if value[1] == GetObjectModel(object) then
			valid = true
		end
	end
	return valid
end

-- Check if the object is a valid object
function IsVehicleValid(vehicle)
	local valid = false
	for index, value in pairs(vehiclesList) do
		if value[1] == GetVehicleModel(vehicle) then
			valid = true
		end
	end
	return valid
end

-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- == ADMIN COMMAND, DELETE THE FOLLOWING LINES IF SERVER IS PUBLIC ==
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- ===================================================================
-- Theses following lines are for debugging new object, vehicle and animations

-- Show the nearest vehicle current storage information
function cmd_det(playerid)
	local closestVehicle, dist = GetNearestVehicle(playerid)
	if dist < distanceToInteractWithVehicle then
		local StorageLocationY = GetTableRowValue(VehiclesStorageLocationY, vehicle)
		local StorageLocationX = GetTableRowValue(VehiclesStorageLocationX, vehicle)
		local StorageLocationXEachLine = GetTableRowValue(VehiclesStorageLocationXEachLine, vehicle)
		AddPlayerChat(playerid, "StorageLocationY= "..pasteAllTable(StorageLocationY))
		AddPlayerChat(playerid, "StorageLocationX = "..pasteAllTable(StorageLocationX))
		AddPlayerChat(playerid, "StorageLocationXEachLine = "..pasteAllTable(StorageLocationXEachLine))
	end
end
AddCommand("det", cmd_det)

-- Let's you play any animation
AddCommand("anim", function(playerid, anim)
	SetPlayerAnimation(playerid, anim)
end)

-- Return a complete table in a string
function pasteAllTable(table)
	local toReturn = "{"
	local length = tablelength(table)
	for index,value in pairs(table) do
		if type(value) == "table" then
		toReturn = toReturn..pasteAllTable(value)..""
		else
		toReturn = toReturn..""..value..""
		if index ~= length then
			toReturn = toReturn..","
		end
		end
	end
	toReturn = toReturn.."}"
	return toReturn
end

  
-- Ask the client what is the size of the nearest object
function cmd_dim(playerid)
	local x,y,z = GetPlayerLocation(playerid)
	local object = GetNearestObject(playerid)
	CallRemoteEvent(playerid, "GetDim", object)
end
AddCommand("dim", cmd_dim)

-- Paste the size of the object to the server console, usefull for copy-paste
AddRemoteEvent("PasteDim", function(playerid, object, x, y, z)
	print('{'..GetObjectModel(object)..', "", '..x..', '..y..', '..z..'},')
	AddPlayerChat(playerid, ""..x..', '..y..', '..z.."")
end)

-- Create random vehicle
AddRemoteEvent("CreateVehicle", function(playerid)
	local Vx, Vy, Vz = GetPlayerForward(playerid)
	local x, y, z = GetPlayerLocation(playerid)
	local vehicle = CreateVehicle(RandomObjectFromTable(vehiclesList)[1], x + (Vx * 350), y + (Vy * 350), z)
	AddVehicle(vehicle)
	AddPlayerToVehicleRestriction(vehicle, playerid)
end)

-- Create random object
AddRemoteEvent("CreateObject", function(playerid)
	local Vx, Vy, Vz = GetPlayerForward(playerid)
	local x, y, z = GetPlayerLocation(playerid)
	local object = CreateObject(RandomObjectFromTable(objectsList)[1], x + (Vx * 300), y + (Vy * 300), z - 100)
	AddObject(object)
	AddPlayerToObjectRestriction(object, playerid)
end)

-- Return a random object from the table
function RandomObjectFromTable(table)
	local obj = table[Random(1, tablelength(table))]
	return obj
end

-- See all objects that are in the table
function cmd_seeo(playerid)
	if tablelength(objects) ~= 0 then
		for index, value in pairs(objects) do 
			AddPlayerChat(playerid, "Object Index: "..index.." Model Name: "..tostring(value).."")
		end
	else
		AddPlayerChat(playerid, "Objects is empty")
	end
end
AddCommand("seeo", cmd_seeo)

-- See all vehicles that are in the table
function cmd_seev(playerid)
	if tablelength(vehicles) ~= 0 then
		for index, value in pairs(vehicles) do 
			AddPlayerChat(playerid, "Vehicle Index: "..index.." Model Name: "..tostring(value).."")
		end
	else
		AddPlayerChat(playerid, "Vehicles is empty")
	end
end
AddCommand("seev", cmd_seev)


-- The following lines are for vehicle storage testing
local currentWidth, currentDepth, currentOffsetX, currentOffsetY, currentOffsetZ

function changeVehicle(playerid, newWidth, newDepth, newOffsetX, newOffsetY, newOffsetZ)
	local width, depth, offsetX, offsetY, offsetZ
	
	if (newWidth == 0) and (currentWidth == nil) then
		width = 0
	elseif (newWidth == 0) and (currentWidth ~= nil) then
		width = currentWidth
	else
		width = newWidth
		currentWidth = newWidth
	end

	if (newDepth == 0) and (currentDepth == nil) then
		depth = 0
	elseif (newDepth == 0) and (currentDepth ~= nil) then
		depth = currentDepth
	else
		depth = newDepth
		currentDepth = newDepth
	end

	if (newOffsetX == 0) and (currentOffsetX == nil) then
		offsetX = 0
	elseif (newOffsetX == 0) and (currentOffsetX ~= nil) then
		offsetX = currentOffsetX
	else
		offsetX = newOffsetX
		currentOffsetX = newOffsetX
	end

	if (newOffsetY == 0) and (currentOffsetY == nil) then
		offsetY = 0
	elseif (newOffsetY == 0) and (currentOffsetY ~= nil) then
		offsetY = currentOffsetY
	else
		offsetY = newOffsetY
		currentOffsetY = newOffsetY
	end

	if (newOffsetZ == 0) and (currentOffsetZ == nil) then
		offsetZ = 0
	elseif (newOffsetZ == 0) and (currentOffsetZ ~= nil) then
		offsetZ = currentOffsetZ
	else
		offsetZ = newOffsetZ
		currentOffsetZ = newOffsetZ
	end
	emptyVehicle(playerid)
	FillVehicle(playerid, width, depth, offsetX, offsetY, offsetZ)
end

AddCommand("vw", function(playerid, width)
	changeVehicle(playerid, width, 0, 0, 0, 0)
end)


AddCommand("vd", function(playerid, depth)
	changeVehicle(playerid, 0, depth, 0, 0, 0)
end)


AddCommand("vx", function(playerid, x)
	changeVehicle(playerid, 0, 0, x, 0, 0)
end)


AddCommand("vy", function(playerid, y)
	changeVehicle(playerid, 0, 0, 0, y, 0)
end)


AddCommand("vz", function(playerid, z)
	changeVehicle(playerid, 0, 0, 0, 0, z)
end)


AddCommand("fill", function(playerid)
	FillVehicle(playerid, 0, 0, 0, 0, 0)
end)

function FillVehicle(playerid, newWidth, newDepth, newOffsetX, newOffsetY, newOffsetZ)
	local playerX, playerY, playerZ = GetPlayerLocation(playerid)
	local vehicle = GetNearestVehicle(playerid)
	local vehicleX, vehicleY, vehicleZ = GetVehicleLocation(vehicle)
	-- If we have an interactable vehicle
	if vehicle ~= nil then
		if GetDistance3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) <= distanceToInteractWithVehicle + 5000 then
			-- Vehicle size
			local width, depth, height, offsetX, offsetY, offsetZ, needTrunkOpen = GetVehicleValue(vehicle)

			if newWidth ~= 0 then
				width = newWidth
			end

			if newDepth ~= 0 then
				depth = newDepth
			end


			if newOffsetX ~= 0 then
				offsetX = newOffsetX
			end

			if newOffsetY ~= 0 then
				offsetY = newOffsetY
			end

			if newOffsetZ ~= 0 then
				offsetZ = newOffsetZ
			end

			AddPlayerChat(playerid, "Width: "..width.." Depth: "..depth.." OffsetX: "..offsetX.." OffsetY: "..offsetY.." OffsetZ: "..offsetZ.."")
			print(""..width..", "..depth..", "..offsetX..", "..offsetY..", "..offsetZ.."")
			-- Object size
			local sizeX = 10
			local sizeY = 10
			local sizeZ = 5

			local full = false

			while full == false do --673 coca cola 500 baril
				local object = CreateObject(673, playerX, playerY, playerZ - 300)
				-- Vehicle current storage
				local storageObjects = GetTableRowValue(VehiclesStorageObjects, vehicle)
				local storageLocationX = GetTableRowValue(VehiclesStorageLocationX, vehicle)
				local storageLocationY = GetTableRowValue(VehiclesStorageLocationY, vehicle)
				local storageLocationXEachLine = GetTableRowValue(VehiclesStorageLocationXEachLine, vehicle)

				local currentStorageLocationX = storageLocationX[tablelength(storageLocationX)]
				local currentStorageLocationY = storageLocationY[tablelength(storageLocationY)]
				local currentLine = tablelength(storageLocationXEachLine)
				local currentLineLocationX = storageLocationXEachLine[currentLine]
				
				-- If the object can be placed on the current line
				if (sizeX <= depth - currentStorageLocationX) and (sizeY <= width - currentStorageLocationY) and (sizeZ <= height) then
					SetObjectAttached(object, ATTACH_VEHICLE, vehicle, (offsetX - currentStorageLocationX) - (sizeX/2), (offsetY + currentStorageLocationY) + (sizeY/2), offsetZ, 0, 0, 0)
					
					-- Insert new object in the vehicle storage
					table.insert(storageObjects, object)
					ChangeTableRowValue(VehiclesStorageObjects, vehicle, storageObjects)

					-- Move the Y location by adding the object sizeY
					table.insert(storageLocationY, currentStorageLocationY + sizeY)
					ChangeTableRowValue(VehiclesStorageLocationY, vehicle, storageLocationY)

					-- Add the object sizeX in the current line
					table.insert(currentLineLocationX, currentStorageLocationX + sizeX)
					storageLocationXEachLine[currentLine] = currentLineLocationX
					ChangeTableRowValue(VehiclesStorageLocationXEachLine, vehicle, storageLocationXEachLine)
				-- If not, try to place it on the next line
				else
					currentStorageLocationY = 0
					local currentHighestXLocation = GetHighestValueInTable(currentLineLocationX)
					if (sizeX <= depth - currentHighestXLocation) and (sizeY <= width - currentStorageLocationY) and (sizeZ <= height) then
						
						SetObjectAttached(object, ATTACH_VEHICLE, vehicle, (offsetX - currentHighestXLocation) - (sizeX/2), (offsetY + currentStorageLocationY) + (sizeY/2), offsetZ, 0, 0, 0)

						-- Insert new object in the vehicle storage
						table.insert(storageObjects, object)
						ChangeTableRowValue(VehiclesStorageObjects, vehicle, storageObjects)

						-- Move the Y location by adding the object sizeY
						table.insert(storageLocationY, currentStorageLocationY + sizeY)
						ChangeTableRowValue(VehiclesStorageLocationY, vehicle, storageLocationY)

						-- Add the object sizeX in a new line
						table.insert(storageLocationXEachLine, {currentHighestXLocation + sizeX})
						ChangeTableRowValue(VehiclesStorageLocationXEachLine, vehicle, storageLocationXEachLine)

						-- Add the object sizeX in the current line
						table.insert(storageLocationX, currentHighestXLocation)
						ChangeTableRowValue(VehiclesStorageLocationX, vehicle, storageLocationX)
					else
						full = true
					end
				end
			end
		end
	end
end

function cmd_empty(playerid)
	emptyVehicle(playerid)
end
AddCommand("empty", cmd_empty)

function emptyVehicle(playerid)
	local playerX, playerY, playerZ = GetPlayerLocation(playerid)
	local vehicle = GetNearestVehicle(playerid)
	local vehicleX, vehicleY, vehicleZ = GetVehicleLocation(vehicle)
	-- If we have an interactable vehicle
	if vehicle ~= nil then
		if GetDistance3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) <= distanceToInteractWithVehicle + 5000 then
			storageObjects = GetTableRowValue(VehiclesStorageObjects, vehicle)
			for index,value in pairs(storageObjects) do
				DestroyObject(value)
			end
			ChangeTableRowValue(VehiclesStorageObjects, vehicle, { })
			storageLocationY = { }
			table.insert(storageLocationY, 0)
			ChangeTableRowValue(VehiclesStorageLocationX, vehicle, storageLocationY)
			storageLocationX = { }
			table.insert(storageLocationX, 0)
			ChangeTableRowValue(VehiclesStorageLocationX, vehicle, storageLocationX)
			highestStorageLocationX = { }
			allStorageLocationX = { }
			table.insert(allStorageLocationX, highestStorageLocationX)
			ChangeTableRowValue(VehiclesStorageLocationXEachLine, vehicle, allStorageLocationX)
		end
	end
end

-- The following lines are for object attach testing
local currentX, currentY, currentZ, currentRx, currentRy, currentRz
local objectPositionFirstTime = false
local currentPlayerBone = "head"

function changeObject(playerid, newX, newY, newZ, newRx, newRy, newRz)
	local x, y, z, rx, ry, rz

	if objectPositionFirstTime == false then
		objectPositionFirstTime = true
		currentX = 0
		currentY = 0
		currentZ = 0
		currentRx = 0
		currentRy = 0
		currentRz = 0
	end

	if (newX == 0) and (currentX == nil) then
		x = 0
	elseif (newX == 0) and (currentX ~= nil) then
		x = currentX
	else
		x = newX
		currentX = newX
	end

	if (newY == 0) and (currentY == nil) then
		y = 0
	elseif (newY == 0) and (currentY ~= nil) then
		y = currentY
	else
		y = newY
		currentY = newY
	end

	if (newZ == 0) and (currentZ == nil) then
		z = 0
	elseif (newZ == 0) and (currentZ ~= nil) then
		z = currentZ
	else
		z = newZ
		currentZ = newZ
	end

	if (newRx == 0) and (currentRx == nil) then
		rx = 0
	elseif (newRx == 0) and (currentRx ~= nil) then
		rx = currentRx
	else
		rx = newRx
		currentRx = newRx
	end

	if (newRy == 0) and (currentRy == nil) then
		ry = 0
	elseif (newRy == 0) and (currentRy ~= nil) then
		ry = currentRy
	else
		ry = newRy
		currentRy = newRy
	end

	if (newRz == 0) and (currentRz == nil) then
		rz = 0
	elseif (newRz == 0) and (currentRz ~= nil) then
		rz = currentRz
	else
		rz = newRz
		currentRz = newRz
	end
	AddPlayerChat(playerid, "x: "..x.." y: "..y.." z: "..z.." rx: "..rx.." ry: "..ry.." rz: "..rz.."")
	local obj = GetPlayerPropertyValue(playerid, "objectInHand")
	print(""..x..", "..y..", "..z..", "..rx..", "..ry..", "..rz..", "..tostring(currentPlayerBone).."},")
	if obj ~= nil then
		AddPlayerChat(playerid, "placing new object position...")
		SetObjectDetached(obj)
		SetObjectAttached(obj, ATTACH_PLAYER, playerid, x, y, z, rx, ry, rz, currentPlayerBone)
	else
		AddPlayerChat(playerid, "You are not holding an object...")
	end
end

AddCommand("ox", function(playerid, x)
	changeObject(playerid, x, 0, 0, 0, 0, 0)
end)


AddCommand("oy", function(playerid, y)
	changeObject(playerid, 0, y, 0, 0, 0, 0)
end)


AddCommand("oz", function(playerid, z)
	changeObject(playerid, 0, 0, z, 0, 0, 0)
end)


AddCommand("orx", function(playerid, rx)
	changeObject(playerid, 0, 0, 0, rx, 0, 0)
end)


AddCommand("ory", function(playerid, ry)
	changeObject(playerid, 0, 0, 0, 0, ry, 0)
end)

AddCommand("orz", function(playerid, rz)
	changeObject(playerid, 0, 0, 0, 0, 0, rz)
end)

AddCommand("bone", function(playerid, bone)
	currentPlayerBone = bone
	changeObject(playerid, 0, 0, 0, 0, 0, 0)
end)

local loopAnim
AddCommand("loopanim", function(playerid, anim)
	SetPlayerAnimation(playerid, anim)
	loopAnim = CreateTimer(function() 
		SetPlayerAnimation(playerid, anim)
	end, 1500)
end)

AddCommand("loopstop", function(playerid, anim)
	DestroyTimer(loopAnim)
	SetPlayerAnimation(playerid, "STOP")
end)

-- Let you change the trunk value of the nearest vehicle
AddCommand("trunk", function(playerid, openRatio)
	local vehicle = GetNearestVehicle(playerid)
	AddPlayerChat(playerid, "Trunk: "..openRatio.."")
	SetVehicleTrunkRatio(vehicle, openRatio)
end)

-- Delete the nearest object from the player
AddCommand("delobject", function(playerid)
	local object = GetNearestObject(playerid)
	RemoveObject(object)
	DestroyObject(object)
end)

-- Delete the nearest vehicle from the player
AddCommand("delvehicle", function(playerid)
	local vehicle = GetNearestVehicle(playerid)
	RemoveVehicle(vehicle)
	DestroyObject(vehicle)
end)

-- Show the object id in the chat
AddCommand("id", function(playerid)
	local object = GetNearestObject(playerid)
	AddPlayerChat(playerid, "Object ID: "..tostring(object).."")
end)

-- Show the object id in the chat
AddCommand("kill", function(playerid)
	SetPlayerHealth(playerid, 0)
end)

-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- == ADMIN COMMAND, DELETE THE PREVIOUS LINES IF SERVER IS PUBLIC ==
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================
-- ==================================================================