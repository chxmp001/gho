function GetChild(parent,child)
	return parent:FindFirstChild(child)
end

repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("Suit").Status.Power.Value

if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("JARVIS") then
	local gui = game.Lighting.IronMan.JARVIS:Clone()
	gui.Parent = game.Players.LocalPlayer.PlayerGui
	gui.Mask.Visible = true
	gui.Eject.Visible = true
	gui.Overlay.ImageTransparency = 0
end

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')

local MyModel = nil
local MyPlayer = nil


local obj = script.Assets
local anims = obj.Animations
local effects = obj.Visual

local MyBillboard = obj.BillboardGui
local lockonImg = MyBillboard.lockon
local holdlockImg = MyBillboard.lockonHeld
local MyDistText = MyBillboard.Distance

local lock = false
local HaveLock = false

local target = nil
local TrackTime = 0

local lockOnSoundPlaying = false
local holdSoundPlaying = false

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local char = plr.Character
local hum = GetChild(char,"Humanoid")

suit = GetChild(char,"Suit")
main = suit.Chest2.Main
status = GetChild(suit,"Status")

local flying = false
local hovering = false
local boost = false
local canfly = true
local sprinting = false
local cansprint = false

local firing = false
local laser = false
local rocket = false
local light = false

local candamage = false
local canattack = true
local attacking = false
local click_d = 0
local mousedown = false

local cangrab = true
local grabbing = false

local rayparts = {}
local beam

local Speed = {CurrentSpeed = 8,MaxSpeed = 150}
local Speeds = {NormalSpeed = Speed.MaxSpeed,SpeedBoost = (Speed.MaxSpeed + 200)}
local SpeedBoost = {Debounce = false,Duration = 10,ReloadTime = 2,}
local Jumping = {JumpTick = 0,Jumps = 0,JumpTime = 0.75,JumpsRequired = 2}
local Controls = {
	Forward = {
		Number = 0,
		Numbers = {
			On = -1,
			Off = 0
		},
		Keys = {"W", 17}
	},
	Backward = {
		Number = 0,
		Numbers = {
			On = 1,
			Off = 0
		},
		Keys = {"S", 18}
	},
	Left = {
		Number = 0,
		Numbers = {
			On = -1,
			Off = 0
		},
		Keys = {"A", 20}
	},
	Right = {
		Number = 0,
		Numbers = {
			On = 1,
			Off = 0
		},
		Keys = {"D", 19}
	}
}
local parts = {
		RightHand = {
			Size = 0.4,
			Name = "Gauntlet1",
			Enabled = false
		},
		LeftHand = {
			Size = 0.4,
			Name = "Gauntlet2",
			Enabled = false
		},
		RightBoot = {
			Size = 0.6,
			Name = "Boot1",
			Enabled = true
		},
		LeftBoot = {
			Size = 0.6,
			Name = "Boot2",
			Enabled = true
		}
	}	

local fly = hum:LoadAnimation(anims.Fly)
local jump = hum:LoadAnimation(anims.Jump)
local land = hum:LoadAnimation(anims.Land)
local hover = hum:LoadAnimation(anims.Hover)
local punch = hum:LoadAnimation(anims.Punch)
local sprint = hum:LoadAnimation(anims.Sprint)
local grab = hum:LoadAnimation(anims.Grab)

function HoverMechanics()
	suit = GetChild(char,"Suit")
	status = suit.Status
	main = suit.Chest2.Main
	status.Flying.Value = true
	
	if main:FindFirstChild("Gyro") then
		main.Gyro:Destroy()
	end
	if main:FindFirstChild("WalkVelocity") then
		main.WalkVelocity:Destroy()
	end
	
	hum.Jump = true
	
	wait(0.1)
	
	local Gyro = Instance.new("BodyGyro")
	Gyro.Name = "FlightGyro"
	Gyro.P = (10 ^ 6)
	Gyro.maxTorque = Vector3.new(Gyro.P, Gyro.P, Gyro.P)
	Gyro.cframe = main.CFrame
	Gyro.Parent = main
	
	local pos = Instance.new("BodyPosition")
	pos.Name = "FlightVelocity"
	pos.Position = Vector3.new(char.Torso.Position.X,char.Torso.Position.Y+3,char.Torso.Position.Z)
	pos.Parent = main
	pos.MaxForce = Vector3.new(0,1e9,0)
	
	local Momentum = Vector3.new(0, 0, 0)
	local LastMomentum = Vector3.new(0, 0, 0)
	local LastTilt = 0
	local CurrentSpeed = Speed.MaxSpeed
	local Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
	
	while (hovering and (not flying) and canfly and status.Power.Value and status.Flying.Value) do
		sprinting = false	
		
		if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
			hum.WalkSpeed = 40
		end	
		
		hum.PlatformStand = false		
		
		status.Charge.Value = status.Charge.Value - 0.015
			
		local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
		local StringTilt = tostring(Tilt)
			
		if StringTilt == "-1.#IND" or StringTilt == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or StringTilt == tostring(0 / 0) then
			Tilt = 0
		end
			
		local AbsoluteTilt = math.abs(Tilt)
			
		if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
			if math.abs(LastTilt) > 0.0001 then
				Tilt = (LastTilt * 0.9)
			else
				Tilt = 0
			end
		else
			Tilt = ((LastTilt * 0.77) + (Tilt * 0.25))
		end
		LastTilt = Tilt
		Momentum = Vector3.new(0, 0, 0)
		Gyro.cframe = game:GetService("Workspace").CurrentCamera.CoordinateFrame
		wait()	
	end
	hum.WalkSpeed = 16
	hum.PlatformStand = false
	StopFlightMechanics()
