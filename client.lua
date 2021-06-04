function UnloadBodyguard()
	for k, guard in pairs(Bodyguard.Guards) do
		if(guard ~= nil) then
            DeletePed(guard)
			Bodyguard.Guards[k] = nil
		end
	end
end

TriggerEvent('chat:addSugestion', '/spawnbodyguard', 'Spawn a bodyguard next to you')
RegisterCommand("spawnbodyguard", function(source, args, rawCommand)
    spawnBodyguard()
end, false)

TriggerEvent('chat:addSugestion', '/unloadbodyguard', 'Unloads the bodyguard')
RegisterCommand("unloadbodyguard", function(source, args, rawCommand)
    UnloadBodyguard()
end, false)

ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

function spawnBodyguard()
        if PlayerData.job ~= nil and PlayerData.job == Bodyguard.JobAce then
            local BodyGuardSkinID = GetHashKey(Bodyguard.GuardSkin)
            local playerPed = PlayerPedId()
            local player = GetPlayerPed(playerPed)
            local playerPosition = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
            local playerGroup = GetPedGroupIndex(playerPed)
            if Bodyguard.SpawnMultiple == false then
                UnloadBodyguard()
            end
                Citizen.Wait(10)
                RequestModel(BodyGuardSkinID)
            while(not HasModelLoaded(BodyGuardSkinID)) do
                Citizen.Wait(10)
            end
            for i = 0, Bodyguard.GuardAmount, 1 do
                Bodyguard.Guards[i] = CreatePed(26, BodyGuardSkinID, playerPosition.x, playerPosition.y, playerPosition.z, 1, false, true)	
                SetPedCanSwitchWeapon(Bodyguard.Guards[i],false)
                SetPedAsGroupMember(Bodyguard.Guards[i], playerGroup)
                if Bodyguard.SetInvincible == true then
                    SetEntityInvincible(Bodyguard.Guards[i], true)
                else
                    SetEntityInvincible(Bodyguard.Guards[i], false)
                end
                if Bodyguard.GiveWeapon == true then
                    GiveWeaponToPed(Bodyguard.Guards[i], GetHashKey(Bodyguard.GuardWeapon), 100, true, true)
                end
            end
            SetModelAsNoLongerNeeded(BodyGuardSkinID)
        else
            print('[ESX.BODYGUARD] - ERROR: You cannot spawn bodyguards or your job is invalid.')
            TriggerEvent('chatMessage', '^1[ESX.BODYGUARD]^0 - ^1ERROR:^0 You cannot spawn bodyguards or your job is invalid.')
    Citizen.Wait(10)
end