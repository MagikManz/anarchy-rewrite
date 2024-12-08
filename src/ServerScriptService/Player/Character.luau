export type CharacterService = {
    GetHumanoid: (self: CharacterService, player: Player, character: Model, retry: boolean) -> Humanoid?,

    DefaultConnections: { { priority: number, func: (player: Player, character: Model) -> () } }
}

local PLAYER_RESPAWN_TIME = 3
local DEFAULT_WALK_SPEED = 14

local Character: CharacterService = {
    GetHumanoid = function(_self, _player, _character, _retry): Humanoid? return nil end,

    DefaultConnections = { }
}

function Character:GetHumanoid(player: Player, character: Model, retry: boolean): Humanoid?
    local humanoid = character:WaitForChild("Humanoid", 30) :: Humanoid?
    if humanoid == nil and player.Character ~= character and player.Character ~= nil and retry then
        return self:GetHumanoid(player, player.Character, retry)
    end

    return humanoid
end

local __init = (function()

    table.insert(Character.DefaultConnections, {
        priority = math.huge,
        func = function(player: Player, character: Model) 
            local humanoid = Character:GetHumanoid(player, character, false)
            if humanoid == nil then
                return
            end

            humanoid.WalkSpeed = DEFAULT_WALK_SPEED
            
            local healthConnection
            healthConnection = humanoid.HealthChanged:Connect(function(newHealth)
                if newHealth ~= 0 then return end

                healthConnection:Disconnect()
                task.wait(PLAYER_RESPAWN_TIME)

                player:LoadCharacter()
            end)
        end
    })

    return nil
end)()

return table.freeze(Character) :: CharacterService