end

function FlightMechanics()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	status.Flying.Value = true
	
	if main:FindFirstChild("Gyro") then
		main.Gyro:Destroy()
	end
	if main:FindFirstChild("WalkVelocity") then
		main.WalkVelocity:Destroy()
	end
	
	wait()
	
	local Gyro = Instance.new("BodyGyro")
	Gyro.Name = "FlightGyro"
	Gyro.P = (10 ^ 6)
	Gyro.maxTorque = Vector3.new(Gyro.P, Gyro.P, Gyro.P)
	Gyro.cframe = main.CFrame
	Gyro.Parent = main
		
	local Velocity = Instance.new("BodyVelocity")
	Velocity.Name = "FlightVelocity"
	Velocity.velocity = Vector3.new(0, 0, 0)
	Velocity.P = (10 ^ 4)
	Velocity.maxForce = Vector3.new(1, 1, 1) * (10 ^ 6)
	Velocity.Parent = main
	
	local Momentum = Vector3.new(0, 0, 0)
	local LastMomentum = Vector3.new(0, 0, 0)
	local LastTilt = 0
	local CurrentSpeed = Speed.MaxSpeed
	local Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
	
	while (flying and (not hovering) and canfly and status.Power.Value and status.Flying.Value) do
		sprinting = false		
		status.Charge.Value = status.Charge.Value - 0.015
		if CurrentSpeed ~= Speed.MaxSpeed then
			CurrentSpeed = Speed.MaxSpeed
			Inertia = (1 - (Speed.CurrentSpeed / CurrentSpeed))
		end
			
		local Direction = game:GetService("Workspace").CurrentCamera.CoordinateFrame:vectorToWorldSpace(Vector3.new(Controls.Left.Number + Controls.Right.Number, math.abs(Controls.Forward.Number) * 0.2, Controls.Forward.Number + Controls.Backward.Number))
		local Movement = Direction * Speed.CurrentSpeed
			
		Momentum = (Momentum * Inertia) + Movement

		local TotalMomentum = Momentum.magnitude
			
		if TotalMomentum > CurrentSpeed then
			TotalMomentum = CurrentSpeed
			for i,v in pairs(parts) do
				if suit:FindFirstChild(v.Name) and suit:FindFirstChild(v.Name).Repulsor:FindFirstChild("Thruster") and (v.Name == "Gauntlet1" or v.Name == "Gauntlet2") then
					suit:FindFirstChild(v.Name).Repulsor.Thruster.Enabled = true
				end
			end
		end
			
		local Tilt = ((Momentum * Vector3.new(1, 0, 1)).unit:Cross(((LastMomentum * Vector3.new(1, 0, 1)).unit))).y
		local StringTilt = tostring(Tilt)
			
		if StringTilt == "-1.#IND" or StringTilt == "1.#IND" or Tilt == math.huge or Tilt == -math.huge or StringTilt == tostring(0 / 0) then
			Tilt = 0
		end
			
		local AbsoluteTilt = math.abs(Tilt)
			
		if AbsoluteTilt > 0.06 or AbsoluteTilt < 0.0001 then
			if math.abs(LastTilt) > 0.0001 then
				Tilt = (LastTilt * 0.9)
			else
				Tilt = 0
			end
		else
			Tilt = ((LastTilt * 0.77) + (Tilt * 0.25))
		end
		LastTilt = Tilt
		if TotalMomentum < 0.5 then
			Momentum = Vector3.new(0, 0, 0)
			TotalMomentum = 0
			Gyro.cframe = game:GetService("Workspace").CurrentCamera.CoordinateFrame
		else
			Gyro.cframe = CFrame.new(Vector3.new(0, 0, 0), Momentum) * CFrame.Angles(0, 0, (Tilt * -20)) * CFrame.Angles((math.pi * -0.5 * (TotalMomentum / CurrentSpeed)), 0, 0)
		end
		Velocity.velocity = Momentum
		LastMomentum = Momentum
		wait()	
	end
	StopFlightMechanics()
