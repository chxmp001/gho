-- Roblox Spaceship Script
-- สร้างยานอวกาศขนาดใหญ่พร้อมฟังก์ชั่นสมจริง

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ตั้งค่าเกี่ยวกับยานอวกาศ
local SPACESHIP_SETTINGS = {
	MaxSpeed = 250,
	Acceleration = 50,
	TurnSpeed = 0.05,
	BoostMultiplier = 2,
	FuelCapacity = 1000,
	FuelConsumption = 0.5,
	BoostFuelConsumption = 1.5,
	HoverHeight = 20,
	GravityForce = 0.5,
	MaxHealth = 1000,
	ShieldCapacity = 500,
	ShieldRechargeRate = 5,
	WeaponCooldown = 0.5,
	MissileCooldown = 3,
	LandingGearDeployTime = 1.5
}

-- สร้างยานอวกาศ
local function CreateSpaceship(spawnLocation)
	local spaceship = {}
	spaceship.Model = Instance.new("Model")
	spaceship.Model.Name = "AdvancedSpaceship"

	-- ส่วนหลักของยานอวกาศ
	local body = Instance.new("Part")
	body.Size = Vector3.new(20, 6, 30)
	body.CFrame = spawnLocation
	body.CustomPhysicalProperties = PhysicalProperties.new(2, 0.5, 0.5, 100, 100)
	body.Material = Enum.Material.Metal
	body.BrickColor = BrickColor.new("Medium stone grey")
	body.CanCollide = true
	body.Anchored = false
	body.Name = "Body"

	-- เพิ่มความเรียบให้กับตัวยาน
	local bodySpecial = Instance.new("SpecialMesh")
	bodySpecial.MeshType = Enum.MeshType.FileMesh
	bodySpecial.Scale = Vector3.new(1, 1, 1)
	bodySpecial.Parent = body

	-- เพิ่มส่วนปีกและรายละเอียดเพิ่มเติม
	local wings = Instance.new("Part")
	wings.Size = Vector3.new(40, 1, 15)
	wings.CFrame = body.CFrame * CFrame.new(0, -1, 0)
	wings.Material = Enum.Material.Metal
	wings.BrickColor = BrickColor.new("Really black")
	wings.CanCollide = true
	wings.Name = "Wings"

	-- เพิ่มส่วนที่เป็นห้องคนขับ
	local cockpit = Instance.new("Part")
	cockpit.Size = Vector3.new(10, 3, 8)
	cockpit.CFrame = body.CFrame * CFrame.new(0, 3, -5)
	cockpit.Material = Enum.Material.Glass
	cockpit.Transparency = 0.5
	cockpit.BrickColor = BrickColor.new("Bright blue")
	cockpit.CanCollide = true
	cockpit.Name = "Cockpit"

	-- เพิ่มส่วนที่เป็นเครื่องยนต์
	local engine1 = Instance.new("Part")
	engine1.Size = Vector3.new(5, 5, 8)
	engine1.CFrame = body.CFrame * CFrame.new(-8, 0, 10)
	engine1.Material = Enum.Material.Metal
	engine1.BrickColor = BrickColor.new("Dark grey")
	engine1.CanCollide = true
	engine1.Name = "EngineLeft"

	local engine2 = Instance.new("Part")
	engine2.Size = Vector3.new(5, 5, 8)
	engine2.CFrame = body.CFrame * CFrame.new(8, 0, 10)
	engine2.Material = Enum.Material.Metal
	engine2.BrickColor = BrickColor.new("Dark grey")
	engine2.CanCollide = true
	engine2.Name = "EngineRight"

	-- เพิ่มส่วนที่เป็นระบบอาวุธ
	local weapon1 = Instance.new("Part")
	weapon1.Size = Vector3.new(2, 2, 10)
	weapon1.CFrame = body.CFrame * CFrame.new(-10, 0, -5)
	weapon1.Material = Enum.Material.Metal
	weapon1.BrickColor = BrickColor.new("Really red")
	weapon1.CanCollide = true
	weapon1.Name = "WeaponLeft"

	local weapon2 = Instance.new("Part")
	weapon2.Size = Vector3.new(2, 2, 10)
	weapon2.CFrame = body.CFrame * CFrame.new(10, 0, -5)
	weapon2.Material = Enum.Material.Metal
	weapon2.BrickColor = BrickColor.new("Really red")
	weapon2.CanCollide = true
	weapon2.Name = "WeaponRight"

	-- เพิ่มส่วนที่เป็นระบบขา Landing Gear
	local landingGear1 = Instance.new("Part")
	landingGear1.Size = Vector3.new(2, 6, 2)
	landingGear1.CFrame = body.CFrame * CFrame.new(-10, -6, 0)
	landingGear1.Material = Enum.Material.Metal
	landingGear1.BrickColor = BrickColor.new("Really black")
	landingGear1.CanCollide = true
	landingGear1.Name = "LandingGearLeft"

	local landingGear2 = Instance.new("Part")
	landingGear2.Size = Vector3.new(2, 6, 2)
	landingGear2.CFrame = body.CFrame * CFrame.new(10, -6, 0)
	landingGear2.Material = Enum.Material.Metal
	landingGear2.BrickColor = BrickColor.new("Really black")
	landingGear2.CanCollide = true
	landingGear2.Name = "LandingGearRight"

	local landingGear3 = Instance.new("Part")
	landingGear3.Size = Vector3.new(2, 6, 2)
	landingGear3.CFrame = body.CFrame * CFrame.new(0, -6, -10)
	landingGear3.Material = Enum.Material.Metal
	landingGear3.BrickColor = BrickColor.new("Really black")
	landingGear3.CanCollide = true
	landingGear3.Name = "LandingGearFront"

	-- เพิ่มระบบแสงและเอฟเฟกต์
	local light1 = Instance.new("PointLight")
	light1.Color = Color3.fromRGB(0, 255, 255)
	light1.Range = 15
	light1.Brightness = 1
	light1.Parent = body

	local light2 = Instance.new("SpotLight")
	light2.Color = Color3.fromRGB(255, 255, 255)
	light2.Angle = 45
	light2.Range = 50
	light2.Brightness = 2
	light2.Parent = cockpit

	-- เพิ่มเอฟเฟกต์ไอพ่นของเครื่องยนต์
	local engineEffect1 = Instance.new("ParticleEmitter")
	engineEffect1.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 0, 128))
	engineEffect1.Size = NumberSequence.new(1, 0)
	engineEffect1.Transparency = NumberSequence.new(0, 1)
	engineEffect1.Rate = 100
	engineEffect1.Speed = NumberRange.new(10, 20)
	engineEffect1.Parent = engine1

	local engineEffect2 = engineEffect1:Clone()
	engineEffect2.Parent = engine2

	-- เพิ่มเอฟเฟกต์ shield
	local shieldEffect = Instance.new("ParticleEmitter")
	shieldEffect.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
	shieldEffect.Size = NumberSequence.new(0.5)
	shieldEffect.Transparency = NumberSequence.new(0.8)
	shieldEffect.Rate = 10
	shieldEffect.Speed = NumberRange.new(1, 2)
	shieldEffect.Parent = body
	shieldEffect.Enabled = false

	-- สร้าง Welds เพื่อยึดชิ้นส่วนต่างๆ เข้าด้วยกัน
	local bodyWeld = Instance.new("WeldConstraint")
	bodyWeld.Part0 = body
	bodyWeld.Part1 = wings
	bodyWeld.Parent = body

	local cockpitWeld = Instance.new("WeldConstraint")
	cockpitWeld.Part0 = body
	cockpitWeld.Part1 = cockpit
	cockpitWeld.Parent = body

	local engine1Weld = Instance.new("WeldConstraint")
	engine1Weld.Part0 = body
	engine1Weld.Part1 = engine1
	engine1Weld.Parent = body

	local engine2Weld = Instance.new("WeldConstraint")
	engine2Weld.Part0 = body
	engine2Weld.Part1 = engine2
	engine2Weld.Parent = body

	local weapon1Weld = Instance.new("WeldConstraint")
	weapon1Weld.Part0 = body
	weapon1Weld.Part1 = weapon1
	weapon1Weld.Parent = body

	local weapon2Weld = Instance.new("WeldConstraint")
	weapon2Weld.Part0 = body
	weapon2Weld.Part1 = weapon2
	weapon2Weld.Parent = body

	local landingGear1Weld = Instance.new("WeldConstraint")
	landingGear1Weld.Part0 = body
	landingGear1Weld.Part1 = landingGear1
	landingGear1Weld.Parent = body

	local landingGear2Weld = Instance.new("WeldConstraint")
	landingGear2Weld.Part0 = body
	landingGear2Weld.Part1 = landingGear2
	landingGear2Weld.Parent = body

	local landingGear3Weld = Instance.new("WeldConstraint")
	landingGear3Weld.Part0 = body
	landingGear3Weld.Part1 = landingGear3
	landingGear3Weld.Parent = body

	-- เพิ่มชิ้นส่วนทั้งหมดเข้าไปในโมเดล
	body.Parent = spaceship.Model
	wings.Parent = spaceship.Model
	cockpit.Parent = spaceship.Model
	engine1.Parent = spaceship.Model
	engine2.Parent = spaceship.Model
	weapon1.Parent = spaceship.Model
	weapon2.Parent = spaceship.Model
	landingGear1.Parent = spaceship.Model
	landingGear2.Parent = spaceship.Model
	landingGear3.Parent = spaceship.Model

	-- ตั้งค่า primary part
	spaceship.Model.PrimaryPart = body

	-- ตั้งค่าตัวแปรที่สำคัญ
	spaceship.Speed = 0
	spaceship.CurrentFuel = SPACESHIP_SETTINGS.FuelCapacity
	spaceship.Health = SPACESHIP_SETTINGS.MaxHealth
	spaceship.Shield = SPACESHIP_SETTINGS.ShieldCapacity
	spaceship.LandingGearDeployed = true
	spaceship.WeaponCooldown = 0
	spaceship.MissileCooldown = 0
	spaceship.IsFlying = false
	spaceship.BoostActive = false
	spaceship.ShieldActive = false

	-- ฟังก์ชั่นควบคุมยานอวกาศ
	spaceship.ControlConnections = {}

	-- ฟังก์ชั่นเปิดใช้งานยานอวกาศ
	function spaceship:Activate(player)
		if not self.IsFlying then
			self.IsFlying = true

			-- สร้าง BodyGyro และ BodyVelocity
			local gyro = Instance.new("BodyGyro")
			gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
			gyro.P = 40000
			gyro.D = 1000
			gyro.CFrame = self.Model.PrimaryPart.CFrame
			gyro.Parent = self.Model.PrimaryPart
			self.Gyro = gyro

			local velocity = Instance.new("BodyVelocity")
			velocity.MaxForce = Vector3.new(400000, 400000, 400000)
			velocity.P = 40000
			velocity.Velocity = Vector3.new(0, 0, 0)
			velocity.Parent = self.Model.PrimaryPart
			self.Velocity = velocity

			-- ฟังก์ชั่นอัพเดทการควบคุม
			local function updateControl()
				local moveDirection = Vector3.new(0, 0, 0)

				if UserInputService:IsKeyDown(Enum.KeyCode.W) then
					moveDirection = moveDirection + self.Model.PrimaryPart.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then
					moveDirection = moveDirection - self.Model.PrimaryPart.CFrame.LookVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then
					moveDirection = moveDirection - self.Model.PrimaryPart.CFrame.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then
					moveDirection = moveDirection + self.Model.PrimaryPart.CFrame.RightVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
					moveDirection = moveDirection + self.Model.PrimaryPart.CFrame.UpVector
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					moveDirection = moveDirection - self.Model.PrimaryPart.CFrame.UpVector
				end

				-- ปรับความเร็ว
				if moveDirection.Magnitude > 0.1 then
					if self.CurrentFuel > 0 then
						self.Speed = math.min(self.Speed + SPACESHIP_SETTINGS.Acceleration * 0.1, SPACESHIP_SETTINGS.MaxSpeed)

						-- ใช้น้ำมันเมื่อเร่งความเร็ว
						local fuelUsage = SPACESHIP_SETTINGS.FuelConsumption
						if self.BoostActive then
							fuelUsage = SPACESHIP_SETTINGS.BoostFuelConsumption
						end
						self.CurrentFuel = math.max(0, self.CurrentFuel - fuelUsage * 0.1)
					else
						self.Speed = math.max(0, self.Speed - SPACESHIP_SETTINGS.Acceleration * 0.2)
					end
				else
					self.Speed = math.max(0, self.Speed - SPACESHIP_SETTINGS.Acceleration * 0.1)
				end

				moveDirection = moveDirection.Unit

				-- เพิ่มความเร็วเมื่อใช้ Boost
				local finalSpeed = self.Speed
				if self.BoostActive and self.CurrentFuel > 0 then
					finalSpeed = finalSpeed * SPACESHIP_SETTINGS.BoostMultiplier
				end

				self.Velocity.Velocity = moveDirection * finalSpeed

				-- อัพเดทเอฟเฟกต์เครื่องยนต์
				local enginePower = self.Speed / SPACESHIP_SETTINGS.MaxSpeed
				for _, engine in ipairs({self.Model.EngineLeft, self.Model.EngineRight}) do
					if engine:FindFirstChild("ParticleEmitter") then
						engine.ParticleEmitter.Rate = 100 * enginePower
						engine.ParticleEmitter.Speed = NumberRange.new(10 * enginePower, 20 * enginePower)
					end
				end

				-- อัพเดทเอฟเฟกต์ shield
				if self.ShieldActive then
					if self.Shield > 0 then
						self.Shield = math.max(0, self.Shield - 0.1)
						self.Model.Body.ParticleEmitter.Enabled = true
					else
						self.ShieldActive = false
						self.Model.Body.ParticleEmitter.Enabled = false
					end
				elseif not self.ShieldActive and self.Shield < SPACESHIP_SETTINGS.ShieldCapacity then
					self.Shield = math.min(SPACESHIP_SETTINGS.ShieldCapacity, self.Shield + SPACESHIP_SETTINGS.ShieldRechargeRate * 0.1)
				end

				-- อัพเดทระยะเวลาคูลดาวน์
				if self.WeaponCooldown > 0 then
					self.WeaponCooldown = math.max(0, self.WeaponCooldown - 0.1)
				end
				if self.MissileCooldown > 0 then
					self.MissileCooldown = math.max(0, self.MissileCooldown - 0.1)
				end
			end

			-- ฟังก์ชั่นอัพเดทการหันยาน
			local function updateRotation()
				local lookDirection = Vector3.new(0, 0, 0)

				if UserInputService:IsKeyDown(Enum.KeyCode.Up) then
					lookDirection = lookDirection + Vector3.new(0, 0, -1)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Down) then
					lookDirection = lookDirection + Vector3.new(0, 0, 1)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Left) then
					lookDirection = lookDirection + Vector3.new(-1, 0, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Right) then
					lookDirection = lookDirection + Vector3.new(1, 0, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
					lookDirection = lookDirection + Vector3.new(0, -1, 0)
				end
				if UserInputService:IsKeyDown(Enum.KeyCode.E) then
					lookDirection = lookDirection + Vector3.new(0, 1, 0)
				end

				if lookDirection.Magnitude > 0.1 then
					local currentCFrame = self.Gyro.CFrame
					local targetCFrame = currentCFrame * CFrame.fromOrientation(
						lookDirection.Z * SPACESHIP_SETTINGS.TurnSpeed,
						-lookDirection.X * SPACESHIP_SETTINGS.TurnSpeed,
						-lookDirection.Y * SPACESHIP_SETTINGS.TurnSpeed
					)
					self.Gyro.CFrame = targetCFrame
				end
			end

			-- เชื่อมต่อการควบคุม
			local controlConnection = RunService.Heartbeat:Connect(function(dt)
				updateControl()
				updateRotation()
			end)
			table.insert(self.ControlConnections, controlConnection)

			-- เพิ่มการควบคุมเฉพาะที่
			local function handleInput(input, gameProcessed)
				if not gameProcessed then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.F then
							if input.UserInputState == Enum.UserInputState.Begin then
								self:ToggleLandingGear()
							end
						elseif input.KeyCode == Enum.KeyCode.R then
							if input.UserInputState == Enum.UserInputState.Begin then
								self:FireWeapon()
							end
						elseif input.KeyCode == Enum.KeyCode.T then
							if input.UserInputState == Enum.UserInputState.Begin then
								self:FireMissile()
							end
						elseif input.KeyCode == Enum.KeyCode.B then
							if input.UserInputState == Enum.UserInputState.Begin then
								self.BoostActive = not self.BoostActive
							end
						elseif input.KeyCode == Enum.KeyCode.V then
							if input.UserInputState == Enum.UserInputState.Begin then
								self:ToggleShield()
							end
						end
					end
				end
			end

			local inputConnection = UserInputService.InputBegan:Connect(handleInput)
			table.insert(self.ControlConnections, inputConnection)

			-- ใส่ที่นั่งสำหรับผู้เล่น
			local seat = Instance.new("VehicleSeat")
			seat.MaxSpeed = 0
			seat.Torque = 0
			seat.TurnSpeed = 0
			seat.Size = Vector3.new(4, 1, 4)
			seat.CFrame = self.Model.Cockpit.CFrame * CFrame.new(0, -1, 0)
			seat.Transparency = 1
			seat.CanCollide = false
			seat.Parent = self.Model

			local seatWeld = Instance.new("WeldConstraint")
			seatWeld.Part0 = self.Model.PrimaryPart
			seatWeld.Part1 = seat
			seatWeld.Parent = seat

			self.Seat = seat

			-- แสดงข้อมูลสถานะ
			local function createStatusDisplay()
				local statusGui = Instance.new("BillboardGui")
				statusGui.Size = UDim2.new(10, 0, 5, 0)
				statusGui.StudsOffset = Vector3.new(0, 5, 0)
				statusGui.AlwaysOnTop = true
				statusGui.Parent = self.Model.PrimaryPart

				local statusFrame = Instance.new("Frame")
				statusFrame.Size = UDim2.new(1, 0, 1, 0)
				statusFrame.BackgroundTransparency = 0.5
				statusFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				statusFrame.Parent = statusGui

				local statusLayout = Instance.new("UIListLayout")
				statusLayout.Parent = statusFrame

				local fuelLabel = Instance.new("TextLabel")
				fuelLabel.Size = UDim2.new(1, 0, 0.2, 0)
				fuelLabel.BackgroundTransparency = 1
				fuelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				fuelLabel.TextScaled = true
				fuelLabel.Font = Enum.Font.SourceSansBold
				fuelLabel.Parent = statusFrame

				local healthLabel = Instance.new("TextLabel")
				healthLabel.Size = UDim2.new(1, 0, 0.2, 0)
				healthLabel.BackgroundTransparency = 1
				healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				healthLabel.TextScaled = true
				healthLabel.Font = Enum.Font.SourceSansBold
				healthLabel.Parent = statusFrame

				local shieldLabel = Instance.new("TextLabel")
				shieldLabel.Size = UDim2.new(1, 0, 0.2, 0)
				shieldLabel.BackgroundTransparency = 1
				shieldLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				shieldLabel.TextScaled = true
				shieldLabel.Font = Enum.Font.SourceSansBold
				shieldLabel.Parent = statusFrame

				local speedLabel = Instance.new("TextLabel")
				speedLabel.Size = UDim2.new(1, 0, 0.2, 0)
				speedLabel.BackgroundTransparency = 1
				speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				speedLabel.TextScaled = true
				speedLabel.Font = Enum.Font.SourceSansBold
				speedLabel.Parent = statusFrame

				local statusConnection = RunService.Heartbeat:Connect(function()
					fuelLabel.Text = "Fuel: " .. math.floor(self.CurrentFuel / SPACESHIP_SETTINGS.FuelCapacity * 100) .. "%"
					healthLabel.Text = "Health: " .. math.floor(self.Health / SPACESHIP_SETTINGS.MaxHealth * 100) .. "%"
					shieldLabel.Text = "Shield: " .. math.floor(self.Shield / SPACESHIP_SETTINGS.ShieldCapacity * 100) .. "%"
					speedLabel.Text = "Speed: " .. math.floor(self.Speed) .. " km/h"
				end)

				table.insert(self.ControlConnections, statusConnection)
				self.StatusDisplay = statusGui
			end

			createStatusDisplay()

			-- เล่นเสียงเมื่อเปิดใช้งานยาน
			local activationSound = Instance.new("Sound")
			activationSound.SoundId = "rbxassetid://1569972625"
			activationSound.Volume = 1
			activationSound.Parent = self.Model.PrimaryPart
			activationSound:Play()

			-- เพิ่มเอฟเฟกต์แสงเมื่อเปิดใช้งานยาน
			local activationLight = Instance.new("PointLight")
			activationLight.Color = Color3.fromRGB(0, 255, 255)
			activationLight.Range = 30
			activationLight.Brightness = 5
			activationLight.Parent = self.Model.PrimaryPart

			-- เอฟเฟกต์การเปิดใช้งานยาน
			local function playActivationEffect()
				local effect = Instance.new("ParticleEmitter")
				effect.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(0, 0, 128))
				effect.Size = NumberSequence.new(5, 0)
				effect.Transparency = NumberSequence.new(0, 1)
				effect.Rate = 100
				effect.Speed = NumberRange.new(10, 20)
				effect.Parent = self.Model.PrimaryPart
				effect.Lifetime = NumberRange.new(0.5, 1)
				effect.Enabled = true

				delay(2, function()
					effect.Enabled = false
					wait(2)
					if effect then
						effect:Destroy()
					end
				end)

				delay(2, function()
					if activationLight then
						activationLight:Destroy()
					end
				end)
			end

			playActivationEffect()

			return true
		end
		return false
	end

	-- ฟังก์ชั่นหยุดการควบคุมยานอวกาศ
	function spaceship:Deactivate()
		if self.IsFlying then
			self.IsFlying = false

			-- ลบการควบคุมต่างๆ
			for _, connection in ipairs(self.ControlConnections) do
				connection:Disconnect()
			end
			self.ControlConnections = {}

			-- ลบ BodyGyro และ BodyVelocity
			if self.Gyro then
				self.Gyro:Destroy()
				self.Gyro = nil
			end
			if self.Velocity then
				self.Velocity:Destroy()
				self.Velocity = nil
			end

			-- ลบแสดงข้อมูลสถานะ
			if self.StatusDisplay then
				self.StatusDisplay:Destroy()
				self.StatusDisplay = nil
			end

			-- เล่นเสียงเมื่อปิดใช้งานยาน
			local deactivationSound = Instance.new("Sound")
			deactivationSound.SoundId = "rbxassetid://1569972625"
			deactivationSound.Volume = 0.5
			deactivationSound.PlaybackSpeed = 0.5
			deactivationSound.Parent = self.Model.PrimaryPart
			deactivationSound:Play()

			return true
		end
		return false
	end

	function spaceship:FireWeapon()
		if self.WeaponCooldown <= 0 then
			-- ยิงอาวุธจากที่ติดตั้งอาวุธทั้งสองข้าง
			local function fireFromWeapon(weapon)
				local projectile = Instance.new("Part")
				projectile.Size = Vector3.new(0.5, 0.5, 2)
				projectile.CFrame = weapon.CFrame * CFrame.new(0, 0, -5)
				projectile.Anchored = false
				projectile.CanCollide = false
				projectile.Material = Enum.Material.Neon
				projectile.BrickColor = BrickColor.new("Really red")
				projectile.Name = "SpaceshipProjectile"

				-- เพิ่มเอฟเฟกต์แสงให้กระสุน
				local light = Instance.new("PointLight")
				light.Color = Color3.fromRGB(255, 0, 0)
				light.Range = 10
				light.Brightness = 2
				light.Parent = projectile

				-- เพิ่มเอฟเฟกต์เส้นทางของกระสุน
				local trail = Instance.new("Trail")
				trail.Attachment0 = Instance.new("Attachment", projectile)
				trail.Attachment0.Position = Vector3.new(0, 0, 1)
				trail.Attachment1 = Instance.new("Attachment", projectile)
				trail.Attachment1.Position = Vector3.new(0, 0, -1)
				trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
				trail.Transparency = NumberSequence.new(0, 1)
				trail.Lifetime = 0.5
				trail.Parent = projectile

				-- เพิ่มการเคลื่อนที่ของกระสุน
				local velocity = Instance.new("BodyVelocity")
				velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				velocity.Velocity = weapon.CFrame.LookVector * 200
				velocity.Parent = projectile

				-- เพิ่มความเสียหายเมื่อกระสุนชนกับวัตถุอื่น
				local damage = 20

				-- ตั้งค่าให้กระสุนยิงออกจากยานอวกาศ
				projectile.Parent = workspace

				-- เล่นเสียงเมื่อยิงกระสุน
				local fireSound = Instance.new("Sound")
				fireSound.SoundId = "rbxassetid://130113322"
				fireSound.Volume = 0.5
				fireSound.PlaybackSpeed = 1.5
				fireSound.Parent = weapon
				fireSound:Play()

				-- ตรวจสอบการชนของกระสุน
				local connection
				connection = projectile.Touched:Connect(function(hit)
					if hit.Parent and hit.Parent ~= self.Model and hit.Parent:FindFirstChild("Humanoid") then
						-- ถ้าชนกับผู้เล่น
						hit.Parent.Humanoid:TakeDamage(damage)

						-- เล่นเอฟเฟกต์การระเบิด
						self:CreateExplosionEffect(projectile.Position, 5, Color3.fromRGB(255, 0, 0))

						-- ลบกระสุน
						connection:Disconnect()
						projectile:Destroy()
					elseif hit.Parent and hit.Parent ~= self.Model and hit.Parent:FindFirstChild("SpaceshipProjectile") == nil then
						-- ถ้าชนกับวัตถุอื่นที่ไม่ใช่ผู้เล่นหรือกระสุนอื่น
						self:CreateExplosionEffect(projectile.Position, 5, Color3.fromRGB(255, 0, 0))

						-- ลบกระสุน
						connection:Disconnect()
						projectile:Destroy()
					end
				end)

				-- ลบกระสุนหลังจากเวลาผ่านไป
				delay(3, function()
					if projectile and projectile.Parent then
						connection:Disconnect()
						projectile:Destroy()
					end
				end)
			end

			-- ยิงจากทั้งสองปืน
			fireFromWeapon(self.Model.WeaponLeft)
			fireFromWeapon(self.Model.WeaponRight)

			-- ตั้งค่าคูลดาวน์
			self.WeaponCooldown = SPACESHIP_SETTINGS.WeaponCooldown

			return true
		end
		return false
	end

	-- ฟังก์ชั่นยิงขีปนาวุธ
	function spaceship:FireMissile()
		if self.MissileCooldown <= 0 then
			-- สร้างขีปนาวุธ
			local missile = Instance.new("Part")
			missile.Size = Vector3.new(1, 1, 3)
			missile.CFrame = self.Model.PrimaryPart.CFrame * CFrame.new(0, -2, -5)
			missile.Anchored = false
			missile.CanCollide = false
			missile.Material = Enum.Material.Metal
			missile.BrickColor = BrickColor.new("Dark grey")
			missile.Name = "SpaceshipMissile"

			-- เพิ่มเอฟเฟกต์ไฟฟ้าที่ขีปนาวุธ
			local fire = Instance.new("Fire")
			fire.Size = 3
			fire.Heat = 10
			fire.Color = Color3.fromRGB(255, 0, 0)
			fire.SecondaryColor = Color3.fromRGB(255, 128, 0)
			fire.Parent = missile

			-- เพิ่มเอฟเฟกต์ควันที่ขีปนาวุธ
			local smoke = Instance.new("Smoke")
			smoke.Size = 3
			smoke.RiseVelocity = 10
			smoke.Color = Color3.fromRGB(100, 100, 100)
			smoke.Parent = missile

			-- เพิ่มเอฟเฟกต์เส้นทางของขีปนาวุธ
			local trail = Instance.new("Trail")
			trail.Attachment0 = Instance.new("Attachment", missile)
			trail.Attachment0.Position = Vector3.new(0, 0, 1.5)
			trail.Attachment1 = Instance.new("Attachment", missile)
			trail.Attachment1.Position = Vector3.new(0, 0, -1.5)
			trail.Color = ColorSequence.new(Color3.fromRGB(255, 128, 0))
			trail.Transparency = NumberSequence.new(0, 1)
			trail.Lifetime = 1
			trail.Parent = missile

			-- เพิ่มการเคลื่อนที่ของขีปนาวุธ
			local velocity = Instance.new("BodyVelocity")
			velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			velocity.Velocity = self.Model.PrimaryPart.CFrame.LookVector * 150
			velocity.Parent = missile

			-- เล่นเสียงเมื่อยิงขีปนาวุธ
			local missileSound = Instance.new("Sound")
			missileSound.SoundId = "rbxassetid://130113322"
			missileSound.Volume = 1
			missileSound.PlaybackSpeed = 0.8
			missileSound.Parent = missile
			missileSound:Play()

			-- ตั้งค่าความเสียหาย
			local damage = 100

			-- ตั้งค่าให้ขีปนาวุธยิงออกจากยานอวกาศ
			missile.Parent = workspace

			-- ตรวจสอบการชนของขีปนาวุธ
			local connection
			connection = missile.Touched:Connect(function(hit)
				if hit.Parent and hit.Parent ~= self.Model and hit.Parent:FindFirstChild("SpaceshipMissile") == nil then
					-- เล่นเอฟเฟกต์การระเบิด
					self:CreateExplosionEffect(missile.Position, 15, Color3.fromRGB(255, 128, 0))

					-- สร้างความเสียหายรอบๆ
					local explosionRadius = 10
					for _, obj in pairs(workspace:GetChildren()) do
						if obj:IsA("Model") and obj ~= self.Model and obj:FindFirstChild("Humanoid") then
							local humanoid = obj:FindFirstChild("Humanoid")
							local rootPart = obj:FindFirstChild("HumanoidRootPart")

							if humanoid and rootPart then
								local distance = (rootPart.Position - missile.Position).Magnitude
								if distance <= explosionRadius then
									local damageAmount = damage * (1 - (distance / explosionRadius))
									humanoid:TakeDamage(damageAmount)
								end
							end
						end
					end

					-- ลบขีปนาวุธ
					connection:Disconnect()
					missile:Destroy()

					-- เล่นเสียงระเบิด
					local explosionSound = Instance.new("Sound")
					explosionSound.SoundId = "rbxassetid://142070127"
					explosionSound.Volume = 1
					explosionSound.PlaybackSpeed = 1
					explosionSound.Parent = workspace
					explosionSound.Position = missile.Position
					explosionSound:Play()

					game.Debris:AddItem(explosionSound, 3)
				end
			end)

			-- ลบขีปนาวุธหลังจากเวลาผ่านไป
			delay(5, function()
				if missile and missile.Parent then
					-- เล่นเอฟเฟกต์การระเบิด
					self:CreateExplosionEffect(missile.Position, 15, Color3.fromRGB(255, 128, 0))

					connection:Disconnect()
					missile:Destroy()
				end
			end)

			-- ตั้งค่าคูลดาวน์
			self.MissileCooldown = SPACESHIP_SETTINGS.MissileCooldown

			return true
		end
		return false
	end

	-- ฟังก์ชั่นเปิด/ปิดขาลงจอด
	function spaceship:ToggleLandingGear()
		if self.LandingGearDeployed then
			-- เก็บขาลงจอด
			for _, gear in ipairs({self.Model.LandingGearLeft, self.Model.LandingGearRight, self.Model.LandingGearFront}) do
				local targetPosition = gear.Position + Vector3.new(0, 5, 0)
				local tween = TweenService:Create(gear, TweenInfo.new(SPACESHIP_SETTINGS.LandingGearDeployTime), {
					Position = targetPosition
				})
				tween:Play()
			end

			-- เล่นเสียงเก็บขาลงจอด
			local gearSound = Instance.new("Sound")
			gearSound.SoundId = "rbxassetid://1569972625"
			gearSound.Volume = 0.5
			gearSound.PlaybackSpeed = 1.5
			gearSound.Parent = self.Model.PrimaryPart
			gearSound:Play()

			self.LandingGearDeployed = false
		else
			-- กางขาลงจอด
			for _, gear in ipairs({self.Model.LandingGearLeft, self.Model.LandingGearRight, self.Model.LandingGearFront}) do
				local targetPosition = gear.Position - Vector3.new(0, 5, 0)
				local tween = TweenService:Create(gear, TweenInfo.new(SPACESHIP_SETTINGS.LandingGearDeployTime), {
					Position = targetPosition
				})
				tween:Play()
			end

			-- เล่นเสียงกางขาลงจอด
			local gearSound = Instance.new("Sound")
			gearSound.SoundId = "rbxassetid://1569972625"
			gearSound.Volume = 0.5
			gearSound.PlaybackSpeed = 1.2
			gearSound.Parent = self.Model.PrimaryPart
			gearSound:Play()

			self.LandingGearDeployed = true
		end

		return true
	end

	-- ฟังก์ชั่นเปิด/ปิดโล่ป้องกัน
	function spaceship:ToggleShield()
		self.ShieldActive = not self.ShieldActive

		-- เล่นเสียงเปิด/ปิดโล่
		local shieldSound = Instance.new("Sound")
		if self.ShieldActive then
			shieldSound.SoundId = "rbxassetid://130113322"
			shieldSound.Volume = 0.5
			shieldSound.PlaybackSpeed = 0.5
		else
			shieldSound.SoundId = "rbxassetid://130113322"
			shieldSound.Volume = 0.5
			shieldSound.PlaybackSpeed = 0.3
		end
		shieldSound.Parent = self.Model.PrimaryPart
		shieldSound:Play()

		-- เปิด/ปิดเอฟเฟกต์โล่
		self.Model.Body.ParticleEmitter.Enabled = self.ShieldActive

		return true
	end

	-- ฟังก์ชั่นเอฟเฟกต์การระเบิด
	function spaceship:CreateExplosionEffect(position, size, color)
		local explosion = Instance.new("Explosion")
		explosion.Position = position
		explosion.BlastRadius = size
		explosion.BlastPressure = 0
		explosion.Visible = true
		explosion.Parent = workspace

		-- แก้ไขสีของเอฟเฟกต์การระเบิด
		for _, child in pairs(explosion:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				child.Color = ColorSequence.new(color)
			end
		end

		-- ลบเอฟเฟกต์การระเบิดหลังจากเวลาผ่านไป
		game.Debris:AddItem(explosion, 2)

		return explosion
	end

	-- ฟังก์ชั่นที่ทำให้ได้รับความเสียหาย
	function spaceship:TakeDamage(amount)
		-- ตรวจสอบว่าโล่ป้องกันเปิดอยู่หรือไม่
		if self.ShieldActive and self.Shield > 0 then
			-- ลดความเสียหายที่ได้รับลงครึ่งหนึ่ง
			amount = amount * 0.5

			-- ลดพลังงานโล่
			self.Shield = math.max(0, self.Shield - amount)

			-- ถ้าพลังงานโล่หมด ปิดโล่
			if self.Shield <= 0 then
				self.ShieldActive = false
				self.Model.Body.ParticleEmitter.Enabled = false
			end
		else
			-- ลดพลังงานชีวิต
			self.Health = math.max(0, self.Health - amount)

			-- เล่นเสียงเมื่อได้รับความเสียหาย
			local damageSound = Instance.new("Sound")
			damageSound.SoundId = "rbxassetid://1565384019"
			damageSound.Volume = 1
			damageSound.PlaybackSpeed = 1
			damageSound.Parent = self.Model.PrimaryPart
			damageSound:Play()

			-- ถ้าพลังงานชีวิตหมด ทำลายยานอวกาศ
			if self.Health <= 0 then
				self:Destroy()
			end
		end

		return true
	end

	-- ฟังก์ชั่นการเติมน้ำมัน
	function spaceship:Refuel(amount)
		self.CurrentFuel = math.min(SPACESHIP_SETTINGS.FuelCapacity, self.CurrentFuel + amount)

		-- เล่นเสียงเติมน้ำมัน
		local refuelSound = Instance.new("Sound")
		refuelSound.SoundId = "rbxassetid://131436155"
		refuelSound.Volume = 0.5
		refuelSound.PlaybackSpeed = 1
		refuelSound.Parent = self.Model.PrimaryPart
		refuelSound:Play()

		return true
	end

	-- ฟังก์ชั่นการซ่อมแซม
	function spaceship:Repair(amount)
		self.Health = math.min(SPACESHIP_SETTINGS.MaxHealth, self.Health + amount)

		-- เล่นเสียงซ่อมแซม
		local repairSound = Instance.new("Sound")
		repairSound.SoundId = "rbxassetid://131436155"
		repairSound.Volume = 0.5
		repairSound.PlaybackSpeed = 1.2
		repairSound.Parent = self.Model.PrimaryPart
		repairSound:Play()

		return true
	end

	-- ฟังก์ชั่นการทำลายยานอวกาศ
	function spaceship:Destroy()
		-- เล่นเอฟเฟกต์การระเบิด
		self:CreateExplosionEffect(self.Model.PrimaryPart.Position, 20, Color3.fromRGB(255, 128, 0))

		-- เล่นเสียงระเบิด
		local explosionSound = Instance.new("Sound")
		explosionSound.SoundId = "rbxassetid://142070127"
		explosionSound.Volume = 1
		explosionSound.PlaybackSpeed = 0.8
		explosionSound.Parent = workspace
		explosionSound.Position = self.Model.PrimaryPart.Position
		explosionSound:Play()

		-- ลบยานอวกาศ
		if self.Model then
			self.Model:Destroy()
		end

		-- ลบการควบคุมต่างๆ
		for _, connection in ipairs(self.ControlConnections) do
			connection:Disconnect()
		end
		self.ControlConnections = {}

		game.Debris:AddItem(explosionSound, 3)

		return true
	end

	-- ฟังก์ชั่นที่สร้างยานอวกาศ
	function CreateSpaceshipManager()
		local spaceshipManager = {}
		spaceshipManager.Spaceships = {}

		-- ฟังก์ชั่นที่สร้างยานอวกาศใหม่
		function spaceshipManager:CreateSpaceship(player, spawnLocation)
			if not spawnLocation then
				spawnLocation = CFrame.new(0, 50, 0)
			end

			local spaceship = CreateSpaceship(spawnLocation)
			spaceship.Model.Parent = workspace
			spaceship.Owner = player

			table.insert(self.Spaceships, spaceship)

			return spaceship
		end

		-- ฟังก์ชั่นที่ลบยานอวกาศ
		function spaceshipManager:DestroySpaceship(spaceship)
			for i, ship in ipairs(self.Spaceships) do
				if ship == spaceship then
					table.remove(self.Spaceships, i)
					spaceship:Destroy()
					break
				end
			end
		end

		-- ฟังก์ชั่นที่หายานอวกาศของผู้เล่น
		function spaceshipManager:GetPlayerSpaceship(player)
			for _, spaceship in ipairs(self.Spaceships) do
				if spaceship.Owner == player then
					return spaceship
				end
			end
			return nil
		end

		return spaceshipManager
	end

	-- ฟังก์ชั่นที่สร้างยานอวกาศสำหรับผู้เล่น
	local function onPlayerAdded(player)
		-- สร้างคำสั่งที่ใช้ในการสร้างยานอวกาศ
		local function onChatted(message)
			if message:lower() == "/spaceship" then
				local character = player.Character
				if character and character:FindFirstChild("HumanoidRootPart") then
					local spawnLocation = character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
					local spaceship = spaceshipManager:CreateSpaceship(player, spawnLocation)
					spaceship:Activate(player)

					-- แสดงข้อความที่บอกวิธีการควบคุม
					local hint = Instance.new("Hint")
					hint.Text = "ควบคุมยานอวกาศ: W,A,S,D,Space,Shift = เคลื่อนที่, ลูกศร = หมุน, F = ขาลงจอด, R = ยิงอาวุธ, T = ยิงขีปนาวุธ, B = Boost, V = โล่ป้องกัน"
					hint.Parent = player.PlayerGui

					delay(10, function()
						if hint then
							hint:Destroy()
						end
					end)
				end
			end
		end

		player.Chatted:Connect(onChatted)
	end

	-- ฟังก์ชั่นที่ทำงานเมื่อเกมเริ่ม
	local function onGameStart()
		-- สร้างตัวจัดการยานอวกาศ
		spaceshipManager = CreateSpaceshipManager()

		-- เพิ่มผู้เล่นที่เข้ามาในเกม
		for _, player in ipairs(Players:GetPlayers()) do
			onPlayerAdded(player)
		end

		-- เพิ่มผู้เล่นที่เข้ามาใหม่
		Players.PlayerAdded:Connect(onPlayerAdded)

		-- ลบยานอวกาศเมื่อผู้เล่นออกจากเกม
		Players.PlayerRemoving:Connect(function(player)
			local spaceship = spaceshipManager:GetPlayerSpaceship(player)
			if spaceship then
				spaceshipManager:DestroySpaceship(spaceship)
			end
		end)
	end

	-- เรียกใช้ฟังก์ชั่นเริ่มเกม
	onGameStart()

	return {
		CreateSpaceship = CreateSpaceship,
		CreateSpaceshipManager = CreateSpaceshipManager
	}