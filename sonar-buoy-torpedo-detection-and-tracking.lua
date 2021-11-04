--[[
sonar-buoy-torped-detection-and-tracking.lua
by Michael Coviello

Description:
    This will assign one missile to each detected enemy target, and allow the
    others to continue moving in the direction they were launched.
    Will only work on targets below sea level (Mainly meant for submarines).

Example Setup:
    Attach to a spinning torpedo gantry that utilises ACBs to fire on reload, into the water.

]]--


function Update(I)

    --Create an array to store the missiles that have a target
    local usedMissiles = {};
    for i = 0, I:GetLuaControlledMissileCount(0) - 1 do
        usedMissiles[i] = true
    end

    for t = 0, I:GetNumberOfTargets(0) - 1 do
        if target.Valid() and target.Position.y <= 0 then
            local curTarget = I:GetTargetInfo(0,t)
            local closestMissileIndex = 0
            local closestDistanceFromTarget = Vector3.Distance(I:GetLuaControlledMissileInfo(0,0).Position, curTarget.Position)
            for m = 1, I:GetLuaControlledMissileCount(0) - 1 do
                local currentMissileDistanceFromTarget = Vector3.Distance(I:GetLuaControlledMissileInfo(0,m).Position, curTarget.Position)
                if currentMissileDistanceFromTarget < closestDistanceFromTarget and usedMissiles[m] == false then
                    closestMissileIndex = m
                    closestDistanceFromTarget = currentMissileDistanceFromTarget
                end
            end
            usedMissiles[closestMissileIndex] = true
            local goal_pos = curTarget.Position
            goal_pos.y = goal_pos.y - 100

            I:SetLuaControlledMissileAimPoint(0, closestMissileIndex, goal_pos.x, goal_pos.y, goal_pos.z)
        end
    end

    for m = 0, I:GetLuaControlledMissileCount(0) - 1 do
        if usedMissiles[m] == false then
            local current_pos = I:GetLuaControlledMissileInfo(0,m).Position + I:GetLuaControlledMissileInfo(0,m).Velocity
            current_pos.y =  - 50
            I:SetLuaControlledMissileAimPoint(0, m, current_pos.x, current_pos.y, current_pos.z)
        end
    end
end