end

function StopFlightMechanics()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	flying = false
	hovering = false
	status.Flying.Value = false
	
	for i,v in pairs(main:GetChildren()) do
		if v and v.Name == "FlightGyro" or v.Name == "FlightVelocity" then
			v:Destroy()
		end
	end
	
	for i,v in pairs(parts) do
		if suit:FindFirstChild(v.Name).Repulsor:FindFirstChild("Thruster") then
			suit:FindFirstChild(v.Name).Repulsor.Thruster:Destroy()
		end
	end
	
	fly:Stop()
	hover:Stop()
	main.FlyBoost:Stop()
	
	main.Fly:Stop()
	
	hum.WalkSpeed = 16
	
	if status.Sentry.Value and not hovering then
		if not main:FindFirstChild("Gyro") then
			local g = Instance.new("BodyGyro")
			g.Name = "Gyro"
			g.Parent = main
		end	
		if not main:FindFirstChild("WalkVelocity") then
			local Velocity = Instance.new("BodyVelocity")
			Velocity.Name = "WalkVelocity"
			Velocity.velocity = Vector3.new(0,0,0)
			Velocity.P = (10 ^ 4)
			Velocity.maxForce = Vector3.new(1,0,1) * (10^6)
			Velocity.Parent = main
		end
	end
end

function Fly()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	if canfly then
		sprinting = false
		local function AddThruster(part,size,bool)
			local fire = effects.Thruster:Clone()
			fire.Size = NumberSequence.new(size)
			fire.Enabled = bool
			fire.Parent = part.Repulsor
		end
		flying = true
		if status.InSuit.Value then
			jump:Play()
			fly:Play()
		end
		main.Fly:Play()
		coroutine.resume(coroutine.create(FlightMechanics))
		for i,v in pairs(parts) do
			if suit:FindFirstChild(v.Name) then
				AddThruster(suit:FindFirstChild(v.Name),v.Size,v.Enabled)
			end
		end
	end
end

function StopFlight()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	hovering = false
	fly:Stop()
	hover:Stop()
	main.FlyBoost:Stop()
	main.Fly:Stop()
	if status.InSuit.Value then
		hum.WalkSpeed = 16
	end
	for i,v in pairs(parts) do
		if suit:FindFirstChild(v.Name).Repulsor:FindFirstChild("Thruster") then
			suit:FindFirstChild(v.Name).Repulsor.Thruster:Destroy()
		end
	end
end

function Hover()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	if canfly then
		sprinting = false
		StopFlightMechanics()
		local function AddThruster(part,size,bool)
			local fire = effects.Thruster:Clone()
			fire.Size = NumberSequence.new(size)
			fire.Enabled = bool
			fire.Parent = part.Repulsor
		end
		hovering = true
		if status.InSuit.Value then
			hover:Play()
		end
		main.Fly:Play()
		hum.JumpPower = 60
		hum.Jump = true
		coroutine.resume(coroutine.create(HoverMechanics))
		for i,v in pairs(parts) do
			if suit:FindFirstChild(v.Name) then
				AddThruster(suit:FindFirstChild(v.Name),v.Size,v.Enabled)
			end
		end
	end
end

