--[[
	Filename: Weapons.client.lua
	Author(s): MagikTheDog
	
	Master of client side for the weapon's systems.
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponTypes = require(ReplicatedStorage.Shared.Types.Weapons)
local SharedWeapons = require(ReplicatedStorage.Shared.Weapons)

export type Weapons = {
	RegisteredWeapons: { [string]: WeaponTypes.WeaponData },

	CurrentWeapon: WeaponTypes.WeaponData?,

	RegisterWeapon: (self: Weapons, weapon: Tool) -> (),

	__index: Weapons
}

local Weapons: Weapons = {
	RegisteredWeapons = {},
	CurrentWeapon = nil,

	RegisterWeapon = function (_self: Weapons, _weapon: Tool) end,

} :: Weapons

Weapons.__index = Weapons

function Weapons:RegisterWeapon(weapon: Tool)
	local weaponId = weapon:GetAttribute("_id")
	if weaponId == nil then
		warn("Weapon has no _id attribute.")
		return
	end

	local weaponData = SharedWeapons.GetDataByName(weapon.Name)
	if weaponData == nil then
		warn("Weapon data not found for weapon: " .. weapon.Name)
		return
	end

	self.RegisteredWeapons[weaponId] = weaponData
end

return table.freeze(Weapons) :: Weapons
