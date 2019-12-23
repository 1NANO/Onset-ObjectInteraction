-- Export multiple function when the package start..
function OnPackageStart()
    AddFunctionExport("AddObject", AddObject)
    AddFunctionExport("RemoveObject", RemoveObject)
    AddFunctionExport("AddVehicle", AddVehicle)
    AddFunctionExport("RemoveVehicle", RemoveVehicle)
    AddFunctionExport("AddPlayerToObjectRestriction", AddPlayerToObjectRestriction)
    AddFunctionExport("RemovePlayerFromObjectRestriction", RemovePlayerFromObjectRestriction)
    AddFunctionExport("AddPlayerToVehicleRestriction", AddPlayerToVehicleRestriction)
    AddFunctionExport("RemovePlayerFromVehicleRestriction", RemovePlayerFromVehicleRestriction)
    AddFunctionExport("GetPlayerObject", GetPlayerObject)
    AddFunctionExport("SetPlayerObject", SetPlayerObject)
    AddFunctionExport("CanPlayerPickup", CanPlayerPickup)
    AddFunctionExport("CanPlayerDrop", CanPlayerDrop)
    AddFunctionExport("CanPlayerLoad", CanPlayerLoad)
    AddFunctionExport("CanPlayerUnLoad", CanPlayerUnLoad)
end
AddEvent("OnPackageStart", OnPackageStart)

-- Add an object with this function in order to make it interactable
function AddObject(object)
    if IsObjectValid(object) == true then
        table.insert(ObjectsisBeingHeld, {object, false})
        table.insert(ObjectsRestriction, {object, { }})
        if enableObjectDespawn == true then
            table.insert(ObjectsCanDespawn, {object, {true, objectDespawnTime}})
        end
        SetObjectPropertyValue(object, "interactable", true)
        table.insert(objects, object)
        return object
    else
        print("Trying to add an invalid object to the objects table")
        return nil
    end
end

-- Remove an object that was interactable
function RemoveObject(object)
	local indexToRemove = nil
	for index, value in pairs(objects) do
		if value == object then
			indexToRemove = index
		end
    end
    if indexToRemove ~= nil then
        table.remove(ObjectsisBeingHeld, ReturnTableRowIndex(ObjectsisBeingHeld, object))
        table.remove(ObjectsRestriction, ReturnTableRowIndex(ObjectsRestriction, object))
        table.remove(ObjectsCanDespawn, ReturnTableRowIndex(ObjectsCanDespawn, object))
        table.remove(objects, indexToRemove)
    end
end

-- Add a vehicle with this function in order to make it interactable
function AddVehicle(vehicle)
    if IsVehicleValid(vehicle) == true then
        table.insert(VehiclesStorageObjects, {vehicle, { }})
        table.insert(VehiclesRestriction, {vehicle, { }})
        local width, depth, height, offsetX, offsetY, offsetZ, trunkOffset, needTrunkOpen = GetVehicleValue(vehicle)
        SetVehiclePropertyValue(vehicle, "trunkOffset", trunkOffset)

        -- Setting storage value to be ready to receive objects
        local storageLocationY = { }
        table.insert(storageLocationY, 0)
        table.insert(VehiclesStorageLocationY, {vehicle, storageLocationY})
        local storageLocationX = { }
        table.insert(storageLocationX, 0)
        table.insert(VehiclesStorageLocationX, {vehicle, storageLocationX})
        local highestStorageLocationX = { }
        local allStorageLocationX = { }
        table.insert(allStorageLocationX, highestStorageLocationX)
        table.insert(VehiclesStorageLocationXEachLine, {vehicle, allStorageLocationX})

        table.insert(vehicles, vehicle)
        return vehicle
    else
        print("Trying to add an invalid vehicle to the vehicles table")
        return nil
    end
end

-- Remove a vehicle that was interactable
function RemoveVehicle(vehicle)
	local indexToRemove = nil
	for index, value in pairs(vehicles) do
		if value == vehicle then
			indexToRemove = index
		end
    end
    if indexToRemove ~= nil then
        table.remove(VehiclesStorageObjects, ReturnTableRowIndex(VehiclesStorageObjects, vehicle))
        table.remove(VehiclesRestriction, ReturnTableRowIndex(VehiclesRestriction, vehicle))
        table.remove(VehiclesStorageLocationY, ReturnTableRowIndex(VehiclesStorageLocationY, vehicle))
        table.remove(VehiclesStorageLocationX, ReturnTableRowIndex(VehiclesStorageLocationX, vehicle))
        table.remove(VehiclesStorageLocationXEachLine, ReturnTableRowIndex(VehiclesStorageLocationXEachLine, vehicle))
        table.remove(vehicles, indexToRemove)
    end