function TrackLock(mouse)
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local myHead = char:FindFirstChild("Head")
	HaveLock = false
	target = nil
	while lock and mousedown and status.Power.Value do
		local mousePos = mouse.Hit
		local minOffset = nil
		local foundPlayer = false
		for _,i in pairs(game.Players:GetPlayers()) do			
			if i.Character and i.Character:FindFirstChild('Torso') and i~= plr then

				local torsoPos = i.Character.Torso.CFrame
				local dist = (main.CFrame.p-torsoPos.p).magnitude
				local mouseDirection = (mouse.hit.p-main.CFrame.p).unit
				local offset = (((mouseDirection*dist)+main.CFrame.p)-
					 torsoPos.p).magnitude
				if offset<9 and (not minOffset or offset<minOffset) then
					foundPlayer = true
					MyDistText.Text = tostring(math.floor(dist*100)/100)
					if target~=i then	
						if not target and i and not lockOnSoundPlaying 
								and not holdSoundPlaying then
							main.Lock:Play()
							lockOnSoundPlaying = true
							lockonImg.Visible = true
							MyDistText.Visible = true
							TrackTime = tick()
						end			
						target = i
						MyBillboard.Parent = plr.PlayerGui
						MyBillboard.Adornee =  i.Character.Torso
						lockonImg.Visible = true
					end
				end
			end
		end
		if (tick()-TrackTime)>1.1 and target and not holdSoundPlaying then
			main.HoldLock:Play()
			holdSoundPlaying=true
			lockonImg.Visible = false
			holdlockImg.Visible = true
		end
		if not foundPlayer and target then
			target=nil
			lockOnSoundPlaying=false
			main.Lock:Stop()
			if holdSoundPlaying then
				main.HoldLock:Stop()
				holdSoundPlaying = false
			end
			lockonImg.Visible = false
			holdlockImg.Visible = false
			MyDistText.Visible = false
			MyBillboard.Parent = nil
			MyBillboard.Adornee = nil
		end		
		wait(1/30)
	end
	target=nil
	lockOnSoundPlaying=false
	main.Lock:Stop()
	if holdSoundPlaying then
		main.Hold.Lock:Stop()
		holdSoundPlaying = false
	end
	lockonImg.Visible = false
	holdlockImg.Visible = false
	MyDistText.Visible = false
	MyBillboard.Parent = nil
	MyBillboard.Adornee = nil
end

function CastRepulsor(startPos,endPos,segLength,parts,type)
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local part, nend = game.Workspace:FindPartOnRay( Ray.new(startPos,(endPos-startPos).unit*999.999),char)
	if nend then endPos = nend end
	local damage = {Arm=50,Chest=120}
	if part and part.Parent and not part.Parent:IsA("Hat") then
		if (not part.Anchored) and (not part:IsDescendantOf(char)) then
			local PushBack = CFrame.new(main.CFrame.p,part.Position).lookVector * 60
			PushBack = Vector3.new(PushBack.X,20,PushBack.Z)
			part.Velocity = PushBack
		elseif (part.Anchored) and (not part:IsDescendantOf(char)) then
			if math.max(part.Size.X,part.Size.Y,part.Size.Z) <= 21 then
				part.Anchored = false
				part.CanCollide = true
				part:BreakJoints()
				local PushBack = CFrame.new(main.CFrame.p,part.Position).lookVector * 60
				PushBack = Vector3.new(PushBack.X,20,PushBack.Z)
				part.Velocity = PushBack
			end
		end
		if part.Parent:FindFirstChild('Humanoid') and part.Parent ~= char then
			coroutine.resume(coroutine.create(function()
				local humanoid = part.Parent:FindFirstChild('Humanoid')
				humanoid.PlatformStand = true
				humanoid:TakeDamage(damage[type])
				wait(0.5)
				humanoid.PlatformStand = false
				humanoid.Sit = true
			end))
			for i,v in pairs(parts) do
				v:Destroy()
			end
		elseif part.Parent:IsA("Model") then
			local limb = part.Parent
			if limb.Parent:FindFirstChild("Status") then
				if limb.Parent.Status.InSuit.Value then
					coroutine.resume(coroutine.create(function()
						limb.Parent.Status.Flying.Value = false
						local humanoid = limb.Parent.Parent:FindFirstChild('Humanoid')
						humanoid.PlatformStand = true
						humanoid:TakeDamage(damage[type])
						wait(0.5)
						humanoid.PlatformStand = false
						humanoid.Sit = true
					end))
				end
			end
		end
	end		
	
	local numSegments = math.floor(math.min((startPos-endPos).magnitude/segLength,50))
	local initNumParts = #parts
	for i=numSegments,initNumParts,1 do
		if parts[i] then
			parts[i]:Destroy()
			parts[i]=nil
		end
	end
	for i = 1,numSegments,1 do
		if not parts[i] then
			parts[i] = Instance.new('Part')
			parts[i].Parent = suit
			parts[i].Anchored = true
			parts[i].Size = Vector3.new(0.2,0.2,segLength)
			parts[i].CanCollide = false
			parts[i].Transparency = 1
			local fire = effects[type]:Clone()
			fire.Parent = parts[i]
			local light = Instance.new("PointLight")
			light.Parent = parts[i]
			light.Brightness = 50
			light.Range = 7
			light.Color = Color3.new(255/255,185/255,71/255)
		end
		parts[i].CFrame = CFrame.new(((i-.4)*(endPos-startPos).unit*segLength)+startPos,endPos)
	end
	return parts
end

