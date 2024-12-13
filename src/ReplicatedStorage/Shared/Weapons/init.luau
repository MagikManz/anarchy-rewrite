local WeaponsTypes = require(script.Parent.Types.Weapons)

local SharedWeapons = { }

function SharedWeapons.GetDataByName(weaponName: string): WeaponsTypes.WeaponData?
    local weaponModule = script.Stats:FindFirstChild(weaponName) :: ModuleScript?
    if weaponModule == nil then
        return nil
    end

    return require(weaponModule) :: WeaponsTypes.WeaponData
end

return SharedWeapons