end

-- Give a player the right to interact with this object
function AddPlayerToObjectRestriction(object, playerid)
    if GetTableRowValue(PlayersSteamAuth, playerid) then
        local restriction = GetTableRowValue(ObjectsRestriction, object)
        if playerid ~= nil then
            table.insert(restriction, tostring(GetPlayerSteamId(playerid)))
        end
        ChangeTableRowValue(ObjectsRestriction, object, restriction)
    end
end

-- Remove a player from having the right to interact with this object
function RemovePlayerFromObjectRestriction(object, playerid)
    if GetTableRowValue(PlayersSteamAuth, playerid) then
        local restriction = GetTableRowValue(ObjectsRestriction, object)
        local indexToRemove
        for index, value in pairs(restriction) do
            if value == tostring(GetPlayerSteamId(playerid)) then
                indexToRemove = index
            end
        end
        table.remove(restriction, indexToRemove)
        ChangeTableRowValue(ObjectsRestriction, object, restriction)
    end
end

-- Give a player the right to interact with this vehicle
function AddPlayerToVehicleRestriction(vehicle, playerid)
    if GetTableRowValue(PlayersSteamAuth, playerid) then
        local restriction = GetTableRowValue(VehiclesRestriction, vehicle)
        if playerid ~= nil then
            table.insert(restriction, tostring(GetPlayerSteamId(playerid)))
        end
        ChangeTableRowValue(VehiclesRestriction, vehicle, restriction)
    end
end

-- Remove a player from having the right to interact with this vehicle
function RemovePlayerFromVehicleRestriction(vehicle, playerid)
    if GetTableRowValue(PlayersSteamAuth, playerid) then
        local restriction = GetTableRowValue(VehiclesRestriction, vehicle)
        local indexToRemove
        for index, value in pairs(restriction) do
            if value == tostring(GetPlayerSteamId(playerid)) then
                indexToRemove = index
            end
        end
        table.remove(restriction, indexToRemove)
        ChangeTableRowValue(VehiclesRestriction, vehicle, restriction)
    end
end

-- Get the object that the player is currently holding
function GetPlayerObject(playerid)
    local object = GetPlayerPropertyValue(playerid, "objectInHand")
    if object ~= nil then
        return object
    else
        return nil
    end
end

-- Give a player an object to hold
function SetPlayerObject(playerid, object)
    if object ~= nil then
        if GetTableRowValue(ObjectsisBeingHeld, object) == false then
            if GetPlayerPropertyValue(playerid, "objectInHand") == nil then
                -- We can pickup the object
                PickUp(playerid, object)
            end
        end
    end
end

-- Function to call when a player is requesting to pickup an object
function CanPlayerPickup(playerid)
	-- If the player doesn't already hold an object
	if GetPlayerPropertyValue(playerid, "objectInHand") == nil then
		local playerX, playerY, playerZ = GetPlayerLocation(playerid)
		local object = GetNearestObject(playerid)
		-- If we have an interactable object
		if object ~= nil then
			-- We are making sure that the object can be picked
			if GetTableRowValue(ObjectsisBeingHeld, object) == false then
                local objectX, objectY, objectZ = GetObjectLocation(object)
                local anim, sizeX, sizeY, sizeZ = GetObjectValue(object)
				-- If the distance between the object and the player is valid
				if GetDistance3D(objectX, objectY, objectZ, playerX, playerY, playerZ) <= distanceToInteractWithObject then
					-- If the player has the right to interact
					if RightToInteract(playerid, GetTableRowValue(ObjectsRestriction, object)) == true then
						-- We can pickup the object
						PickUp(playerid, object)
					else
						AddPlayerChat(playerid, "You cannot interact with this object!")
					end
				else
					AddPlayerChat(playerid, "There is no object near you to pick up!")
				end
			end
		else
			AddPlayerChat(playerid, "There is no object near you to pick up!")
		end
	else
		AddPlayerChat(playerid, "You already hold an object!")
	end
end