function CastLaser(startPos,endPos)
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local part, nend = game.Workspace:FindPartOnRay( Ray.new(startPos,(endPos-startPos).unit*999.999))
	if nend then endPos = nend end
	
	if part and part.Parent and not part.Parent:IsA("Hat") then
		if part.Parent:FindFirstChild('Humanoid') and part.Parent ~= char then
			local humanoid = part.Parent:FindFirstChild('Humanoid')
			local torso = part.Parent:FindFirstChild('Torso')
			humanoid:TakeDamage(2)
		elseif (not part.Parent:FindFirstChild("Humanoid")) and (not part:IsDescendantOf(char)) then
			if not part.Anchored then
				part:BreakJoints()
				part.CanCollide = true
			elseif part.Anchored and
				math.max(part.Size.X,part.Size.Y,part.Size.Z) <= 21 then
				part.Anchored = false
				part.CanCollide = true
				part:BreakJoints()
			end
		elseif part.Parent then
			if part.Parent:IsA("Model") and part.Parent.Parent.Name == "Suit" and part.Parent.Parent ~= suit then
				part.Anchored = false
				part.CanCollide = true
				part:BreakJoints()
				part.Transparency = 0
				if part.Material == Enum.Material.Neon then
					part.BrickColor = BrickColor.new("Really black")
				end
				local theirsuit = part.Parent.Parent
				if theirsuit.Parent:FindFirstChild(part.Parent.Target.Value) then
					theirsuit.Parent:FindFirstChild(part.Parent.Target.Value).Transparency = 0
				end
			end
		end
	end	
	
	local segLength = (startPos-endPos).magnitude
	
	if beam then
		beam:Destroy()
	end
	
	local surfaces = {"Top","Bottom","Right","Left","Front","Back"}
	beam = Instance.new('Part')
	beam.Parent = suit
	beam.Anchored = true
	beam.Size = Vector3.new(0,0,segLength)
	beam.CanCollide = false
	beam.Transparency = 0.4
	beam.Material = Enum.Material.Neon
	beam.BrickColor = BrickColor.new("Really red")
	local mesh = Instance.new("BlockMesh")
	mesh.Scale = Vector3.new(0.5,0.5,1)
	mesh.Parent = beam
	for i = 1,#surfaces do
		local light = Instance.new("SurfaceLight")
		light.Parent = beam
		light.Brightness = 50
		light.Range = 7
		light.Color = Color3.new(255,0,0)
		light.Face = surfaces[i]
	end

	beam.CFrame = CFrame.new(((segLength/2)*(endPos-startPos).unit)+startPos,endPos)
end

local rightweld = game.Players.LocalPlayer.Character.Torso['Right Shoulder']
local oldright = rightweld.C0
local leftweld = game.Players.LocalPlayer.Character.Torso['Left Shoulder']
local oldleft = leftweld.C0

