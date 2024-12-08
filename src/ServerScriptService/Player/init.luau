local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Character = require(script.Character)

export type PlayerService = {
    OnPlayerAdded: ( self: PlayerService, callback: ( player: Player ) -> (), priority: number? ) -> (),
    OnPlayerRemoving: ( self: PlayerService, callback: ( player: Player ) -> (), priority: number? ) -> (),

    OnCharacterAdded: ( self: PlayerService, callback: ( player: Player, character: Model ) -> (), priority: number? ) -> (),

    Character: Character.CharacterService
}

local playerCallbacks: {
    PlayerAdded:  { { priority: number, func: (player: Player) -> () } },
    PlayerRemoving: { { priority: number, func: (player: Player) -> () }},

    CharacterAdded: { { priority: number, func: (player: Player, character: Model) -> () }}
} = { PlayerAdded = { }, PlayerRemoving = { }, CharacterAdded = {  } }

local Player: PlayerService = { 
    OnPlayerAdded = function(_self, _callback, _priority) end,
    OnPlayerRemoving = function(_self, _callback, _priority) end,

    OnCharacterAdded = function(_self, _callback, _priority) end,

    Character = Character
}

local function __SORTCALLBACKS(name: string)
    table.sort(playerCallbacks[name], function(t1, t2)
        return t1.priority > t2.priority
    end)
end

local function callPlayerAddedCallbacks(player: Player)
    for _, callback in ipairs(playerCallbacks.PlayerAdded) do
        task.spawn(callback.func, player)
    end
end

local function callPlayerRemovingCallbacks(player: Player)
    for _, callback in ipairs(playerCallbacks.PlayerRemoving) do
        task.spawn(callback.func, player)
    end
end

local function callCharacterCallbacks(player: Player, character: Model)
    for _, callback in ipairs(playerCallbacks.CharacterAdded) do
        task.spawn(callback.func, player, character)
    end
end

function Player:OnPlayerAdded(callback: (player: Player) -> (), priority: number?)
    priority = priority or 0
    
    table.insert(playerCallbacks.PlayerAdded, {
        priority = priority :: number,
        func = callback
    })

    __SORTCALLBACKS("PlayerAdded")

    for _, player: Player in ipairs(Players:GetPlayers()) do
        task.spawn(callback, player)
    end
end

function Player:OnPlayerRemoving(callback: (player: Player) -> (), priority: number?)
    priority = priority or 0
    
    table.insert(playerCallbacks.PlayerRemoving, {
        priority = priority :: number,
        func = callback
    })

    __SORTCALLBACKS("PlayerRemoving")
end

function Player:OnCharacterAdded(callback: (player: Player, character: Model) -> (), priority: number?)
    priority = priority or 0
    
    table.insert(playerCallbacks.CharacterAdded, {
        priority = priority :: number,
        func = callback
    })

    __SORTCALLBACKS("CharacterAdded")

    for _, player: Player in ipairs(Players:GetPlayers()) do
        if player.Character then
            task.spawn(callback, player, player.Character)
        end
    end
end

local __init = (function()
    local function connectPlayerAdded(player: Player)
        callPlayerAddedCallbacks(player)
        
        if player.Character then
            callCharacterCallbacks(player, player.Character)
        end

        player.CharacterAppearanceLoaded:Connect(function(character)
            callCharacterCallbacks(player, character)
        end)

        player:LoadCharacter()
    end

    for _, player: Player in ipairs(Players:GetPlayers()) do
        task.spawn(connectPlayerAdded, player)
    end

    Players.PlayerAdded:Connect(connectPlayerAdded)
    Players.PlayerRemoving:Connect(callPlayerRemovingCallbacks)

    if PhysicsService:IsCollisionGroupRegistered("ViewModel") == false then
        PhysicsService:RegisterCollisionGroup("ViewModel")
    end

    if PhysicsService:CollisionGroupsAreCollidable("ViewModel", "Default") == true then
        PhysicsService:CollisionGroupSetCollidable("ViewModel", "Default", false)
    end

    for _, info in ipairs(Character.DefaultConnections) do
        Player:OnCharacterAdded(info.func, info.priority)
    end

    if RunService:IsStudio() == false then
        game:BindToClose(function()
            for _, player in ipairs(Players:GetPlayers()) do
                task.spawn(callPlayerRemovingCallbacks, player)
            end

            task.wait(20)
        end)
    end

    return nil
end)()


return table.freeze(Player) :: PlayerService
