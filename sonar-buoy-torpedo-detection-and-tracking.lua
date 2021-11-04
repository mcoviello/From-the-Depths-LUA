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

    local TORPEDO_HOVER_DEPTH = 100

    --Create an array to store the missiles that have a target.
    local usedMissiles = {};
    for i = 0, I:GetLuaControlledMissileCount(0) - 1 do
        usedMissiles[i] = false
    end

    for t = 0, I:GetNumberOfTargets(0) - 1 do
        local curTarget = I:GetTargetInfo(0,t)
        --If the target is below sea level...
        if curTarget.Valid and curTarget.Position.y <= 0 then
            local closestMissileIndex = 0
            local closestDistanceFromTarget = Vector3.Distance(I:GetLuaControlledMissileInfo(0,0).Position, curTarget.Position)
            --Calculate the closest missile to the target, that isn't already on a target.
            for m = 1, I:GetLuaControlledMissileCount(0) - 1 do
                local currentMissileDistanceFromTarget = Vector3.Distance(I:GetLuaControlledMissileInfo(0,m).Position, curTarget.Position)
                if currentMissileDistanceFromTarget < closestDistanceFromTarget and not usedMissiles[m] then
                    closestMissileIndex = m
                    closestDistanceFromTarget = currentMissileDistanceFromTarget
                end
            end

            --For the closest missile, make it hover below the sub (or above, if the sub is too deep)
            usedMissiles[closestMissileIndex] = true
            local goal_pos = curTarget.Position
            goal_pos.y = (curTarget.Position.y - TORPEDO_HOVER_DEPTH > I:GetTerrainAltitudeForPosition(curTarget.Position.x, curTarget.Position.y, curTarget.Position.z) and goal_pos.y - TORPEDO_HOVER_DEPTH or goal_pos.y + TORPEDO_HOVER_DEPTH)
            I:SetLuaControlledMissileAimPoint(0, closestMissileIndex, goal_pos.x, goal_pos.y, goal_pos.z)
        end
    end

    --Make all unused missiles continue in their launch direction
    for m = 0, I:GetLuaControlledMissileCount(0) - 1 do
        if usedMissiles[m] == false then
            local current_pos = I:GetLuaControlledMissileInfo(0,m).Position + I:GetLuaControlledMissileInfo(0,m).Velocity
            current_pos.y =  - 50
            I:SetLuaControlledMissileAimPoint(0, m, current_pos.x, current_pos.y, current_pos.z)
        end
    end
end