mouse.KeyDown:connect(function(key)
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local ByteKey = string.byte(key)
	if key == " " then
		if flying then
			flying = false
			StopFlight()
		elseif canfly and (not flying) and (status.Power.Value) and (status.InSuit.Value or status.Sentry.Value) then
			if (tick() - Jumping.JumpTick) <= Jumping.JumpTime or Jumping.JumpTick == 0 then
				Jumping.JumpTick = tick()
				Jumping.Jumps = Jumping.Jumps + 1
				if Jumping.Jumps >= Jumping.JumpsRequired then
					Jumping.JumpTick = 0
					Jumping.Jumps = 0
					Fly()
				end
			else
				Jumping.JumpTick = tick()
				Jumping.Jumps = 1
			end
		end
	elseif key == "f" and (not SpeedBoost.Debounce) and (not boost) and flying and (not hovering) then
		boost = true
		SpeedBoost.Debounce = true
		main.FlyBoost:Play()
		for i,v in pairs(parts) do
			if suit:FindFirstChild(v.Name) and suit:FindFirstChild(v.Name).Repulsor:FindFirstChild("Thruster") then
				suit:FindFirstChild(v.Name).Repulsor.Thruster.Enabled = true
			end
		end
		Speed.MaxSpeed = Speeds.SpeedBoost
		wait(SpeedBoost.Duration)
		main.FlyBoost:Stop()
		Speed.MaxSpeed = Speeds.NormalSpeed
		for i,v in pairs(parts) do
			if suit:FindFirstChild(v.Name) and suit:FindFirstChild(v.Name).Repulsor:FindFirstChild("Thruster") then
				suit:FindFirstChild(v.Name).Repulsor.Thruster.Enabled = v.Enabled
			end
		end
		wait(SpeedBoost.ReloadTime)
		boost = false
		SpeedBoost.Debounce = false
	elseif key == "h" and canfly and status.InSuit.Value then
		if hovering == false or flying then
			hovering = true
			StopFlight()
			StopFlightMechanics()
			Hover()
		elseif hovering then
			hum.WalkSpeed = 16
			StopFlight()
			StopFlightMechanics()
			hovering = false
		end
	--weapons
	--right repulsor
	elseif key == "e" then
		if not firing and status.Power.Value and not laser and not light and (not grabbing) then
			sprinting = false
			firing = true
			suit.Gauntlet1.Main.Equip:Play()
			local targ = nil
			if target == nil then
				targ = mouse.Hit.p
			end		
			local rayparts = {}
			if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
				rightweld.CurrentAngle = 0
				rightweld.DesiredAngle = 0
				rightweld.MaxVelocity = 0
				local tframe = game.Players.LocalPlayer.Character.Torso.CFrame
				local taim = mouse.Hit.p - (tframe.p)
				rightweld.C0 = (CFrame.new(Vector3.new(),tframe:vectorToObjectSpace(taim)) * CFrame.Angles(math.pi/2,math.pi/2,0)) + Vector3.new(1,0.5,0)
			end
			wait(0.5)
			suit.Gauntlet1.Main.Fire:Play()
			status.Charge.Value = status.Charge.Value - 0.5
			wait(0.2)
			rightweld.C0 = oldright
			local a = suit.Gauntlet1.Repulsor.CFrame.p+suit.Gauntlet1.Repulsor.CFrame:vectorToWorldSpace(Vector3.new(0,0,0))
			if target ~= nil then
				targ = target.Character.Torso.CFrame.p
			elseif target == nil then
				targ = mouse.Hit.p
			end		
			rayparts = CastRepulsor(a,targ,10,rayparts,"Arm")
			wait(0.1)
			firing = false
			for i,v in pairs(rayparts) do
				v:Destroy()
				wait()
			end
		end
	--left repulsor
	elseif key == "q" then
		if not firing and status.Power.Value and not laser and not light and (not grabbing) then
			sprinting = false
			firing = true
			suit.Gauntlet2.Main.Equip:Play()
			local targ = nil
			if target == nil then
				targ = mouse.Hit.p
			end		
			local rayparts = {}
			if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
				leftweld.CurrentAngle = 0
				leftweld.DesiredAngle = 0
				leftweld.MaxVelocity = 0
				local tframe = game.Players.LocalPlayer.Character.Torso.CFrame
				local taim = mouse.Hit.p - (tframe.p)
				leftweld.C0 = (CFrame.new(Vector3.new(),tframe:vectorToObjectSpace(taim)) * CFrame.Angles(math.pi/2,-math.pi/2,0)) + Vector3.new(-1,0.5,0)
			end
			wait(0.5)
			suit.Gauntlet2.Main.Fire:Play()
			status.Charge.Value = status.Charge.Value - 0.5
			wait(0.2)
			leftweld.C0 = oldleft
			local a = suit.Gauntlet2.Repulsor.CFrame.p+suit.Gauntlet2.Repulsor.CFrame:vectorToWorldSpace(Vector3.new(0,0,0))
			if target ~= nil then
				targ = target.Character.Torso.CFrame.p
			elseif target == nil then
				targ = mouse.Hit.p
			end		
			rayparts = CastRepulsor(a,targ,10,rayparts,"Arm")
			wait(0.1)
			firing = false
			for i,v in pairs(rayparts) do
				v:Destroy()
				wait()
			end
		end
	--chest repulsor
	elseif key == "r" then
		if status.Power.Value and (not firing) and (not grabbing) and (status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value)) then
			sprinting = false
			local anim = hum:LoadAnimation(anims.Unibeam)
			firing = true
			main.Equip:Play()
			local targ = nil
			if target == nil then
				targ = mouse.Hit.p
			end		
			local rayparts = {}
			if status.InSuit.Value then
				anim:Play()
			end
			wait(0.5)
			main.Fire:Play()
			status.Charge.Value = status.Charge.Value - 1.5
			wait(0.2)
			anim:Stop()
			local a = suit.Chest1.Light.CFrame.p+suit.Chest1.Light.CFrame:vectorToWorldSpace(Vector3.new(0,0,0))
			if target ~= nil then
				targ = target.Character.Torso.CFrame.p
			elseif target == nil then
				targ = mouse.Hit.p
			end		
			rayparts = CastRepulsor(a,targ,10,rayparts,"Chest")
			wait(0.1)
			for i,v in pairs(rayparts) do
				v:Destroy()
				wait()
			end
			wait(3)
			firing = false
		end
	--laser
	elseif key == "t" then
		if (not laser) and status.Power.Value and (not firing) and (not light) and not grabbing then
			sprinting = false
			laser = true
			Laser()
		end
	elseif key == "l" then
		if (not light) and status.Power.Value and (not firing) and (not laser) and not grabbing then
			sprinting = false
			light = true
			Light()
		end
	elseif key == "0" then
		if cansprint and (not sprinting) and (not hovering) and (not flying) and ((status.Power.Value and status.InSuit.Value) or ((not status.InSuit.Value) and (not status.Sentry.Value))) then
			sprinting = true
			laser = false
			light = false
			suit.Gauntlet1.Main.Laser:Stop()
			if beam then
				beam:Destroy()
			end
			Sprint()
		end
	elseif key == "g" then
		if ((status.Power.Value and status.InSuit.Value) or ((not status.InSuit.Value) and (status.Sentry.Value) and status.Power.Value)) then
			if not grabbing then
				cangrab = true
				suit.Chest1.Union.Touched:connect(function(part)
					Grab(part)
				end)
				suit.Helmet.Union.Touched:connect(function(part)
					Grab(part)
				end)
				suit.Shoulder1.Union.Touched:connect(function(part)
					Grab(part)
				end)
				suit.Shoulder2.Union.Touched:connect(function(part)
					Grab(part)
				end)
			elseif grabbing then
				grabbing = false
				cangrab = false
				grab:Stop()
				if main:FindFirstChild("Grab") then
					main.Grab:Destroy()
				end
			end
		end
	end
	for i, v in pairs(Controls) do
		for ii, vv in pairs(v.Keys) do
			v.Number = ((((string.lower(type(vv)) == string.lower("String") and key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.On) or v.Number)
		end
	end
end)

mouse.KeyUp:connect(function(key)
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local ByteKey = string.byte(key)
	for i, v in pairs(Controls) do
		for ii, vv in pairs(v.Keys) do
			v.Number = ((((string.lower(type(vv)) == string.lower("String") and key == string.lower(vv)) or (string.lower(type(vv)) == string.lower("Number") and ByteKey == vv)) and v.Numbers.Off) or v.Number)
		end
	end
	if key == "t" then
		laser = false
		suit.Gauntlet1.Main.Laser:Stop()
		if beam then
			beam:Destroy()
		end
	elseif key == "l" then
		light = false
	elseif key == "0" then
		sprinting = false
	end
end)

mouse.Button1Down:connect(function()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	click_d = tick()
	wait(0.42)
	if not attacking and not lock then
		lock = true
		mousedown = true
		TrackLock(mouse)
	end
end)

mouse.Button1Up:connect(function()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	lock = false
	mousedown = false
	main.Lock:Stop()
	main.HoldLock:Stop()
	holdSoundPlaying = false
	lockonImg.Visible = false
	holdlockImg.Visible = false
	MyDistText.Visible = false
	MyBillboard.Parent = nil
	MyBillboard.Adornee = nil
	if (tick()-click_d) <= 0.4 then
		if (not sprinting) and (not grabbing) and status.Power.Value and (not attacking) and canattack and (not light) and (not laser) and (status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value)) then
			attacking = true
			canattack = false
			candamage = true
			punch:Play(0.1,1,2.2)
			suit.Gauntlet1.Light.Swing.Pitch = math.random(100,120)/100
			suit.Gauntlet1.Light.Swing:Play()
			suit.Gauntlet1.Light.Touched:connect(function(part)
				if part.Parent and candamage and (not part:IsDescendantOf(char)) then
					if part.Parent:FindFirstChild("Humanoid") then
						candamage = false
						local humanoid = part.Parent:FindFirstChild("Humanoid")
						local torso = part.Parent:FindFirstChild("Torso")
						suit.Gauntlet1.Light.Smack.Pitch = math.random(90,110)/100
						suit.Gauntlet1.Light.Smack:Play()
						coroutine.resume(coroutine.create(function()
							local PushBack = CFrame.new(char.Torso.CFrame.p,part.Position).lookVector * 60
							PushBack = Vector3.new(PushBack.X,60,PushBack.Z)
							torso.Velocity = PushBack
							humanoid.PlatformStand = true
							humanoid:TakeDamage(50)
							wait(0.5)
							humanoid.PlatformStand = false
							humanoid.Sit = true
						end))
					elseif part.Parent:IsA("Model") then
						if part.Parent.Parent.Name == "Suit" then
							local num = math.random(1,25)
							if num == 1 then
								part:BreakJoints()
								part.CanCollide = true
							end
							part.Parent.Parent.Status.Flying.Value = false
						end
					end
				end
			end)
			wait(1)
			canattack = true
			candamage = false
			attacking = false
		end
	end
end)

