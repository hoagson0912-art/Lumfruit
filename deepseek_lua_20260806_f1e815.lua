-- Auto Fruit Sniper + Server Hop (DeltaX Mobile)
-- Bởi nhatanh Dev
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local TeleportService=game:GetService("TeleportService")
local VirtualUser=game:GetService("VirtualUser")
local LocalPlayer=Players.LocalPlayer or Players:WaitForChild("LocalPlayer")
if not LocalPlayer then return warn("No LocalPlayer") end
local Character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid=Character:WaitForChild("Humanoid")
local RootPart=Character:WaitForChild("HumanoidRootPart")
if not Humanoid or not RootPart then return warn("No Humanoid") end
print("✅ Auto Fruit Sniper started!")
local function findFruit()
    for _,obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Name:lower():find("fruit") then return obj end
        if obj:IsA("Model") and obj.Name:lower():find("fruit") then return obj end
    end
    return nil
end
local function flyTo(pos)
    if not pos then return end
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(4000,4000,4000)
    bv.Parent=RootPart
    while (RootPart.Position-pos).Magnitude>8 do
        local dir=(pos-RootPart.Position).unit
        bv.Velocity=dir*90+Vector3.new(0,8,0)
        wait(0.1)
    end
    bv:Destroy()
end
local function pickFruit()
    VirtualUser:ClickButton1(Vector2.new(0,0))
    wait(0.2)
    VirtualUser:ClickButton1(Vector2.new(0,0))
end
while true do
    wait(1.5)
    local fruit=findFruit()
    if fruit then
        local pos=fruit:IsA("Tool") and fruit.Handle and fruit.Handle.Position or fruit:IsA("Model") and fruit.Head and fruit.Head.Position or fruit.Position
        if pos then
            print("Found fruit: "..fruit.Name)
            flyTo(pos)
            wait(0.3)
            pickFruit()
            print("Picked fruit!")
        end
    else
        print("No fruit, hopping server...")
        TeleportService:Teleport(game.PlaceId)
        wait(5)
    end
end