-- Function to call when a player is requesting to drop an object
function CanPlayerDrop(playerid)
	local object = GetPlayerPropertyValue(playerid, "objectInHand")
	-- If the player currently hold an object
	if object ~= nil then
		-- We can drop it
		Drop(playerid, object)
	else
		AddPlayerChat(playerid, "You have no object in your hands!")
	end
end

-- Function to call when a player is requesting to load an object into a vehicle
function CanPlayerLoad(playerid)
	local object = GetPlayerPropertyValue(playerid, "objectInHand")
    -- If the player currently hold an object
	if object ~= nil then
		local playerX, playerY, playerZ = GetPlayerLocation(playerid)
		local vehicle = GetNearestVehicle(playerid)
		-- If we have an interactable vehicle
		if vehicle ~= nil then
            local vehicleX, vehicleY, vehicleZ = GetVehicleLoadLocation(vehicle)
            -- If the distance between the vehicle and the player is valid
            if GetDistance3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) <= distanceToInteractWithVehicle then
                -- If the player has the right to interact with this vehicle
                if RightToInteract(playerid, GetTableRowValue(ObjectsRestriction, object)) == true then
                    -- We can load the object inside the vehicle
                    local width, depth, height, offsetX, offsetY, offsetZ, trunkOffset, needTrunkOpen = GetVehicleValue(vehicle)

                    local canLoad = false
                    -- Checking if the trunk of the vehicle need to be open
                    if needTrunkOpen == true then
                        if GetVehicleTrunk(vehicle) then
                            canLoad = true
                        end
                    else
                        canLoad = true
                    end
                    if canLoad == true then
                        -- Object size
                        local anim, sizeX, sizeY, sizeZ = GetObjectValue(object)

                        -- Vehicle current storage
                        local vehicleIndex = ReturnTableRowIndex(VehiclesStorageObjects, vehicle)
                        local storageObjects = VehiclesStorageObjects[vehicleIndex][2]
                        local storageLocationX = VehiclesStorageLocationX[vehicleIndex][2]
                        local storageLocationY = VehiclesStorageLocationY[vehicleIndex][2]
                        local storageLocationXEachLine = VehiclesStorageLocationXEachLine[vehicleIndex][2]

                        local currentStorageLocationX = storageLocationX[tablelength(storageLocationX)]
                        local currentStorageLocationY = storageLocationY[tablelength(storageLocationY)]
                        local currentLine = tablelength(storageLocationXEachLine)
                        local currentLineLocationX = storageLocationXEachLine[currentLine]
                        
                        -- If the object can be placed on the current line
                        if (sizeX <= depth - currentStorageLocationX) and (sizeY <= width - currentStorageLocationY) and (sizeZ <= height) then
                            Drop(playerid, object)
                            Delay(1000, function() 
                                SetObjectAttached(object, ATTACH_VEHICLE, vehicle, (offsetX - currentStorageLocationX) - (sizeX/2), (offsetY + currentStorageLocationY) + (sizeY/2), offsetZ, 0, 0, 0)
                                ChangeTableRowValue(ObjectsisBeingHeld, object, true)
                                -- Insert new object in the vehicle storage
                                table.insert(storageObjects, object)
                                VehiclesStorageObjects[vehicleIndex][2] = storageObjects

                                -- Move the Y location by adding the object sizeY
                                table.insert(storageLocationY, currentStorageLocationY + sizeY)
                                VehiclesStorageLocationY[vehicleIndex][2] = storageLocationY

                                -- Add the object sizeX in the current line
                                table.insert(currentLineLocationX, currentStorageLocationX + sizeX)
                                storageLocationXEachLine[currentLine] = currentLineLocationX
                                VehiclesStorageLocationXEachLine[vehicleIndex][2] = storageLocationXEachLine
                            end)
                        -- If not, try to place it on the next line
                        else
                            currentStorageLocationY = 0
                            local currentHighestXLocation = GetHighestValueInTable(currentLineLocationX)
                            if (sizeX <= depth - currentHighestXLocation) and (sizeY <= width - currentStorageLocationY) and (sizeZ <= height) then
                                Drop(playerid, object)
                                Delay(1000, function() 
                                    SetObjectAttached(object, ATTACH_VEHICLE, vehicle, (offsetX - currentHighestXLocation) - (sizeX/2), (offsetY + currentStorageLocationY) + (sizeY/2), offsetZ, 0, 0, 0)
                                    ChangeTableRowValue(ObjectsisBeingHeld, object, true)

                                    -- Insert new object in the vehicle storage
                                    table.insert(storageObjects, object)
                                    VehiclesStorageObjects[vehicleIndex][2] = storageObjects

                                    -- Move the Y location by adding the object sizeY
                                    table.insert(storageLocationY, currentStorageLocationY + sizeY)
                                    VehiclesStorageLocationY[vehicleIndex][2] = storageLocationY

                                    -- Add the object sizeX in a new line
                                    table.insert(storageLocationXEachLine, {currentHighestXLocation + sizeX})
                                    VehiclesStorageLocationXEachLine[vehicleIndex][2] = storageLocationXEachLine

                                    -- Add the object sizeX in the current line
                                    table.insert(storageLocationX, currentHighestXLocation)
                                    VehiclesStorageLocationX[vehicleIndex][2] = storageLocationX
                                end)
                            else
                                AddPlayerChat(playerid, "There is not enough space in this vehicle!")
                            end
                        end
                    else
                        AddPlayerChat(playerid, "You need to open the trunk!")
                    end
                else
                    AddPlayerChat(playerid, "You cannot interact with this vehicle!")
                end
            else
                AddPlayerChat(playerid, "There is no storage near you!")
            end
		else
			AddPlayerChat(playerid, "There is no storage near you!")
		end
	else
		AddPlayerChat(playerid, "You have no object in your hands!")
	end
