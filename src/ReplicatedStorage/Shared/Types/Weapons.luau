export type WeaponData = {
    Name: string,

	Constants: {
        Damages: { Head: number, Toros: number, HumanoidRootPart: number, Else: number },
		FireRate: number,
		ReloadTime: number,
		ClipSize: number,
		Accuracy: number,
		NumBullets: number,
		FireMode: string,
		Range: number,
		BarrelOffset: CFrame
	},

	Data: {
		CurrentAmmo: number,
		LastShotTick: number,

		IsReloading: boolean,
		IsFiring: boolean,
		IsEquipped: boolean,
	},
} 

return true