function Laser()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
		rightweld.CurrentAngle = 0
		rightweld.DesiredAngle = 0
		rightweld.MaxVelocity = 0
	end
	suit.Gauntlet1.Main.Laser:Play()
	while laser and (not firing) and (not grabbing) and (not light) and (status.Power.Value) do
		sprinting = false
		if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
			rightweld.CurrentAngle = 0
			rightweld.DesiredAngle = 0
			rightweld.MaxVelocity = 0
			local tframe = game.Players.LocalPlayer.Character.Torso.CFrame
			tframe = tframe + tframe:vectorToWorldSpace(Vector3.new(1, 0.5, 0))
			local taim = mouse.Hit.p - (tframe.p)
			rightweld.C0 = (CFrame.new(Vector3.new(),tframe:vectorToObjectSpace(taim)) * CFrame.Angles(math.pi/2,math.pi/2,0)) + Vector3.new(1,0.5,0)
		end
		local a = suit.Gauntlet1.Repulsor.CFrame.p+suit.Gauntlet1.Repulsor.CFrame:vectorToWorldSpace(Vector3.new(0,0,0))
		local targ = nil
		if target ~= nil then
			targ = target.Character.Torso.CFrame.p
		elseif target == nil then
			targ = mouse.Hit.p
		end	
		CastLaser(a,targ)
		status.Charge.Value = status.Charge.Value - 0.03
		wait()
	end
	rightweld.C0 = oldright
	laser = false