end

-- Function to call when a player is requesting to unload an object into a vehicle
function CanPlayerUnLoad(playerid)
	-- If the player doesn't already hold an object
	if GetPlayerPropertyValue(playerid, "objectInHand") == nil then
		local playerX, playerY, playerZ = GetPlayerLocation(playerid)
		local vehicle = GetNearestVehicle(playerid)
		-- If we have an interactable vehicle
		if vehicle ~= nil then
			local vehicleX, vehicleY, vehicleZ = GetVehicleLoadLocation(vehicle)
			-- If the distance between the vehicle and the player is valid
			if GetDistance3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) <= distanceToInteractWithVehicle then
				-- If we have the right to interact with this vehicle
				if RightToInteract(playerid, GetTableRowValue(VehiclesRestriction, vehicle)) == true then
                    -- Removing the last object from the vehicle
                    local vehicleIndex = ReturnTableRowIndex(VehiclesStorageObjects, vehicle)
					local storageObjects = VehiclesStorageObjects[vehicleIndex][2]
					local numberOfObjectInVehicle = tablelength(storageObjects)
					local object = storageObjects[numberOfObjectInVehicle]
					table.remove(storageObjects, numberOfObjectInVehicle)
                    VehiclesStorageObjects[vehicleIndex][2] = storageObjects

					local storageLocationX = VehiclesStorageLocationX[vehicleIndex][2]
					local storageLocationY = VehiclesStorageLocationY[vehicleIndex][2]
					local storageLocationXEachLine = VehiclesStorageLocationXEachLine[vehicleIndex][2]
					local currentLine = tablelength(storageLocationXEachLine)
					local currentLineLocationX = storageLocationXEachLine[currentLine]

					-- Removing the last StorageLocationY from the vehicle
					table.remove(storageLocationY, tablelength(storageLocationY))
                    VehiclesStorageLocationY[vehicleIndex][2] = storageLocationY

					local curentLineLength = tablelength(currentLineLocationX)
					-- If there is more than one object remaining on that line
					if curentLineLength ~= 1 then
						table.remove(currentLineLocationX, curentLineLength)
					-- If this object is the last one on the line
					else
						-- If this object is the last one on the vehicle
						if currentLine == 1 then
							storageLocationXEachLine[1] = { }
						else
							table.remove(storageLocationXEachLine, currentLine)
							table.remove(storageLocationX, tablelength(storageLocationX))
						end
					end
                    VehiclesStorageLocationX[vehicleIndex][2] = storageLocationX
                    VehiclesStorageLocationXEachLine[vehicleIndex][2] = storageLocationXEachLine
					
					-- Pickup the object from the vehicle
					PickUp(playerid, object)
				else
					AddPlayerChat(playerid, "You cannot interact with this vehicle!")
				end
			else
				AddPlayerChat(playerid, "There is no object near you to pick up!")
			end
		else
			AddPlayerChat(playerid, "There is no vehicle near you to unload!")
		end
	else
		AddPlayerChat(playerid, "You already hold an object!")
	end
end