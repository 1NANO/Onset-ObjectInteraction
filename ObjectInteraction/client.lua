-- DialogUI library (TEMPORARY)
local Dialog = ImportPackage("dialogui")

-- DialogUI library for the admin menu (TEMPORARY)
local AdminMenu = Dialog.create("Admin Menu", "", "Spawn vehicle", "Spawn object", "Cancel")

-- Load location of a vehicle
local showNearestLoadLocation = false

-- Last vehicle driven by the player. He will be able to see the trunk load location when walking with an object
local playerCar

-- OnKeyPress Event
function OnKeyPress(key)
    -- If the E key is pressed, look for available interaction to send to the server.
    if key == "E" then
        SendAdvancedInteraction()
    end

    -- G key for the admin menu (TEMPORARY)
    if key == "G" then
        Dialog.show(AdminMenu)
    end
end
AddEvent("OnKeyPress", OnKeyPress)

-- Save the last vehicle information of the player
function OnPlayerEnterVehicle(player, vehicle, seat)
    playerCar = vehicle
end
AddEvent("OnPlayerEnterVehicle", OnPlayerEnterVehicle)

-- Return the length of a table
function tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
  end

-- Server telling the client to show load location
AddRemoteEvent("OnReceivingStartLoadLocation", function()
    showNearestLoadLocation = true
end)

-- Server telling the client to cancel the load location
AddRemoteEvent("OnReceivingCancelLoadLocation", function()
    showNearestLoadLocation = false
end)

-- Render the load location for the player vehicle
function OnRenderHUD()
    if showNearestLoadLocation == true then
        if (playerCar ~= nil) then
            local vehicleX, vehicleY, vehicleZ = GetVehicleLocation(playerCar)
            local trunkOffset = GetVehiclePropertyValue(playerCar, "trunkOffset")
            local Vx, Vy, Vz = GetVehicleForwardVector(playerCar)
            SetDrawColor(RGB(255, 255, 0))
            DrawCircle3D(vehicleX + (Vx * trunkOffset), vehicleY + (Vy * trunkOffset), vehicleZ + 25.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 200.0)
        end
    end
end
AddEvent('OnRenderHUD', OnRenderHUD)

-- This event right now is used to patch a bug with object collision.
--local previousLength = 0
local objectInHandDetection = true
function OnGameTick(DeltaSeconds)
    if disableObjectCollision == true then
        local objects = GetStreamedObjects(true)
        --local length = tablelength(objects)
        --print(length)
        --if length ~= previousLength then
            --previousLength = length
            DisableAllInteractableCollision(objects)
            --AddPlayerChat("Received request to set collisions on "..length.." objects...")
        --end
    else
        local objectInHand = GetPlayerPropertyValue(GetPlayerId(), "objectInHand")
        if objectInHand ~= nil then
            if objectInHandDetection == true then
                objectInHandDetection = false
                local ObjectStaticMeshComponent = GetObjectStaticMeshComponent(objectInHand)
                ObjectStaticMeshComponent:SetCollisionEnabled(0)
            end
        else
            objectInHandDetection = true
        end
    end
end
AddEvent('OnGameTick', OnGameTick)

-- Disable the collisions of all the objects that are marked as "Interactable"
function DisableAllInteractableCollision(objects)
    for index, value in pairs(objects) do
        if GetObjectPropertyValue(value, "interactable") ~= nil then
            local ObjectStaticMeshComponent = GetObjectStaticMeshComponent(value)
            ObjectStaticMeshComponent:SetCollisionEnabled(0)
        end
    end
end

-- Check whatever interaction is best to send to the server. If none then it doesn't do anything.
function SendAdvancedInteraction()
    if GetVehicleAvailability() == true then
        if GetPlayerPropertyValue(GetPlayerId(), "objectInHand") == nil then
            CallRemoteEvent("OnClientUnload")
        else
            CallRemoteEvent("OnClientLoad")
        end
    else
        if GetPlayerPropertyValue(GetPlayerId(), "objectInHand") == nil then
            if GetObjectAvailability() then
                CallRemoteEvent("OnClientPickup")
            end
        else
            CallRemoteEvent("OnClientDrop")
        end
    end
end

-- Check if there is an available object that might be worth picking up
function GetObjectAvailability()
    local objects = GetStreamedObjects()
    local object = nil
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(GetPlayerId())

	for _,o in pairs(objects) do
        local x2, y2, z2 = GetObjectLocation(o)
        local dist = GetDistance3D(x, y, z, x2, y2, z2)
        if dist < nearest_dist then
            nearest_dist = dist
            object = o
        end
    end
    
    if nearest_dist < distanceToInteractWithObject then
        return true
    else
        return false
    end
end

-- Check if there is an available vehicle where the player can interact
function GetVehicleAvailability()
    local vehicles = GetStreamedVehicles()
    local vehicle = nil
	local nearest_dist = 999999.9
	local x, y, z = GetPlayerLocation(GetPlayerId())

    for _,v in pairs(vehicles) do
        local trunkOffset = GetVehiclePropertyValue(v, "trunkOffset")
		if trunkOffset ~= nil then
            local x2, y2, z2 = GetVehicleLocation(v)
            local Vx, Vy, Vz = GetVehicleForwardVector(v)
			local dist = GetDistance3D(x, y, z, x2 + (Vx * trunkOffset), y2 + (Vy * trunkOffset), z2)
			if dist < nearest_dist then
				nearest_dist = dist
				vehicle = v
			end
		end
    end
    
    if nearest_dist < distanceToInteractWithVehicle then
        return true
    else
        return false
    end
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

-- OnDialogSubmit event (TEMPORARY)
AddEvent("OnDialogSubmit", function(dialog, button)
    -- Admin menu
    if dialog == AdminMenu then
        if button == 1 then
            CallRemoteEvent("CreateVehicle")
        elseif button == 2 then
            CallRemoteEvent("CreateObject")
        end
    else
        return
    end
end)

-- Send the object size to the server and print it to the client logs, usefull for copy-paste
AddRemoteEvent("GetDim", function(object)
    local x,y,z = GetObjectSize(object)
    CallRemoteEvent("PasteDim", object, x,y,z)
    print('{'..GetObjectModel(object)..', "", '..x..', '..y..', '..z..'},')
end)