end

function Light()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	local torch = suit.Gauntlet1.Repulsor.Torch
	if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
		rightweld.CurrentAngle = 0
		rightweld.DesiredAngle = 0
		rightweld.MaxVelocity = 0
	end
	torch.Enabled = true
	while light and (not firing) and (not grabbing) and (not laser) and (status.Power.Value) do
		if status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value) then
			rightweld.CurrentAngle = 0
			rightweld.DesiredAngle = 0
			rightweld.MaxVelocity = 0
			sprinting = false
			local tframe = game.Players.LocalPlayer.Character.Torso.CFrame
			tframe = tframe + tframe:vectorToWorldSpace(Vector3.new(1, 0.5, 0))
			local taim = mouse.Hit.p - (tframe.p)
			rightweld.C0 = (CFrame.new(Vector3.new(),tframe:vectorToObjectSpace(taim)) * CFrame.Angles(math.pi/2,math.pi/2,0)) + Vector3.new(1,0.5,0)
		end
		wait()
	end
	rightweld.C0 = oldright
	torch.Enabled = false
	light = false
end

function Sprint()
	suit = GetChild(char,"Suit")
	main = suit.Chest2.Main
	status = GetChild(suit,"Status")
	sprint:Play()
	while cansprint and sprinting and (not hovering) and (not flying) and (not laser) and (not light) and ((status.Power.Value and status.InSuit.Value) or ((not status.InSuit.Value) and (not status.Sentry.Value))) do
		hum.WalkSpeed = 32
		hum.JumpPower = 0
		wait()
	end
	sprint:Stop()
	hum.WalkSpeed = 16
	hum.JumpPower = 60
end

function Grab(part)
	if (not grabbing) and cangrab and part.Parent:FindFirstChild("Torso") and part.Parent:FindFirstChild("Humanoid") and part.Parent:FindFirstChild("Humanoid").Health > 0 then
		local main = char:FindFirstChild("Suit").Chest2.Main
		laser = false
		light = false
		local ch = part.Parent
		local hm = part.Parent:WaitForChild("Humanoid")	
		local spd = hm.WalkSpeed
		local pw = hm.JumpPower				
		local w = Instance.new("Weld")
		w.Name = "Grab"
		w.Parent = main
		w.Part0 = main
		w.Part1 = part.Parent.Torso
		w.C0 = CFrame.new(0,0,-1)
		if status.InSuit.Value then
			grab:Play()
		end
		grabbing = true
		coroutine.resume(coroutine.create(function()
			while cangrab and grabbing and (status.InSuit.Value or (status.Calling.Value and (not status.Whole.Value) and status.Ejected.Value)) do
				hm.PlatformStand = true
				hm.JumpPower = 0
				hm.WalkSpeed = 0
				wait()
			end
			hm.JumpPower = pw
			hm.WalkSpeed = spd
			hm.PlatformStand = false
		end))
	end
end

hum.Running:connect(function(speed)
	if speed > 3 then
		cansprint = true
	elseif speed < 15 then
		cansprint = false
		sprinting = false
	end
end)