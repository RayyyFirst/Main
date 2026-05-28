-- // @FunctionManager.luau
local Game: DataModel = game;
if not (Game:IsLoaded()) then Game.Loaded:Wait() end

local global = (shared or (getgenv and getgenv()) or _G) :: any;
(global.FunctionManager_Engine or {Unload = function() end}):Unload();

-- // @Performance.vars
local cloneref: (Instance) -> Instance = (cloneref or clonereference or function(instance: Instance)
    return instance
end)

local type, typeof, pcall, tick, warn, print, next,  loadstring, setmetatable =
    type, typeof, pcall, tick, warn, print, next, loadstring, setmetatable

local math_floor, math_random, math_clamp, math_max, math_min, math_sqrt, math_huge =
    math.floor, math.random, math.clamp, math.max, math.min, math.sqrt, math.huge

local string_format, string_sub, string_match, string_gsub, string_gmatch, string_lower =
    string.format, string.sub, string.match, string.gsub, string.gmatch, string.lower

local table_insert, table_clear, table_sort, table_remove, table_create, table_concat =
    table.insert, table.clear, table.sort, table.remove, table.create, table.concat

local task_wait, task_spawn, task_cancel, task_delay = task.wait, task.spawn, task.cancel, task.delay

local os_clock, os_time, os_date = os.clock, os.time, os.date
local pairs, ipairs = pairs, ipairs

local task_running, task_resume, task_yield, task_create = 
    coroutine.running, coroutine.resume, coroutine.yield, coroutine.create

local Vector3_new, Vector2_new, Vector3_zero, Color3_fromRGB, Color3_fromHSV, CFrame_lookAt, CFrame_new, Instance_new =
    Vector3.new, Vector2.new, Vector3.zero, Color3.fromRGB, Color3.fromHSV, CFrame.lookAt, CFrame.new, Instance.new

local write_file, read_file, is_file, make_folder, is_folder, del_folder, del_file, list_files =
    writefile, readfile, isfile, makefolder, isfolder, delfolder, delfile, listfiles

local globalEnv = (getgenv and getgenv() or _G) :: any;

--[[
local clonefunction: (Function) -> Function = (clonefunction or copyfunction or function(func: Function)
    return func
end)

if typeof(clonefunction) == "function" then
    local isfolder_dummy, isfile_dummy, listfiles_dummy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_dummy(tostring(math_random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then

        globalEnv.isfolder = function(Folder)
            local Success, Data = pcall(isfolder_dummy, Folder)
            return Success and Data or false
        end

        globalEnv.isfile = function(File)
            local Success, Data = pcall(isfile_dummy, File)
            return Success and Data or false
        end

        globalEnv.listfiles = function(Folder)
            local Success, Data = pcall(listfiles_dummy, Folder)
            return Success and Data or {}
        end

		is_folder, is_file, list_files = globalEnv.isfolder, globalEnv.isfile, globalEnv.listfiles
    end
end
--]]

-- // @API.module
local API = {} 
API.__index = API

-- // @Variables
local Workspace, Cache, Class = workspace, Game.GetService, API;
local Project = {Name = "Function Manager", Build = "@1.84", Author = "FlamesW",Language = "luau", File = "Module.luau"}
local Players: Players? = cloneref(Cache(Game, "Players"));
local LocalPlayer: Player? = nil
local Character: Model?, Roots: BasePart?, Humanoid: Humanoid? = nil, nil, nil;
local RunService: RunService? = Cache(Game, "RunService");
local TweenService: TweenService? = cloneref(Cache(Game, "TweenService"));
local MarketplaceService: MarketplaceService? = Cache(Game, "MarketplaceService");
local HttpService: HttpService? = cloneref(Cache(Game, "HttpService"));
local TeleportService: TeleportService? = Cache(Game, "TeleportService");
local RbxAnalyticsService: RbxAnalyticsService? = cloneref(Cache(Game, "RbxAnalyticsService"));
local VirtualInputManager: VirtualInputManager? = Instance_new("VirtualInputManager");
local QueueOnTeleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport);
local GetConnections: GetConnections? = getconnections or get_signal_cons;
local LocalizationService: LocalizationService? = cloneref(Cache(Game, "LocalizationService"));
local UserInputService: UserInputService? = cloneref(Cache(Game, "UserInputService"));
local SoundService: SoundService? = cloneref(Cache(Game, "SoundService"));
local StarterGuiService: StarterGuiService? = cloneref(Cache(Game, "StarterGui"));
local CoreGui: CoreGui? = cloneref(Cache(Game, "CoreGui"));
local Performance: Performance? = Cache(Game, "Stats");
local LightingService: LightingService? = Cache(Game, "Lighting");
local CurrentCamera: Camera? = Workspace.CurrentCamera;
repeat task_wait() LocalPlayer = Players.LocalPlayer until LocalPlayer ~= nil
global.FunctionManager_Engine = API

-- // @Caches.vars
local LoadTime = os_clock()
local RenderStepped = RunService.RenderStepped;
-- local PreSimulation = RunService.PreSimulation;
local Heartbeat = RunService.Heartbeat;
local Stepped = RunService.Stepped;
local InputBegan = UserInputService.InputBegan;
local BindToRenderStep = RunService.BindToRenderStep;
local UnbindFromRenderStep = RunService.UnbindFromRenderStep;

local IsKeyDown = UserInputService.IsKeyDown;
local GetMouseLocation = UserInputService.GetMouseLocation;
local GetPlatform = UserInputService.GetPlatform;

local WorkspaceRaycast = Workspace.Raycast;
local RaycastParamsNew = RaycastParams.new;

local PlaceId, JobId, GameId  = Game.PlaceId, Game.JobId, Game.GameId;
local Get_Asset = getcustomasset or getsynasset;

local AssetTypes = {
    [1] = "Image", [2] = "TShirt", [3] = "Audio", [4] = "Mesh", [5] = "Lua",
    [8] = "Hat", [9] = "Place", [10] = "Model", [11] = "Shirt", [12] = "Pants",
    [13] = "Decal", [17] = "Head", [18] = "Face", [19] = "Gear", [21] = "Badge",
    [24] = "Animation", [27] = "Torso", [28] = "RightArm", [29] = "LeftArm",
    [30] = "LeftLeg", [31] = "RightLeg", [32] = "Package", [34] = "GamePass",
    [38] = "Plugin", [41] = "MeshPart", [42] = "Video", [43] = "Tool"
}

-- // @Signal.luau
function API:_Connect(Name: string, Connection: RBXScriptConnection)
    self._Signal = self._Signal or {} self._Signal[Name] = self._Signal[Name] or {} local Service = self._Signal[Name] Service[#Service + 1] = Connection return Connection;
end

function API:_Disconnect(Name: string): ()
    local Connections = self._Signal and self._Signal[Name] if not Connections then return end for i = 1, #Connections do local Service = Connections[i] if Service then pcall(function() Service:Disconnect() end) end end self._Signal[Name] = nil;
end

function globalEnv._IsLoadedFM() --> typeof(_IsLoadedFM) == "function" and _IsLoadedFM();
    return global.FunctionManager_Engine ~= nil
end

-- // @Engine.luau
local function Build_Engine(Running: Model)
    if not Running then return end
    Character, Roots, Humanoid, CurrentCamera = Running, Running:WaitForChild("HumanoidRootPart", 5), Running:WaitForChild("Humanoid", 5);
    CurrentCamera = Workspace.CurrentCamera;
    
	Class.Character, Class.Roots, Class.Humanoid, Class.CurrentCamera = Character, Roots, Humanoid, CurrentCamera;
end 

Build_Engine(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()) 
API:_Connect("@Engine.luau", LocalPlayer.CharacterAdded:Connect(Build_Engine))

local function Internal(packet)
    if packet.PacketId == 0x1B then
        local data = packet.AsBuffer
        buffer.writeu32(data, 1, 0xFFFFFFFF)
        packet:SetData(data)
    end
end

-- // @Functions.module
function API:CreateInstance(ClassName: string, Properties: { [string]: any }?)
    local InstanceObj = Instance_new(ClassName)

    if Properties then
        local k, v = next(Properties)
        while k do
            InstanceObj[k] = v
            k, v = next(Properties, k)
        end
    end
    return InstanceObj
end

function API:CreateDrawing(DrawType: string, Properties: { [string]: any }?)
    local Success, DrawingObj = pcall(function()
        return Drawing.new(DrawType)
    end)

    if not Success or not DrawingObj then
        return nil
    end

    if Properties then
        local k, v = next(Properties)
        while k do
            pcall(function()
                DrawingObj[k] = v
            end)
            k, v = next(Properties, k)
        end
    end
    
    self.DrawingsList = self.DrawingsList or {}
    table_insert(self.DrawingsList, DrawingObj)
    
    return DrawingObj
end

function API:UpdateDrawing(DrawingObj, Properties)
    if not DrawingObj then return nil end
    
    if Properties then
        local k, v = next(Properties)
        while k do
            pcall(function()
                DrawingObj[k] = v
            end)
            k, v = next(Properties, k)
        end
    end
    
    return DrawingObj
end

function API:ShowDrawing(DrawingObj)
    if not DrawingObj then return end
    pcall(function()
        DrawingObj.Visible = true
    end)
end

function API:HideDrawing(DrawingObj)
    if not DrawingObj then return end
    pcall(function()
        DrawingObj.Visible = false
    end)
end

function API:RemoveDrawing(DrawingObj)
    if not DrawingObj then return end
    pcall(function()
        DrawingObj:Remove()
    end)
    
    if self.DrawingsList then
        for i, obj in ipairs(self.DrawingsList) do
            if obj == DrawingObj then
                table_remove(self.DrawingsList, i)
                break
            end
        end
    end
end

function API:ToggleDrawing(DrawingObj)
    if not DrawingObj then return end
    pcall(function()
        DrawingObj.Visible = not DrawingObj.Visible
    end)
    return DrawingObj.Visible
end

function API:ClearDrawings()
    if not self.DrawingsList then return end
    
    for _, DrawingObj in ipairs(self.DrawingsList) do
        pcall(function()
            DrawingObj:Remove()
        end)
    end
    
    self.DrawingsList = {}
end

function API:CreateDrawingManager()
    if type(self.DrawingManager) ~= "table" then
        self.DrawingManager = {Drawings = {}, AutoCleanup = true,  AutoUpdate = true,
            System = {
                Player = {
                    type = "Player",
                    getPosition = function(Target) 
                        if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                            return Target.Character.HumanoidRootPart.Position
                        end
                        return nil
                    end,
                    isValid = function(Target) 
                        return Target and Target.Parent ~= nil
                    end,
                    onRespawn = function(Target, Callback)
                        return Target.CharacterAdded:Connect(Callback)
                    end,
                    onRemove = function(Target, Callback)
                        return Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                    end
                },
                Character = {
                    type = "Model",
                    getPosition = function(Target)
                        local Roots = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChildWhichIsA("BasePart")
                        return Roots and Roots.Position or nil
                    end,
                    isValid = function(Target)
                        return Target and Target.Parent ~= nil and Target:FindFirstChild("Humanoid") ~= nil
                    end,
                    onRespawn = nil,
                    onRemove = function(Target, Callback)
                        return Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                    end
                },
                Part = {
                    type = "BasePart",
                    getPosition = function(Target) return Target.Position end,
                    isValid = function(Target) return Target and Target.Parent ~= nil end,
                    onRespawn = nil,
                    onRemove = function(Target, Callback)
                        return Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                    end
                },
                Vector3 = {
                    type = "Vector3",
                    getPosition = function(Target) return Target end,
                    isValid = function(Target) return true end,
                    onRespawn = nil,
                    onRemove = nil
                },
                Instance = {
                    type = "Instance",
                    getPosition = function(Target)
                        if Target:IsA("BasePart") then return Target.Position
                        elseif Target:IsA("Model") then
                            local root = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChildWhichIsA("BasePart")
                            return root and root.Position or nil
                        elseif Target:IsA("Player") then
                            if Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
                                return Target.Character.HumanoidRootPart.Position
                            end
                        end
                        return nil
                    end,
                    isValid = function(Target) return Target and Target.Parent ~= nil end,
                    onRespawn = function(Target, Callback)
                        if Target:IsA("Player") then
                            return Target.CharacterAdded:Connect(Callback)
                        end
                        return nil
                    end,
                    onRemove = function(Target, Callback)
                        return Target.AncestryChanged:Connect(function()
                            if not Target.Parent then Callback() end
                        end)
                    end
                }
            }
        }
    end
end

function API:GetDrawingSystem(Target)
    self:CreateDrawingManager()
    
    local Type = typeof(Target)
    
    if Type == "Player" then
        return self.DrawingManager.System.Player
    elseif Type == "Vector3" then
        return self.DrawingManager.System.Vector3
    elseif Type == "Instance" then
        if Target:IsA("BasePart") then
            return self.DrawingManager.System.Part
        elseif Target:IsA("Model") and Target:FindFirstChild("Humanoid") then
            return self.DrawingManager.System.Character
        else
            return self.DrawingManager.System.Instance
        end
    end
    
    return nil
end

function API:CreateDrawingV(DrawType, Properties, Target, OnUpdate, SpecifiedSystem)
    self:CreateDrawingManager()

    local DrawingObj = self:CreateDrawing(DrawType, Properties)
    if not DrawingObj then return nil end
    
    if not Target then return DrawingObj end

    local System = nil
    if SpecifiedSystem then
        System = self.DrawingManager.System[SpecifiedSystem]
        if not System then
            System = self:GetDrawingSystem(Target)
        end
    else
        System = self:GetDrawingSystem(Target)
    end
    
    if not System then return DrawingObj end

    local DrawingID = self:RandomString(15)
    self.DrawingManager.Drawings[DrawingID] = {
        Id = DrawingID,
        Drawing = DrawingObj,
        Target = Target,
        System = System,
        OnUpdate = OnUpdate,
        SpecifiedSystem = SpecifiedSystem,
        IsActive = true,
        Connections = {},
        LastScreenPos = nil
    }
    
    local Data = self.DrawingManager.Drawings[DrawingID]
    
    if System.onRemove then
        local Removed_Connection = System.onRemove(Target, function()
            if Data.IsActive then
                if Data.Drawing then
                    self:RemoveDrawing(Data.Drawing)
                end
                for _, connName in pairs(Data.Connections) do
                    self:_Disconnect(connName)
                end
                self.DrawingManager.Drawings[DrawingID] = nil
            end
        end)
    
        local Drawing_Removed = "@Draw_Remove: " .. DrawingID
        self:_Connect(Drawing_Removed, Removed_Connection)
        table_insert(Data.Connections, Drawing_Removed)
    end
    
    local function CreateRendered()
        local Render_Connection = RenderStepped:Connect(function()
            if not Data or not Data.IsActive then return end
            
            if not Data.System.isValid(Data.Target) then
                self:HideDrawing(Data.Drawing)
                return
            end
            
            local Position = Data.System.getPosition(Data.Target)
            if not Position then
                self:HideDrawing(Data.Drawing)
                return
            end
            
            local screenPos, onScreen = self:WorldToScreen(Position)
            
            if onScreen and screenPos then
                self:ShowDrawing(Data.Drawing)
        
                if DrawType == "Text" then
                    Data.Drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                elseif DrawType == "Circle" or DrawType == "Square" then
                    Data.Drawing.Position = Vector2.new(screenPos.X, screenPos.Y)
                elseif DrawType == "Line" and Data.LastScreenPos then
                    Data.Drawing.From = Data.LastScreenPos
                    Data.Drawing.To = Vector2.new(screenPos.X, screenPos.Y)
                end
                
                if OnUpdate then
                    OnUpdate(Data.Drawing, Data.Target, screenPos, onScreen)
                end
                
                Data.LastScreenPos = Vector2.new(screenPos.X, screenPos.Y)
            else
                self:HideDrawing(Data.Drawing)
            end
        end)
        
        return Render_Connection
    end
    
    local CRender_Connection = CreateRendered()
    local Draw_Rendered = "@Draw_Render: " .. DrawingID
    self:_Connect(Draw_Rendered, CRender_Connection)
    table_insert(Data.Connections, Draw_Rendered)
    
    if System.onRespawn then
        local function onRespawn()
            if Data and Data.IsActive then
                for i, Connection in ipairs(Data.Connections) do
                    if Connection:match("@Draw_Render: ") then
                        self:_Disconnect(Connection)
                        Data.Connections[i] = nil
                        break
                    end
                end

                local NRender_Connection = CreateRendered()
                local NDraw_Rendered = "@Draw_Render: " .. DrawingID
                self:_Connect(NDraw_Rendered, NRender_Connection)
                table_insert(Data.Connections, NDraw_Rendered)
            end
        end
        
        local OnRespawn = System.onRespawn(Target, onRespawn)
        local Draw_Spawned = "@Draw_Respawn: " .. DrawingID
        self:_Connect(Draw_Spawned, OnRespawn)
        table_insert(Data.Connections, Draw_Spawned)
    end

    return {
        Drawing = DrawingObj,
        System = System,
        Specified = SpecifiedSystem ~= nil,
        SpecifiedName = SpecifiedSystem,
        Remove = function()
            if Data.IsActive then
                Data.IsActive = false
                for _, Connection in pairs(Data.Connections) do
                    self:_Disconnect(Connection)
                end
                if Data.Drawing then
                    self:RemoveDrawing(Data.Drawing)
                end
                self.DrawingManager.Drawings[DrawingID] = nil
            end
        end,
        Update = function(_, newProps)
            return self:UpdateDrawing(DrawingObj, newProps)
        end,
        Show = function() self:ShowDrawing(DrawingObj) end,
        Hide = function() self:HideDrawing(DrawingObj) end
    }
end

function API:ClearDrawingsV()
    if not self.DrawingManager then return end

    for id, Data in pairs(self.DrawingManager.Drawings) do
        if Data and Data.IsActive then
            Data.IsActive = false
            for _, Connection in pairs(Data.Connections or {}) do
                self:_Disconnect(Connection)
            end
            if Data.Drawing then
                self:RemoveDrawing(Data.Drawing)
            end
        end
    end

    self.DrawingManager.Drawings = {}
end

function API:PlaySound(Id, Options)
    Options = Options or {}
    self.Sounds = self.Sounds or {}

    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    
    if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end
    
    local Data = self.Sounds[SoundId]
    if not Data then
        local SoundInstance = self:CreateInstance("Sound", {
            Name = self:RandomString(15),
            SoundId = SoundId,
            Parent = SoundService
        })
        Data = {Instance = SoundInstance}
        self.Sounds[SoundId] = Data
    end
    
    if not Options.Stack then
        if Data.Connection then
            self:_Disconnect(Data.Connection)
            Data.Connection = nil
        end
        
        if Data.Instance.Playing then
            Data.Instance:Stop()
        end
    end

    Data.Instance.TimePosition = 0
    Data.Instance.Volume = Options.Volume or 1
    Data.Instance.Looped = Options.Looped or false
    Data.Instance:Play()

    if Options.OnEnded then
        local Manager = "@Sound_" .. self:RandomString(15)
        local Connection = Data.Instance.Ended:Connect(function()
            Options.OnEnded(Data.Instance)
            self:_Disconnect(Manager)

            if Data then
                Data.Connection = nil
            end
        end)

        self:_Connect(Manager, Connection)
        Data.Connection = Manager
    end

    return Data.Instance
end

function API:IsSoundPlaying(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
    end
    
    local Data = self.Sounds[SoundId]
    return Data and Data.Instance and Data.Instance.Playing or false
end

function API:PauseSound(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
    end
    
    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance:Pause()
        return true
    end
    return false
end

function API:ResumeSound(Id)
    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end
    if type(SoundId) == "number" then
        SoundId = "rbxassetid://" .. SoundId
    end
    
    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance:Resume()
        return true
    end
    return false
end

function API:StopSound(...)
    self.Sounds = self.Sounds or {}

    for _, Id in ipairs({...}) do
        local SoundId = Id
        if self.Sounds.Assets and self.Sounds.Assets[Id] then
            SoundId = self.Sounds.Assets[Id]
        end
        
        if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
            SoundId = "rbxassetid://" .. tostring(SoundId)
        end

        local Data = self.Sounds[SoundId]
        if Data and Data.Instance then
            if Data.Connection then
                self:_Disconnect(Data.Connection)
                Data.Connection = nil
            end
            Data.Instance:Stop()
        end
    end
end

function API:SetVolume(Id, Volume)
    self.Sounds = self.Sounds or {}

    local SoundId = Id
    if self.Sounds.Assets and self.Sounds.Assets[Id] then
        SoundId = self.Sounds.Assets[Id]
    end

    if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
        SoundId = "rbxassetid://" .. tostring(SoundId)
    end

    local Data = self.Sounds[SoundId]
    if Data and Data.Instance then
        Data.Instance.Volume = Volume
        return true
    end
    
    return false
end

function API:Preload(...)
    self.Sounds = self.Sounds or {}

    for _, Id in ipairs({...}) do
        local SoundId = Id
        if self.Sounds.Assets and self.Sounds.Assets[Id] then
            SoundId = self.Sounds.Assets[Id]
        end
        
        if type(SoundId) == "number" or (type(SoundId) == "string" and SoundId:match("^%d+$")) then
            SoundId = "rbxassetid://" .. tostring(SoundId)
        end

        if not self.Sounds[SoundId] then
            local SoundInstance = self:CreateInstance("Sound", {
                Name = self:RandomString(15),
                SoundId = SoundId,
                Volume = 0,
                Parent = SoundService
            })
            SoundInstance:Play()
            task_wait(0.05)
            SoundInstance:Stop()
            self.Sounds[SoundId] = {Instance = SoundInstance}
        end
    end
end

function API:SoundsAssets(Assets)
    self.Sounds = self.Sounds or {}
    self.Sounds.Assets = Assets
end

function API:ClearSounds()
    if not self.Sounds then return end

    for SoundId, Data in pairs(self.Sounds) do
        if type(Data) == "table" and Data.Instance then
            if Data.Connection then
                self:_Disconnect(Data.Connection)
            end

            pcall(function()
                Data.Instance:Stop()
                Data.Instance:Destroy()
            end)
        end
    end
    
    self.Sounds = nil
end

function API:LoadCustomAsset(Asset, Url)
    if not is_file(Asset) then
        local Success, Content = pcall(function()
            return Game:HttpGet(Url)
        end)

        if Success then 
            write_file(Asset, Content) 
        else 
            return Url 
        end
    end

    if Get_Asset then
        return Get_Asset(Asset)
    else
        return is_file(Asset) and "rbxasset://" .. Asset or Url
    end
end

function API:GetAssetInfo(Id)
    self.AssetCache = self.AssetCache or {}

    local Cached = self.AssetCache[Id]
    if Cached then
        return Cached
    end
    
    local Success, Info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, Id)

    if not Success or not Info then
        return nil
    end
    
    local Result = {
        Id = Id,
        Name = Info.Name,
        Creator = Info.Creator and Info.Creator.Name,
        CreatorId = Info.Creator and Info.Creator.Id,
        TypeId = Info.AssetTypeId,
        TypeName = AssetTypes[Info.AssetTypeId] or "Unknown",
        Description = Info.Description,
        Created = Info.Created,
        Updated = Info.Updated,
        Price = Info.PriceInRobux,
        IsForSale = Info.IsForSale,
        IsLimited = Info.IsLimited,
        IsLimitedUnique = Info.IsLimitedUnique,
        CollectibleItemId = Info.CollectibleItemId,
        SaleLocation = Info.SaleLocation,
        Genres = Info.Genres,
        ItemRestrictions = Info.ItemRestrictions
    }

    self.AssetCache[Id] = Result
    return Result
end

function API:GetDescendants(Instance, ClassName, Limit)
    local Descendants = Instance:GetDescendants()
    local Total = #Descendants
    Limit = Limit or Total
    
    local Results = table_create(Limit)
    local Count = 0
    
    for i = 1, Total do
        if Count >= Limit then break end
        
        local obj = Descendants[i]
        if obj:IsA(ClassName) then
            Count = Count + 1
            Results[Count] = obj
        end
    end
    
    if Count < Limit then
        local Trimmed = table_create(Count)
        for i = 1, Count do
            Trimmed[i] = Results[i]
        end
        return Trimmed, Count
    end
    
    return Results, Count
end

function API:GetChildren(Instance, ClassName)
    local Children = Instance:GetChildren()
    local Results = table_create(#Children)
    local Count = 0

    for i = 1, #Children do
        local Instance = Children[i]
        if Instance:IsA(ClassName) then
            Count = Count + 1
            Results[Count] = Instance
        end
    end
    
    return Results, Count
end

function API:SaveData(FileName, Data)
    local Success, Encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)
    if not Success then return false end

    local Success, Err = pcall(function()
        write_file(FileName, Encoded)
    end)
    return Success
end

function API:LoadData(FileName)
    if not is_file(FileName) then return nil end
    
    local Success, Content = pcall(function()
        return read_file(FileName)
    end)
    if not Success then return nil end
    
    local Success, Decoded = pcall(function()
        return HttpService:JSONDecode(Content)
    end)
    return Success and Decoded or nil
end

function API:DeleteData(FileName)
    if is_file(FileName) then
        pcall(function() del_file(FileName) end)
        return true
    end
    return false
end

function API:GetDevice()
    return GetPlatform(UserInputService)
end

function API:ToPlace(Place)
    TeleportService:Teleport(Place)
end

function API:Time()
    return os_date("%H:%M:%S")
end

function API:Date()
    return os_date("%Y/%m/%d")
end

function API:GetPing()
    local Ping = Performance.Network.ServerStatsItem["Data Ping"]:GetValue()
    return tonumber(string_format("%.2f", Ping))
end

function API:GetFps()
    if not self.FpsCounter then
        local Frames = tick()
        self.CurrentFPS = 0

        self.FpsCounter = RenderStepped:Connect(function()
            local tick = tick()
            self.CurrentFPS = 1 / (tick - Frames)
            Frames = tick
        end)

        self:_Connect("@Fps", self.FpsCounter)
    end

    return self.CurrentFPS or 0
end

function API:StopFps()
    self:_Disconnect("@Fps")
    self.FpsCounter = nil
    self.CurrentFPS = 0
end

function API:QueueOnTeleport(Flag, State, Script, Callbacks)
    if not self.Queues_Loaded then
        if is_file("@QueueSystem.json") then
            local Content = read_file("@QueueSystem.json")
            if Content then
                local Success, Data = pcall(HttpService.JSONDecode, HttpService, Content)
                if Success and Data and Data.Queues then
                    self.Teleport_Queues = Data.Queues
                else
                    self.Teleport_Queues = {}
                end
            else
                self.Teleport_Queues = {}
            end
        else
            self.Teleport_Queues = {}
        end
        self.Queues_Loaded = true
    end

    if Callbacks and type(Callbacks) == "table" then
        self.QueueCallbacks = self.QueueCallbacks or {}
        self.QueueCallbacks[Flag] = Callbacks
    end

    if State == false then
        self.Teleport_Queues = self.Teleport_Queues or {}
        self.Teleport_Queues[Flag] = nil

        local SaveData = { Queues = self.Teleport_Queues }
        local Encoded = HttpService:JSONEncode(SaveData)
        write_file("@QueueSystem.json", Encoded)
        return false
    end

    self.Teleport_Queues = self.Teleport_Queues or {}
    self.Teleport_Queues[Flag] = Script

    local SaveData = { Queues = self.Teleport_Queues }
    local Encoded = HttpService:JSONEncode(SaveData)
    write_file("@QueueSystem.json", Encoded)

    if not self.TeleportListener then
        self.TeleportListener = LocalPlayer.OnTeleport:Connect(function(TeleportState)
            for f, s in pairs(self.Teleport_Queues) do
                if QueueOnTeleport then
                    pcall(QueueOnTeleport, s)
                end
            end

            if TeleportState == Enum.TeleportState.Failed then
                for f, cb in pairs(self.QueueCallbacks or {}) do
                    if cb.OnFailed then pcall(cb.OnFailed) end
                end
            end
        end)
        self:_Connect("@TeleportQueue", self.TeleportListener)
    end

    local Call = self.QueueCallbacks and self.QueueCallbacks[Flag]
    if Call and Call.OnStart then
        pcall(Call.OnStart, Script)
    end

    return true
end

function API:SetQueue(Flag, State)
    self.Teleport_Queues = self.Teleport_Queues or {}

    if Flag == false and State == nil then
        self:_Disconnect("@TeleportQueue")
        return
    end

    if State then
        local Script = self.Teleport_Queues[Flag]
        if Script then
            return self:QueueOnTeleport(Flag, true, Script)
        end
        return false
    else
        return self:QueueOnTeleport(Flag, false)
    end
end

function API:LoadFile(Url)
    local Success, Result = pcall(function()
        return loadstring(Game:HttpGet(Url .. "?nocache=" .. tostring(os_clock())))()
    end)

    return Success and Result or nil
end

function API:GetWebSocket()
    return (pcall(function() return WebSocket end) and WebSocket) or nil
end

function API:ConnectSocket(Url)
    local WebSocketLib = self:GetWebSocket()
    
    if not WebSocketLib then
        return false, "WebSocket not available"
    end
    
    if self.Websocket and self.Websocket.Connected then
        return true, "Already connected"
    end
    
    local Success, Connection = pcall(function()
        return WebSocketLib.connect(Url)
    end)
    
    if Success and Connection then
        self.Websocket = {
            Connection = Connection,
            Connected = true,
            Url = Url,
            Handlers = {},
            OnDisconnect = nil,
            OnError = nil
        }

        self:_Connect("@WebSocket_Message", Connection.OnMessage:Connect(function(message)
            if self.Websocket and self.Websocket.Handlers then
                for _, handler in ipairs(self.Websocket.Handlers) do
                    pcall(handler, message)
                end
            end
        end))

        self:_Connect("@WebSocket_Close", Connection.OnClose:Connect(function()
            if self.Websocket then
                self.Websocket.Connected = false
                if self.Websocket.OnDisconnect then
                    pcall(self.Websocket.OnDisconnect)
                end
            end
        end))
        
        if Connection.OnError then
            self:_Connect("@WebSocket_Error", Connection.OnError:Connect(function(Err)
                if self.Websocket and self.Websocket.OnError then
                    pcall(self.Websocket.OnError, Err)
                end
            end))
        end
        
        return true, "Connected"
    end

    return false, "Connection failed: " .. tostring(Success)
end

function API:OnSocketMessage(Callback)
    if not self.Websocket then
        self.Websocket = { Handlers = {} }
    end
    if not self.Websocket.Handlers then
        self.Websocket.Handlers = {}
    end
    table_insert(self.Websocket.Handlers, Callback)
end

function API:SendSocket(Message)
    if not self.Websocket or not self.Websocket.Connection or not self.Websocket.Connected then
        return false, "Not connected"
    end
    
    local Success, Err = pcall(function()
        self.Websocket.Connection:Send(Message)
    end)
    
    if Success then
        return true, "Message sent"
    else
        return false, "Send failed: " .. tostring(Err)
    end
end

function API:DisconnectSocket()
    if not self.Websocket or not self.Websocket.Connection then
        return false, "Not connected"
    end

    local Success, Err = pcall(function()
        self.Websocket.Connection:Close()
        self.Websocket.Connected = false
        self.Websocket = nil
    end)
    
    if Success then
        return true, "Disconnected"
    else
        return false, "Disconnect failed: " .. tostring(Err)
    end
end

function API:IsSocketConnected()
    return self.Websocket and self.Websocket.Connected or false
end

function API:OnSocketDisconnect(Callback)
    if not self.Websocket then
        self.Websocket = {}
    end
    self.Websocket.OnDisconnect = Callback
end

function API:OnSocketError(Callback)
    if not self.Websocket then
        self.Websocket = {}
    end
    self.Websocket.OnError = Callback
end

function API:ClearWebSockets()
    if not self.Websocket then return end

    self:_Disconnect("@WebSocket_Message")
    self:_Disconnect("@WebSocket_Close")
    self:_Disconnect("@WebSocket_Error")

    if self.Websocket.Connection then
        pcall(function()
            self.Websocket.Connection:Close()
        end)
    end

    self.Websocket = nil
end

function API:ToColor3(Color)
    if not Color then return Color3_fromRGB(255, 255, 255) end
    
    local ColorType = typeof(Color)
    
    if ColorType == "Color3" then
        return Color
    end
    
    if ColorType == "string" then
        if Color:match("^#?%x%x%x%x%x%x$") then
            return self:HexToRGB(Color)
        end
        local R, G, B = Color:match("(%d+)[%s,]*(%d+)[%s,]*(%d+)")
        if R and G and B then
            return Color3_fromRGB(tonumber(R), tonumber(G), tonumber(B))
        end
    end
    
    if ColorType == "table" then
        if Color[1] and Color[2] and Color[3] then
            return Color3_fromRGB(Color[1], Color[2], Color[3])
        end

        if (Color.r or Color.R) and (Color.g or Color.G) and (Color.b or Color.B) then
            return Color3_fromRGB(
                Color.r or Color.R,
                Color.g or Color.G,
                Color.b or Color.B
            )
        end
	
        if (Color.H or Color.h) and (Color.S or Color.s) and (Color.V or Color.v) then
            return Color3_fromHSV(Color.H or Color.h, Color.S or Color.s, Color.V or Color.v)
        end
    end

    if Color.h and Color.s and Color.v then
        return Color3_fromHSV(Color.h, Color.s, Color.v)
    end
    
    return Color3_fromRGB(255, 255, 255)
end

function API:StringToRGB(String)
    if not String then return nil end
    
    local R = tonumber(string_match(String, "(%d+)[%s]*,[%s]*%d+[%s]*,[%s]*%d+"))
    local G = tonumber(string_match(String, "%d+[%s]*,[%s]*(%d+)[%s]*,[%s]*%d+"))
    local B = tonumber(string_match(String, "%d+[%s]*,[%s]*%d+[%s]*,[%s]*(%d+)"))
    
    if R and G and B then
        return Color3_fromRGB(R, G, B)
    end
    
    return nil
end

function API:RGBToString(Rgb)
    return math_floor(Rgb.R * 255) .. ", " .. math_floor(Rgb.G * 255) .. ", " .. math_floor(Rgb.B * 255)
end

function API:HexToRGB(Hex)
    Hex = Hex:gsub("#", "")
    local R = tonumber(Hex:sub(1, 2), 16)
    local G = tonumber(Hex:sub(3, 4), 16)
    local B = tonumber(Hex:sub(5, 6), 16)
    return Color3_fromRGB(R, G, B)
end

function API:RGBToHex(Rgb)
    local R = math_floor(Rgb.R * 255)
    local G = math_floor(Rgb.G * 255)
    local B = math_floor(Rgb.B * 255)
    return string_format("#%02X%02X%02X", R, G, B)
end

function API:HSVToRGB(H, S, V)
    return Color3_fromHSV(H, S, V)
end

function API:RGBToHSV(Rgb)
    return Rgb.R, Rgb.G, Rgb.B
end

function API:Rainbowify(Speed)
    Speed = Speed or 1
    local Time = tick() * Speed
    return Color3_fromHSV(Time % 1, 1, 1)
end

function API:LightenColor(Color, Amount)
    Amount = Amount or 0.15
    local Color3 = self:ToColor3(Color)
    local H, S, V = Color3:ToHSV()
    V = math_clamp(V + Amount, 0, 1)
    return Color3_fromHSV(H, S, V)
end

function API:DarkenColor(Color, Amount)
    Amount = Amount or 0.15
    local Color3 = self:ToColor3(Color)
    local H, S, V = Color3:ToHSV()
    V = math_clamp(V - Amount, 0, 1)
    return Color3_fromHSV(H, S, V)
end

function API:RandomColor()
    return Color3_fromHSV(math_random(), math_random(), 1)
end

function API:Gitport(Owner, Repo, Version, File)
    local Tag = (Version == "latest" and "latest/download" or "download/" .. Version)    
    return self:LoadFile(("https://github.com/%s/%s/releases/%s/%s"):format(Owner, Repo, Tag, File))
end

function API:ControlF9(State)
    pcall(function()
        StarterGuiService:SetCore("DevConsoleVisible", State or false)
    end)
end

function API:RandomString(Length)
    Length = Length or 15
    local Characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local t = table_create(Length)
    
    for i = 1, Length do
        local RandomIndex = math_random(1, #Characters)
        t[i] = string_sub(Characters, RandomIndex, RandomIndex)
    end
    
    return table_concat(t)
end

function API:SpeedTest(Func, Iterations, ...)
    Iterations = Iterations or 100
    local args = {...}
    
    local Start = os_clock()
    for i = 1, Iterations do
        pcall(function() Func(unpack(args)) end)
    end
    local TotalMs = (os_clock() - Start) * 1000
    
    local Result = {
        Total = TotalMs,
        Average = TotalMs / Iterations,
        Iterations = Iterations
    }
    
    print(string_format("[SpeedTest] %d iterations: %.2f ms total (avg: %.3f ms)", 
        Iterations, TotalMs, Result.Average))
    
    return Result
end

function API:HowLong(Ago)
    if Ago < 60 then
        return "Just now"
    elseif Ago >= 31536000 then
        local y = math_floor(Ago / 31536000)
        return y .. " year" .. (y == 1 and "" or "s") .. " ago"
    elseif Ago >= 2592000 then
        local m = math_floor(Ago / 2592000)
        return m .. " month" .. (m == 1 and "" or "s") .. " ago"
    elseif Ago >= 604800 then
        local w = math_floor(Ago / 604800)
        return w .. " week" .. (w == 1 and "" or "s") .. " ago"
    elseif Ago >= 86400 then
        local d = math_floor(Ago / 86400)
        return d .. " day" .. (d == 1 and "" or "s") .. " ago"
    elseif Ago >= 3600 then
        local h = math_floor(Ago / 3600)
        return h .. " hour" .. (h == 1 and "" or "s") .. " ago"
     else
        local min = math_floor(Ago / 60)
        return min .. " minute" .. (min == 1 and "" or "s") .. " ago"
    end
end

function API:Version() 
    return Project;
end

function API:LogCommit(Repo, Branch, Version) -- // Github Only
    local Owner, RepoName

    local Matches = {Repo:match("github%.com/([^/]+)/([^/]+)")}
    if #Matches >= 2 then
        Owner = Matches[1]
        RepoName = Matches[2]
        RepoName = RepoName:gsub("%.git$", "")
    else
        return nil
    end

    local function StripString(s)
        if not s then return "Unknown" end
        s = s:match("^%s*(.-)%s*$")
        s = s:gsub("%s+", " ")
        return s
    end

    local Selected = Branch or "main"
    local Github = "https://github.com/" .. Owner .. "/" .. RepoName .. "/commits/" .. Selected .. ".atom"

    local Success, Response = pcall(function()
        return Game:HttpGet(Github .. "?nocache=" .. os_clock())
    end)

    if not Success then warn("Failed to fetch commit logs~") return nil end

    local Commits = {}
    local StartPoint = 1

    while true do
        local Entry = Response:match("<entry>(.-)</entry>", StartPoint)
        if not Entry then break end

        local author = StripString(Entry:match("<name>(.-)</name>"))
        local message = StripString(Entry:match("<title>(.-)</title>"))
        local updated = Entry:match("<updated>(.-)</updated>")
        local fullSha = StripString(Entry:match("<id>.-[Cc]ommit/(.-)</id>"))
        local sha = fullSha and fullSha:sub(1, 7) or "Unknown"

        if updated and fullSha then
            local commitTime = DateTime.fromIsoDate(updated)
            local now = DateTime.now()
            local timeAgo = self:HowLong(now.UnixTimestamp - commitTime.UnixTimestamp)

            table_insert(Commits, {
                Author = author,
                Message = message,
                Sha = sha,
                FullSha = fullSha,
                TimeAgo = timeAgo,
                Timestamp = commitTime,
                RawDate = updated,
                Version = #Commits + 1
            })
        end

        StartPoint = Response:find("</entry>", StartPoint) + 8
        if #Commits >= Version then break end
    end

    if Version then
        if Commits[Version] then
            return Commits[Version]
        else
            warn("Version " .. Version .. " not found. Only " .. #Commits .. " commits available.")
            return nil
        end
    else
        return Commits[1] or nil
    end
end

function API:IsMobile()
    local Plat = self:GetDevice()
    return Plat == Enum.Platform.IOS or Plat == Enum.Platform.Android
end

function API:UpdateTrack(FilePath, RemoteUrl, OnDownloaded, OnChanged, Options)
    task_spawn(function()
        Options = Options or {}
        local MaxSize = Options.MaxSize or math_huge
        
        local FileName = FilePath:match("[^/]+$")
        local Dir = FilePath:match("^(.+)/[^/]+$")
        if Dir then
            local path = ""
            for folder in Dir:gmatch("[^/]+") do
                path = path .. folder .. "/"
                if not is_folder(path) then make_folder(path) end
            end
        end
        
        local Success, Remote = pcall(function()
            return Game:HttpGet(RemoteUrl .. "?v=" .. os_time())
        end)
        if not Success then return warn("Failed: " .. RemoteUrl) end
        
        local StoredContent = Remote
        local Truncated = false
        if #Remote > MaxSize then
            StoredContent = Remote:sub(1, MaxSize)
            Truncated = true
        end
        
        local Exists = is_file(FilePath)
        local Old = Exists and read_file(FilePath) or nil
        local Changed = Exists and Old ~= StoredContent
        
        write_file(FilePath, StoredContent)
        
        if not Exists and OnDownloaded then
            OnDownloaded({FileName = FileName, Content = Remote, Size = #Remote, StoredSize = #StoredContent, Truncated = Truncated})
        elseif Changed and OnChanged then
            OnChanged({FileName = FileName, Content = Remote, OldSize = #Old, NewSize = #Remote, Truncated = Truncated})
        end
        
        return {FileName = FileName, Changed = Changed, New = not Exists, Content = Remote, StoredSize = #StoredContent}
    end)
end

function API:AbbreviateNumber(Number)
    local Abbrev = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "De" }

    for i = #Abbrev, 1, -1 do
        local Value = 10 ^ (i * 3)
        if Number >= Value then
            return string_format("%.1f%s", Number / Value, Abbrev[i])
        end
    end

    return tostring(Number)
end

function API:GetAveragePosition(Targets)
    local TotalX, TotalY, TotalZ = 0, 0, 0
    local Count = 0
    
    local Index, Target = next(Targets)
    while Index do
        local Pos = self:ResolvePosition(Target)
        if Pos then
            TotalX = TotalX + Pos.X
            TotalY = TotalY + Pos.Y
            TotalZ = TotalZ + Pos.Z
            Count = Count + 1
        end
        Index, Target = next(Targets, Index)
    end
    
    if Count == 0 then return nil end
    
    local InvCount = 1 / Count
    return Vector3_new(TotalX * InvCount, TotalY * InvCount, TotalZ * InvCount)
end

function API:RandomVector3(RangeX, RangeY, RangeZ)
    if type(RangeX) == "table" then
        if RangeX.X and RangeX.Y and RangeX.Z then
            return Vector3_new(
                math_random(-RangeX.X, RangeX.X),
                math_random(-RangeX.Y, RangeX.Y),
                math_random(-RangeX.Z, RangeX.Z)
            )
        elseif RangeX[1] and RangeX[2] and RangeX[3] then
            return Vector3_new(
                math_random(-RangeX[1], RangeX[1]),
                math_random(-RangeX[2], RangeX[2]),
                math_random(-RangeX[3], RangeX[3])
            )
        end
    end
    
    RangeX = RangeX or 100
    RangeY = RangeY or RangeX
    RangeZ = RangeZ or RangeX
    
    return Vector3_new(
        math_random(-RangeX, RangeX),
        math_random(-RangeY, RangeY),
        math_random(-RangeZ, RangeZ)
    )
end

function API:GetTitles()
    return {
        "mr", "mrs", "ms", "miss", "mx", "dr", "doc", "doctor", "prof", "professor",
        "phd", "md", "dds", "dvm", "jd", "esq", "attorney", "lawyer", "judge",
        "justice", "chief", "head", "dean", "principal", "superintendent", "director",
        "chair", "chairman", "chairwoman", "chairperson", "president", "vice president",
        "ceo", "cfo", "coo", "cto", "executive", "manager", "supervisor", "coordinator",
        "administrator", "officer", "agent", "special agent", "detective", "inspector",
        "sergeant", "lieutenant", "captain", "major", "colonel", "general", "admiral",
        "commander", "lieutenant commander", "ensign", "petty officer", "seaman",
        "corporal", "sergeant major", "staff sergeant", "master sergeant", "warrant officer",
        "brigadier", "brigadier general", "major general", "lieutenant general",
        "general of the army", "fleet admiral", "rear admiral", "vice admiral",
        "private", "soldier", "cadet", "midshipman", "recruit", "veteran",
        "senator", "representative", "congressman", "congresswoman", "ambassador",
        "governor", "lieutenant governor", "mayor", "councilman", "councilwoman",
        "alderman", "minister", "prime minister", "chancellor", "secretary",
        "secretary of state", "treasurer", "attorney general", "solicitor general",
        "speaker", "majority leader", "minority leader", "whip", "chief of staff",
        "king", "queen", "prince", "princess", "duke", "duchess", "marquis", "marchioness",
        "earl", "countess", "viscount", "viscountess", "baron", "baroness", "sir", "dame",
        "lord", "lady", "master", "madam", "madame", "monsieur", "herr", "frau", "fräulein",
        "signor", "signora", "signorina", "don", "doña", "dom", "dona", "rajah", "ranee",
        "sultan", "sultana", "emir", "sheikh", "sheikha", "caliph", "pharaoh", "kaiser",
        "tsar", "tsarina", "emperor", "empress", "archduke", "archduchess", "grand duke",
        "pope", "cardinal", "archbishop", "bishop", "priest", "pastor", "minister",
        "reverend", "rabbi", "imam", "sheikh", "mufti", "ayatollah", "grand mufti",
        "monsignor", "deacon", "archdeacon", "canon", "vicar", "chaplain", "missionary",
        "evangelist", "apostle", "prophet", "guru", "swami", "lama", "dalai lama",
        "monk", "nun", "friar", "abbot", "abbess", "prior", "prioress", "elder",
        "nurse", "rn", "lpn", "np", "pa", "therapist", "psychologist", "psychiatrist",
        "counselor", "social worker", "paramedic", "emt", "surgeon", "anesthesiologist",
        "cardiologist", "neurologist", "pediatrician", "oncologist", "radiologist",
        "veterinarian", "vet", "chiropractor", "optometrist", "dentist", "orthodontist",
        "pharmacist", "pathologist", "urologist", "gynecologist",
        "teacher", "instructor", "lecturer", "assistant professor", "associate professor",
        "adjunct professor", "emeritus", "fellow", "scholar", "researcher", "scientist",
        "historian", "philosopher", "mathematician", "physicist", "chemist", "biologist",
        "astronomer", "geologist", "economist", "sociologist", "psychologist", "linguist",
        "esquire", "counsel", "barrister", "solicitor", "advocate", "prosecutor",
        "defense attorney", "public defender", "district attorney", "da", "clerk", "bailiff",
        "magistrate", "justice of the peace", "notary", "notary public", "paralegal",
        "boss", "foreman", "team lead", "project manager", "product manager",
        "program manager", "scrum master", "agile coach", "owner", "founder",
        "co-founder", "partner", "principal", "associate", "analyst", "specialist",
        "administrator", "consultant", "advisor", "strategist", "planner",
        "honorable", "hon", "the honorable", "excellency", "your excellency", "grace",
        "your grace", "highness", "your highness", "majesty", "your majesty", "eminence",
        "your eminence", "holiness", "your holiness", "beatitude", "your beatitude",
        "dad", "father", "mom", "mother", "grandpa", "grandmother", "grandma",
        "uncle", "aunt", "cousin", "nephew", "niece", "brother", "sister", "husband",
        "wife", "fiance", "fiancee", "partner", "significant other", "parent", "guardian",
        "coach", "trainer", "instructor", "guide", "mentor", "tutor", "advisor",
        "assistant", "aide", "deputy", "vice", "acting", "interim", "temporary",
        "honorary", "emeritus", "retired", "former", "late", "young", "little",
        "gentleman", "lady", "young lady", "young man", "ma'am"
    }
end

function API:LoadEnglishDictionary()
    local File = "@EnglishDictionary.json"

    if is_file(File) then
        local Success, Data = pcall(function()
            return read_file(File)
        end)

        if Success and Data then
            local Decoded = HttpService:JSONDecode(Data)
            self.English_Dictionary = Decoded
            return true
        end
    end

    local Dictionary = "https://raw.githubusercontent.com/dwyl/english-words/master/words_dictionary.json"

    local Success, Data = pcall(function()
        return Game:HttpGet(Dictionary)
    end)

    if Success and Data then
        local Decoded = HttpService:JSONDecode(Data)
        self.English_Dictionary = {}
        
        for Word, _ in pairs(Decoded) do
            self.English_Dictionary[Word:lower()] = true
        end
        
        local JsonSuccess, JsonData = pcall(function()
            return HttpService:JSONEncode(self.English_Dictionary)
        end)
        
        if JsonSuccess and JsonData then
            write_file(File, JsonData)
        end

        return true
    end
    
    return false
end

function API:IsDictionary(Word)
    if not Word or Word == "" then return false end
    Word = Word:lower()
    
    if not self.English_Dictionary then
        self:LoadEnglishDictionary()
    end
    
    return self.English_Dictionary[Word] == true
end

function API:AutoCorrect(String)
    if not String or String == "" then return "" end
    
    local SplitWords = {}
    for Word in String:gmatch("%S+") do
        local CleanWord = Word:gsub("[%p]+$", "")
        local TrailingPunctuation = Word:match("[%p]+$") or ""
        table.insert(SplitWords, {word = CleanWord, punct = TrailingPunctuation, original = Word})
    end

    local ProcessedWords = {}
    local NextWordCapitalized = true
    local TitleList = self:GetTitles() 
    
    for Index, CurrentWord in ipairs(SplitWords) do
        local BaseWord = CurrentWord.word
        local LowerBaseWord = BaseWord:lower()
        local NeedsCapital = false
        
        if Index == 1 then
            NeedsCapital = true
        elseif NextWordCapitalized then
            NeedsCapital = true
        elseif LowerBaseWord == "i" then
            NeedsCapital = true
        end
        
        local IsTitleWord = false
        for _, TitleName in ipairs(TitleList) do
            if LowerBaseWord == TitleName then
                IsTitleWord = true
                NeedsCapital = true
                break
            end
        end
        
        if Index > 1 and not NeedsCapital then
            local PreviousLower = SplitWords[Index-1].word:lower()
            for _, TitleName in ipairs(TitleList) do
                if PreviousLower == TitleName then
                    NeedsCapital = true
                    break
                end
            end
        end
        
        local IsAllCapsSlang = self:IsDictionary(BaseWord) and BaseWord == BaseWord:upper()
        
        if IsAllCapsSlang then
            BaseWord = BaseWord:upper()
            NextWordCapitalized = false
        elseif NeedsCapital then
            BaseWord = BaseWord:sub(1, 1):upper() .. BaseWord:sub(2):lower()
            NextWordCapitalized = false
        else
            if not self:IsDictionary(BaseWord) and #BaseWord > 2 then
                BaseWord = BaseWord:sub(1, 1):upper() .. BaseWord:sub(2):lower()
            else
                BaseWord = BaseWord:lower()
            end
        end
    
        table.insert(ProcessedWords, BaseWord .. CurrentWord.punct)
        
        if CurrentWord.punct:match("[.!?]") then
            NextWordCapitalized = true
        else
            NextWordCapitalized = false
        end
    end
    
    local FinalText = table.concat(ProcessedWords, " ")
    
    FinalText = FinalText:gsub("%s+([%.,%?%!;:])", "%1")
    FinalText = FinalText:gsub("([%.,%?%!;:])(%w)", "%1 %2")
    
    if not FinalText:match("[%p]$") and FinalText:match("%w$") then
        FinalText = FinalText .. "."
    end
    
    return FinalText
end

function API:Reverseify(String)
    if not String or String == "" then return "" end
    
    local Words = {}
    for Word in String:gmatch("%S+") do
        table_insert(Words, Word)
    end
    
    local ReversedWords = {}
    for i = #Words, 1, -1 do
        local Word = Words[i]
        local ReversedWord = ""
        for j = #Word, 1, -1 do
            ReversedWord = ReversedWord .. Word:sub(j, j)
        end
        table_insert(ReversedWords, ReversedWord)
    end
    
    local Result = table_concat(ReversedWords, " ")
    
    return Result
end

function API:Nerdify(Text)
    if not Text or Text == "" then return "Erm, actually... ☝️🤓" end
    
    local Corrected = self:AutoCorrect(Text)
    
    Corrected = Corrected:gsub("%.$", "")
    
    local Words = {}
    for Word in Corrected:gmatch("%S+") do
        table.insert(Words, Word)
    end

    local Prefixes = {
        "Erm, actually, ",
        "Erm... Actually, ",
        "Well, ackshually, ",
        "Um, actually, ",
        "Erm, technically, ",
        "Well, technically speaking, ",
        "To be pedantic, ",
        "If we want to be precise, ",
        "I hate to be that guy, but ",
        "Well, if you want to get technical, ",
        "Actually, if you look at the facts, ",
        "Erm, excuse me, but ",
        "Well, according to my sources, ",
    }
    
    local Suffixes = {
        " ☝️🤓",
        " ☝️🤓 *adjusts glasses*",
        " ☝️🤓 *pushes up glasses*",
        " ☝️🤓 *snorts*",
        " ☝️🤓 *clears throat*",
        " ☝️🤓 *nods pedantically*",
        " ☝️🤓 hehe",
        " ☝️🤓 just saying",
        " ☝️🤓 fun fact",
        " ☝️🤓 the more you know",
    }
    
    local Prefix = ""
    if #Words > 4 then
        Prefix = Prefixes[math_random(1, #Prefixes)]
    elseif #Words > 2 then
        if math_random() < 0.5 then
            Prefix = Prefixes[math_random(1, #Prefixes)]
        end
    end

    if math_random() < 0.15 then
        Corrected = Corrected .. " hehe"
    end

    if math_random() < 0.05 then
        Prefix = "Erm, " .. Prefix:lower()
    end
    
    local Suffix = Suffixes[math_random(1, #Suffixes)]
    
    return Prefix .. Corrected:sub(1, 1):upper() .. Corrected:sub(2) .. Suffix
end

function API:Uwuify(Text)
    if not Text or Text == "" then return "uwu" end
    
    local Result = Text:lower()
    
    Result = Result:gsub("[rl]", "w")
    Result = Result:gsub("th", "d")
    Result = Result:gsub("you", "uwu")
    Result = Result:gsub("n([aeiou])", "ny%1")
    Result = Result:gsub("m([aeiou])", "my%1")
    Result = Result:gsub("ove", "uv")
    Result = Result:gsub("ck", "cc")
    
    local Words = {}
    for Word in Result:gmatch("%S+") do
        table.insert(Words, Word)
    end
    
    if #Words > 0 then
        local firstWord = Words[1]
        local stutterCount = math_random(1, 2)
        local stuttered = ""
        for i = 1, stutterCount do
            stuttered = stuttered .. firstWord:sub(1, 1) .. "-"
        end
        Words[1] = stuttered .. firstWord
    end
    
    Result = table_concat(Words, " ")
    
    local Suffixes = {" >w<", " uwu", " owo", " ^w^", " :3", "~", " Meow~"}
    Result = Result .. Suffixes[math_random(1, #Suffixes)]
    
    return Result
end

function API:Trim(String)
    return string_match(String, "^%s*(.-)%s*$")
end

function API:GetRandomNumber(Min, Max)
    return math_random(Min, Max)
end

function API:Chance(Percent)
    return math_random(1, 100) <= Percent
end

function API:Percent(Current, Max)
    if Max <= 0 then return 0 end
    return (Current / Max) * 100
end

function API:IsBetween(Value, Min, Max)
    return Value >= Min and Value <= Max
end

function API:IsNumeric(String)
    return string_match(String, "^%d+$") ~= nil
end

function API:IsURL(String)
    return String:match("^https?://[%w-.]+%.[a-zA-Z]{2,}(/.*)?$") ~= nil
end

function API:ResolvePosition(...)
    local args = {...}
    local numArgs = #args
    
    if numArgs >= 3 and type(args[1]) == "number" and type(args[2]) == "number" and type(args[3]) == "number" then
        return Vector3_new(args[1], args[2], args[3])
    end
    
    if numArgs >= 2 and type(args[1]) == "number" and type(args[2]) == "number" then
        return Vector3_new(args[1], args[2], numArgs >= 3 and args[3] or 0)
    end
    
    local arg = args[1]
    
    local function safePCall(func, ...)
        local success, result = pcall(func, ...)
        return success and result or nil
    end
    
    local function extractNumbers(str)
        local numbers = {}
        for num in string_gmatch(str, "(-?%d+%.?%d*)") do
            table_insert(numbers, tonumber(num))
        end
        return numbers
    end
    
    local function toVector3(x, y, z)
        if type(x) == "number" and type(y) == "number" then
            return Vector3_new(x, y, z or 0)
        end
        return nil
    end
    
    if arg == nil then
        return nil
    end
    
    local argType = typeof(arg)
    
    if argType == "Vector3" then
        return arg
    end
    
    if argType == "CFrame" then
        return arg.Position
    end
    
    if type(arg) == "number" then
        return Vector3_new(arg, 0, 0)
    end
    
    if type(arg) == "boolean" then
        if arg then
            return Vector3_new(0, 0, 0)
        end
        return nil
    end
    
    if argType == "Instance" then
        local function getPositionFromInstance(instance)
            if not instance then return nil end
        
            if instance:IsA("BasePart") then
                return instance.Position
            end
            
            if instance:IsA("BackpackItem") or instance:IsA("Tool") then
                local handle = instance:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return handle.Position
                end
                local anyPart = instance:FindFirstChildWhichIsA("BasePart")
                if anyPart then
                    return anyPart.Position
                end
                local pivot = safePCall(function() return instance:GetPivot() end)
                if pivot then return pivot.Position end
            end
            
            if instance:IsA("Model") then
                if instance.PrimaryPart and instance.PrimaryPart:IsA("BasePart") then
                    return instance.PrimaryPart.Position
                end
                local rootPart = instance:FindFirstChild("HumanoidRootPart")
                if rootPart and rootPart:IsA("BasePart") then
                    return rootPart.Position
                end
            end
            
            if instance:IsA("Player") and instance.Character then
                local root = instance.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    return root.Position
                end
                local pivot = safePCall(function() return instance.Character:GetPivot() end)
                if pivot then return pivot.Position end
            end
            
            if instance:IsA("Humanoid") and instance.Parent then
                local root = instance.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    return root.Position
                end
                local pivot = safePCall(function() return instance.Parent:GetPivot() end)
                if pivot then return pivot.Position end
            end
            
            if instance.GetPivot then
                local pivot = safePCall(function() return instance:GetPivot() end)
                if pivot and typeof(pivot) == "CFrame" then
                    return pivot.Position
                end
            end
            
            local anyPart = instance:FindFirstChildWhichIsA("BasePart")
            if anyPart then
                return anyPart.Position
            end
            
            local function findAnyPartRecursive(inst)
                for _, child in ipairs(inst:GetChildren()) do
                    if child:IsA("BasePart") then
                        return child.Position
                    end
                    local found = findAnyPartRecursive(child)
                    if found then return found end
                end
                return nil
            end
            
            return findAnyPartRecursive(instance)
        end
        
        local result = getPositionFromInstance(arg)
        if result then return result end
    end
    
    if type(arg) == "table" then
        local vectorFields = {"position", "Position", "pos", "Pos", "p", "vector", "Vector", "location", "Location"}
        for _, field in ipairs(vectorFields) do
            if arg[field] and typeof(arg[field]) == "Vector3" then
                return arg[field]
            end
        end
        
        if arg.CFrame and typeof(arg.CFrame) == "CFrame" then
            return arg.CFrame.Position
        end
        
        local x = arg.x or arg.X or arg[1]
        local y = arg.y or arg.Y or arg[2]
        local z = arg.z or arg.Z or arg[3]
        if type(x) == "number" and type(y) == "number" then
            return toVector3(x, y, z)
        end
        
        if #arg >= 3 then
            return toVector3(arg[1], arg[2], arg[3])
        end
        
        for _, value in pairs(arg) do
            if type(value) == "table" then
                local nested = API:ResolvePosition(value)
                if nested then return nested end
            end
        end
    end
    
    if type(arg) == "string" then
        local str = arg:gsub("%s+", " "):gsub(",", " "):gsub("%(", " "):gsub("%)", " ")
        
        local patterns = {
            "(-?%d+%.?%d*)%s+(-?%d+%.?%d*)%s+(-?%d+%.?%d*)",
            "[Vv]ector3?%s*[%(%[]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[%)%]]",
            "[Cc]frame.*%s*[%(%[]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)%s*[, ]%s*(-?%d+%.?%d*)",
            "(-?%d+%.?%d*)%s*[,]%s*(-?%d+%.?%d*)%s*[,]%s*(-?%d+%.?%d*)",
            "(-?%d+%.?%d*),(-?%d+%.?%d*),(-?%d+%.?%d*)",
        }
        
        for _, pattern in ipairs(patterns) do
            local x, y, z = str:match(pattern)
            if x and y and z then
                return toVector3(tonumber(x), tonumber(y), tonumber(z))
            end
        end
        
        local numbers = extractNumbers(str)
        if #numbers >= 3 then
            return toVector3(numbers[1], numbers[2], numbers[3])
        elseif #numbers == 2 then
            return toVector3(numbers[1], numbers[2], 0)
        elseif #numbers == 1 then
            return toVector3(numbers[1], 0, 0)
        end
    end
    
    if argType == "UDim2" then
        return Vector3_new(arg.X.Offset, arg.Y.Offset, 0)
    end
    
    if argType == "UDim" then
        return Vector3_new(arg.Offset, 0, 0)
    end
    
    if argType == "Region3" then
        return arg.CFrame.Position + (arg.Size / 2)
    end
    
    if argType == "Ray" then
        return arg.Origin
    end
    
    if type(arg) == "userdata" then
        local props = {"Position", "position", "Location", "location", "Origin", "origin"}
        for _, prop in ipairs(props) do
            if arg[prop] and typeof(arg[prop]) == "Vector3" then
                return arg[prop]
            end
        end
        
        if arg.CFrame and typeof(arg.CFrame) == "CFrame" then
            return arg.CFrame.Position
        end
        
        if arg.GetPivot then
            local pivot = safePCall(function() return arg:GetPivot() end)
            if pivot and typeof(pivot) == "CFrame" then
                return pivot.Position
            end
        end
    end
     
    return nil
end

function API:GetPlayer()
    return LocalPlayer
end

function API:GetCharacter()
    return Character
end

function API:GetRoot()
    return Roots
end

function API:GetHumanoid()
    return Humanoid
end

function API:GetHead()
    local Char = self:GetCharacter()
    if not Char then return nil end
    return Char:FindFirstChild("Head") or Char:WaitForChild("Head", 5)
end

function API:ForceReset()
    local Hum = self:GetHumanoid()
    if Hum then
        Hum:ChangeState(15)
    end
end

function API:GetBackpack()
    local Plr = self:GetPlayer()
    if not Plr then return nil end
    
    return Plr:FindFirstChild("Backpack") or Plr:WaitForChild("Backpack")
end

function API:GetTeam()
    local Plr = self:GetPlayer()
    return Plr.Team
end

function API:IsAlive()
    local Hum = self:GetHumanoid()
    return Hum and Hum.Health > 0
end

function API:IsAFriend(Player)
    if not Player then return false end
    return Player:IsFriendsWith(self:GetPlayer().UserId)
end

function API:GetPlaceId()
    return PlaceId
end

function API:GetJobId()
    return JobId
end

function API:GetGameId()
    return GameId
end

function API:Raknet_Desync(State)
    if not raknet then 
        return false 
    end

    if State then
        raknet.add_send_hook(Internal)
    else
        raknet.remove_send_hook(Internal)
    end
    return true
end

function API:ClearRaknet()
    if raknet then
        pcall(function() raknet.remove_send_hook(Internal) end)
    end
end

function API:SmartTimer(Name, Delay)
    self.Timers = self.Timers or {}

    local CT = tick()
    local Last = self.Timers[Name] or 0;

    if CT - Last >= Delay then
        self.Timers[Name] = CT;
        return true;
    end

    return false;
end

function API:WaitUntil(Condition, Out)
    local Time = 0

    while not Condition() do
        task_wait(0.1)
        Time += 0.1

        if Out and Time >= Out then
            return false
        end
    end

    return true
end

function API:Resolve(Mode, Input, Key)
    if typeof(Input) == "string" then
        return {Input}
    end

    if typeof(Input) == "table" then
        local Result = {}
        local k, v = next, Input
        while k do
            if v == true then
                Result[#Result + 1] = k
            end
            k, v = next, Input, k
        end
        Input = Result
    end

    if Mode == "Priority" then
        return self:ResolvePriority(Input, Key, true)
    elseif Mode == "Priority2" then
        return self:ResolvePriority(Input, Key, false)
    elseif Mode == "Random" then
        return self:TableShuffle(Input)
    end
    
    return Input or {}
end

function API:ResolvePriority(Result, Key, NewestFirst)
    if not Key then
        return Result
    end
    
    self.Recency_Stores = self.Recency_Stores or {}
    local Recency = self.Recency_Stores[Key] or {}

    local Current = {}
    for i = 1, #Result do
        Current[Result[i]] = true
    end
    
    local NewRec = {}
    local Seen = {}
    local len = 0
    
    for i = 1, #Recency do
        local Item = Recency[i]
        if Current[Item] and not Seen[Item] then
            len = len + 1
            NewRec[len] = Item
            Seen[Item] = true
        end
    end
    
    for i = 1, #Result do
        local Item = Result[i]
        if not Seen[Item] then
            len = len + 1
            NewRec[len] = Item
        end
    end
    
    self.Recency_Stores[Key] = NewRec
    
    if NewestFirst then
        return self:TableReverse(NewRec)
    else
        return NewRec
    end
end

function API:TableShuffle(T)
    if not T or #T <= 1 then
        return T
    end

    local Shuffled = {}
    for i = 1, #T do
        Shuffled[i] = T[i]
    end
    
    for i = #Shuffled, 2, -1 do
        local j = math_random(i)
        Shuffled[i], Shuffled[j] = Shuffled[j], Shuffled[i]
    end
    return Shuffled
end

function API:TableReverse(T)
    if not T or #T <= 1 then
        return T
    end
    
    local Reversed = {}
    local len = #T
    for i = 1, len do
        Reversed[i] = T[len - i + 1]
    end
    return Reversed
end

function API:TableIsEmpty(T)
    return next(T) == nil
end

function API:TableFind(T, Predicate)
    local k, v = next, T
    while k do
        if Predicate(v, k) then return v, k end
        k, v = next, T, k
    end
    return nil
end

function API:TableValues(T)
    local Values = {}
    local k, v = next, T
    while k do
        Values[#Values + 1] = v
        k, v = next, T, k
    end
    return Values
end

function API:TableKeys(T)
    local Keys = {}
    local k, v = next, T
    while k do
        Keys[#Keys + 1] = k
        k, v = next, T, k
    end
    return Keys
end

function API:TableHas(T, Value)
    for i = 1, #T do
        if T[i] == Value then return true end
    end
    return false
end

function API:TableFirst(T)
    return T[1]
end

function API:TableLast(T)
    return T[#T]
end

function API:TableLookup(T)
    local Lookup = {}
    for i = 1, #T do
        Lookup[T[i]] = true
    end
    return Lookup
end

function API:TableMerge(T1, T2)
    local Result = {}
    for i = 1, #T1 do Result[i] = T1[i] end
    for i = 1, #T2 do Result[#Result + 1] = T2[i] end
    return Result
end

function API:TableAdd(T, Value)
    for i = 1, #T do
        if T[i] == Value then return false end
    end
    T[#T + 1] = Value
    return true
end

function API:TableRemove(T, Value)
    for i = #T, 1, -1 do
        if T[i] == Value then
            table_remove(T, i)
            return true
        end
    end
    return false
end

function API:TableClear(T)
    for i = #T, 1, -1 do
        T[i] = nil
    end
end

function API:Tween(Target: BasePart?, Property: string, Goal: any,
                      Duration: number?, EasingStyle: Enum.EasingStyle?,
                      EasingDirection: Enum.EasingDirection?, Repeats: number?,
                      Reverse: boolean?, Delay: number?)
    Duration = Duration or 1
    EasingStyle = EasingStyle or Enum.EasingStyle.Linear
    EasingDirection = EasingDirection or Enum.EasingDirection.Out
    Repeats = Repeats or 0
    Reverse = Reverse or false
    Delay = Delay or 0

    local Char = self:GetCharacter()
    Target = Target or self:GetRoot()

    if not Target then return end
    local Info = TweenInfo.new(Duration, EasingStyle, EasingDirection, Repeats, Reverse, Delay)
    local Tween = TweenService:Create(Target, Info, {[Property] = Goal})
    Tween:Play()

    return Tween
end

function API:GetTools()
    local Tools = {}
    
    for _, tool in ipairs(self:GetBackpack():GetChildren()) do
        if tool:IsA("Tool") then
            table_insert(Tools, tool)
        end
    end
    
    local Char = self:GetCharacter()
    if Char then
        for _, tool in ipairs(Char:GetChildren()) do
            if tool:IsA("Tool") then
                table_insert(Tools, tool)
            end
        end
    end
    
    return Tools
end

function API:GetToolCount()
    return #self:GetTools()
end

function API:FindTool(Name)
    local Lower = string_lower(Name)
    for _, Tool in ipairs(self:GetTools()) do
        if string_lower(Tool.Name) == Lower then
            return Tool
        end
    end
    return nil
end

function API:EquipTool(Name)
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end

    local Character = self:GetCharacter()
    local Backpack = self:GetBackpack()
    if not Character or not Backpack then return false end

    local HeldTool = self:GetHeldTool()

    if HeldTool and HeldTool.Name == Name then
        return true
    end

    if HeldTool then
        HeldTool.Parent = Backpack
    end

    if Tool.Parent == Backpack then
        Tool.Parent = Character
        return true
    end

    return false
end

function API:UnequipTool(Name)
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end
    
    if Tool.Parent == self:GetCharacter() then
        Tool.Parent = self:GetBackpack()
        return true
    end
    
    return false
end

function API:UseTool(Name)
    local Tool = self:FindTool(Name)
    if not Tool then
        return false
    end

    local HeldTool = self:GetHeldTool()

    if HeldTool ~= Tool then
        self:EquipTool(Name)
        task_wait(0.1)
    end

    HeldTool = self:GetHeldTool()

    if HeldTool == Tool then
        HeldTool:Activate()
        return true
    end

    return false
end

function API:UseHeldTool()
    local HeldTool = self:GetHeldTool()
    if not HeldTool then return false end

    if HeldTool.Enabled ~= false then
        HeldTool:Activate()
        return true
    end

    return false
end

function API:GetHeldTool()
    local Char = self:GetCharacter()
    if Char then
        return Char:FindFirstChildWhichIsA("Tool")
    end
    return nil
end

function API:AddPriority(Name, Priority, Condition, Action)
    self.Priorities = self.Priorities or {}

    table_insert(self.Priorities, {
        Name = Name,
        Priority = Priority,
        Condition = Condition,
        Action = Action,
        Flags = {}
    })
    
    table_sort(self.Priorities, function(a, b)
        return a.Priority > b.Priority
    end)
end

function API:GetTasks()
    for _, Task in ipairs(self.Priorities) do
        if Task.Condition() then
            return Task
        end
    end
    return nil
end

function API:Once(Name, Callback)
    local Selected = self.TaskOnce
    if not Selected then
        Callback()
        return
    end
    
    if not Selected.Flags[Name] then
        Selected.Flags[Name] = true
        Callback()
    end
end

function API:RunTasks()
    local Task = self:GetTasks()
    if Task then
        self.TaskOnce = Task

        Task.Action()

        self.TaskOnce = nil
        return Task.name
    end
    return nil
end

function API:Press(Key)
    VirtualInputManager:SendKeyEvent(true, Key, false, Game)
end

function API:Unpress(Key)
    VirtualInputManager:SendKeyEvent(false, Key, false, Game)
end

function API:Click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, Game, 0)
    task_wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, Game, 0)
end

function API:AntiAFK()
    if global.AFK_Service then return end

    if GetConnections then
        for _, Con in pairs(GetConnections(LocalPlayer.Idled)) do
            if Con.Disable then Con:Disable();
            elseif Con.Disconnect then
                Con:Disconnect();
            end
        end
    else
        LocalPlayer.Idled:Connect(function()
            self:Press(Enum.KeyCode.F5)
            task_wait(0.05)
            self:Unpress(Enum.KeyCode.F5)
        end)
    end

    global.AFK_Service = true
end

function API:SetTime(Amount)
    LightingService.ClockTime = Amount
end

function API:SetFOV(Num)
    CurrentCamera.FieldOfView = Num
end

function API:SetCameraType(Type)
    CurrentCamera.CameraType = Type
end

function API:SetGravity(Amount)
    Workspace.Gravity = Amount
end

function API:SetCameraOcclusion(Mode)
    local Plr = self:GetPlayer()
    if Plr then
        if Mode == "Invisicam" then
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        elseif Mode == "Zoom" then
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        else
            Plr.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Off
        end
    end
end

function API:Zoom(Amount)
    local Plr = self:GetPlayer()
    if Plr then
        Plr.CameraMinZoomDistance = Amount
        Plr.CameraMaxZoomDistance = Amount
    end
end

function API:ThirdPerson(Enabled)
    local Plr = self:GetPlayer()
    if Plr then
        Plr.CameraMode = Enabled and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
    end
end

function API:GetControlModule()
    if self.ControlModule then
        return self.ControlModule
    end
    
    local Scripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if not Scripts then return nil end
    
    local Module = PlayerScripts:FindFirstChild("PlayerModule")
    if not Module then return nil end
    
    local ControlModule = Module:FindFirstChild("ControlModule")
    if not ControlModule then return nil end

    self.ControlModule = require(ControlModule)
    return self.ControlModule
end

function API:PurchasePrompts(State)
    local Prompt = CoreGui:FindFirstChild("PurchasePromptApp")
    if Prompt then
        Prompt.Enabled = State
    end
end

function API:SetSpeed(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.WalkSpeed = Amount
    end
end

function API:SetJumpPower(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.JumpPower = Amount
    end
end

function API:SetHipHeight(Amount)
    local Hum = self:GetHumanoid()
    if Hum then
        Hum.HipHeight = Amount
    end
end

function API:BypassWS(State, Speed)
    State = State or false
    Speed = Speed or 5
    
    self.WSData = self.WSData or {
        Active = false,
        Running = false,
        Speed = Speed,
    }
    
    local function CleanUP()
        self.WSData.Active = false
        self.WSData.Running = false

		self:_Disconnect("@TPWalk")
    end

    if not State then
        CleanUP()
        return false
    end
    
    if self.WSData.Active then
        return true
    end
    
    self.WSData.Active = true
    self.WSData.Running = true
    self.WSData.Speed = Speed
    
    local Connection = Heartbeat:Connect(function()
        if not self.WSData.Running then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end
        
        local delta = Heartbeat:Wait()
        local moveDir = Humanoid.MoveDirection
        
        local Roots = self:GetRoot()
        if not Roots then return end
        
        if moveDir.Magnitude > 0 then
            Roots.CFrame = Roots.CFrame + (moveDir * self.WSData.Speed * delta * self.WSData.Speed)
        else
            Roots.CFrame = Roots.CFrame + (moveDir * delta * self.WSData.Speed)
        end
    end)

    self:_Connect("@TPWalk", Connection)
    return true
end

function API:SetBypassedWS(Speed)
    if not self.WSData or not self.WSData.Active then
        return false
    end
    
    self.WSData.Speed = Speed
    return true
end

function API:BypassJP(State, Amount)
    State = State or false
    Amount = Amount or 20
    
    self.JPData = self.JPData or {
        Active = false,
        Running = false,
        Amount = Amount,
    }
    
    local function CleanUP()
        self.JPData.Active = false
        self.JPData.Running = false
        
		self:_Disconnect("@TPJump")
    end
    
    if not State then
        CleanUP()
        return false
    end
    
    if self.JPData.Active then
        return true
    end
    
    self.JPData.Active = true
    self.JPData.Running = true
    self.JPData.Amount = Amount
    
    local Connection = Heartbeat:Connect(function()
        if not self.JPData.Running then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end
        
        local Roots = self:GetRoot()
        if not Roots then return end
        
        if Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
            Roots.CFrame = Roots.CFrame * CFrame_new(0, self.JPData.Amount, 0)
        end
    end)

    self:_Connect("@TPJump", Connection)
    return true
end

function API:SetBypassedJP(Amount)
    if not self.JPData or not self.JPData.Active then
        return false
    end
    
    self.JPData.Amount = Amount
    return true
end

function API:BringTools(Radius, Interval, BatchSize, Paths)
    Radius = Radius or math_huge
    Interval = Interval or 0.5
    BatchSize = BatchSize or math_huge
    Paths = Paths or {workspace}

    if not Paths then
        Paths = {workspace}
    elseif type(Paths) ~= "table" then
        Paths = {Paths}
    end

    if self.Tools_Connection then
        self:_Disconnect("@BringTools")
        self.Tools_Connection = nil
    end

    self.BroughtTools = self.BroughtTools or {}
    self.ToolsActive = true
    self.ToolsRadius = Radius
    self.ToolsBatchSize = BatchSize
    self.ToolsPaths = Paths
    
    local Elapsed = 0
    
    local function Tools_Task()
        if not self.ToolsActive then return end
        
        local Humanoid = self:GetHumanoid()
        if not Humanoid then return end

        local Tools = {}

        for _, v in ipairs(self.ToolsPaths) do
            if v and v:IsA("Instance") then
                for _, v in ipairs(v:GetChildren()) do
                    if v:IsA("BackpackItem") and v:FindFirstChild("Handle") then
                        if not self.BroughtTools[v] then
                            local Distance = self:GetDistance(v)
                            if Distance <= self.ToolsRadius then
                                table_insert(Tools, v)
                            end
                        end
                    end
                end
            end
        end
        
        for i = 1, math_min(BatchSize, #Tools) do
            local v = Tools[i]
            if v and v.Parent then
                Humanoid:EquipTool(v)
                self.BroughtTools[v] = true
            end
        end
          
        for v, _ in pairs(self.BroughtTools) do
            if not v or not v.Parent then
                self.BroughtTools[v] = nil
            end
        end
    end

    self.Tools_Connection = Heartbeat:Connect(function(deltaTime)
        if not self.ToolsActive then return end

        Elapsed = Elapsed + deltaTime
        if Elapsed >= Interval then 
            Elapsed = 0
            Tools_Task()
        end
    end)
    
    self:_Connect("@BringTools", self.Tools_Connection)
    return true
end

function API:StopBringTools()
    self.ToolsActive = false
    self:_Disconnect("@BringTools")
    self.Tools_Connection = nil
    self.BroughtTools = {}
    return true
end

function API:AntiCollider(State)
    if State then
        if self.AntiCollide then return true end
        self.AntiCollide = true
        
        local LocalPlayer = self:GetPlayer()
        if not LocalPlayer then return false end
        
        self.AntiColliderOrigin = {}
        
        local function DontCollide(Part)
            if not Part or not Part:IsA("BasePart") then return end
            
            if self.AntiColliderOrigin[Part] == nil then
                self.AntiColliderOrigin[Part] = Part.CanCollide
            end
            Part.CanCollide = false
        end

        local function HandleCharacter(Character)
            if not Character then return end
            
            for _, Part in pairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    DontCollide(Part)
                end
            end
            
            local Added_Connection = Character.DescendantAdded:Connect(function(inst)
                if inst:IsA("BasePart") then DontCollide(inst) end
            end)

            local Removed_Connection = Character.DescendantRemoving:Connect(function(inst)
                if inst:IsA("BasePart") and self.AntiColliderOrigin[inst] then
                    self.AntiColliderOrigin[inst] = nil
                end
            end)

            self:_Connect("@AntiCollider_Added: " .. tostring(Character), Added_Connection)
            self:_Connect("@AntiCollider_Removed: " .. tostring(Character), Removed_Connection)
        end

        for _, Plr in pairs(self:GetPlayers(true)) do
            if Plr ~= LocalPlayer and Plr.Character then
                HandleCharacter(Plr.Character)
            end
        end
        
        self:_Connect("@AntiCollider_Players", Players.PlayerAdded:Connect(function(Plr)
            if Plr ~= LocalPlayer and Plr.Character then
                HandleCharacter(Plr.Character)
            end
        end))

        self:_Connect("@AntiCollider", Heartbeat:Connect(function()
            if not self.AntiCollide then return end
            
            for Part, _ in pairs(self.AntiColliderOrigin) do
                if Part and Part.Parent and Part:IsA("BasePart") and Part.CanCollide ~= false then
                    Part.CanCollide = false
                end
            end
        end))
        
        return true
    else
        if not self.AntiCollide then return false end

        for Part, Original in pairs(self.AntiColliderOrigin or {}) do
            if Part and Part.Parent then
                pcall(function() Part.CanCollide = Original end)
            end
        end

        self:_Disconnect("@AntiCollider_Players")
        self:_Disconnect("@AntiCollider")

        for Name, _ in pairs(self._Signal or {}) do
            if type(Name) == "string" and (Name:match("@AntiCollider_Added: ") or Name:match("@AntiCollider_Removed: ")) then
                self:_Disconnect(Name)
            end
        end

        self.AntiCollide = nil
        self.AntiColliderOrigin = nil
        return true
    end
end

function API:Strengthen(State, Density)
    Density = Density or 100
    Density = math_clamp(Density, 0.01, 100)
    
    local Character = self:GetCharacter()
    if not Character then return false end
    
    if not self.Strengthened then self.Strengthened = false end
    
    if State and self.Strengthened == true then return true end
    if not State and self.Strengthened == false then return true end

    local function PhysicalPropertiesV(Char, Dense, DensValue)
        local Parts = Char:GetDescendants()
        if Dense then
            for i = 1, #Parts do
                if Parts[i]:IsA("BasePart") then
                    pcall(function()
                        Parts[i].CustomPhysicalProperties = PhysicalProperties.new(DensValue, 0.3, 0.5)
                    end)
                end
            end
        else
            for i = 1, #Parts do
                if Parts[i]:IsA("BasePart") then
                    pcall(function()
                        Parts[i].CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                    end)
                end
            end
        end
    end

    if State then
        PhysicalPropertiesV(Character, true, Density)
        self.Strengthened = true
        self.StrengthenDensity = Density
        
        if self.StrengthenListener then
            self:_Disconnect("@StrengthListener")
            self.StrengthenListener = nil
        end
        
        self.StrengthenListener = LocalPlayer.CharacterAdded:Connect(function(NewChar)
            task_wait(0.5);
            PhysicalPropertiesV(NewChar, true, self.StrengthenDensity or Density)
        end)
        self:_Connect("@StrengthListener", self.StrengthenListener)
    else
        PhysicalPropertiesV(Character, false)
        self.Strengthened = false
        self.StrengthenDensity = nil
        
        if self.StrengthenListener then
            self:_Disconnect("@StrengthListener")
            self.StrengthenListener = nil
        end
    end

    return true
end

function API:FlightConfig(Config)
    if not self.FlightData then
        self.FlightData = {Active = false}
    end
    
    self.FlightData.SpeedMin = Config.SpeedMin or self.FlightData.SpeedMin or 10
    self.FlightData.SpeedMax = Config.SpeedMax or self.FlightData.SpeedMax or 250
    self.FlightData.SpeedStep = Config.SpeedStep or self.FlightData.SpeedStep or 1.5
    
    if self.FlightData.Active then
        self.FlightData.Speed = math_clamp(self.FlightData.Speed, 
            self.FlightData.SpeedMin, 
            self.FlightData.SpeedMax)
    end
    
    return true
end

function API:Flight(State, Speed)
    State = State or false
    Speed = Speed or 50

    self.FlightData = self.FlightData or 
    {Active = false, Speed = Speed, BodyVelocity = nil, BodyGyro = nil, SpeedStep = 1.5, SpeedMin = 10, SpeedMax = 250}

    local function CleanUP()
        self.FlightData.Active = false
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity:Destroy()
        end
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro:Destroy()
        end

		self:_Disconnect("@Flight")
    end
    
    if not State then
        CleanUP()
        return false
    end
    
    if self.FlightData.Active then
        return true
    end

    local Roots = self:GetRoot()

    if not Roots then
        return false
    end
    
    self.FlightData.Active = true
    self.FlightData.Speed = math_clamp(Speed, self.FlightData.SpeedMin, self.FlightData.SpeedMax)
    
	local Strength = 1e9

    local BV = self:CreateInstance("BodyVelocity", {
        Name = "00x00x00x00x00",
        MaxForce = Vector3_new(Strength, Strength, Strength),
        Velocity = Vector3_zero,
        Parent = Roots
    })
    self.FlightData.BodyVelocity = BV
    
    local BG = self:CreateInstance("BodyGyro", {
        Name = "11x11x11x11x11",
        MaxTorque = Vector3_new(Strength, Strength, Strength),
        P = 3000,
        D = 500,
        CFrame = Roots.CFrame,
        Parent = Roots
    })
    self.FlightData.BodyGyro = BG
    
    local Camera = CurrentCamera
    local ControlModule = self:IsMobile() and self:GetControlModule() or nil

    local Connection = RenderStepped:Connect(function()
        local Roots = self:GetRoot()
        if not self.FlightData.Active or not Roots or not Camera then 
            return 
        end
        
        if self.FlightData.BodyVelocity and self.FlightData.BodyVelocity.Parent ~= Roots then
            self.FlightData.BodyVelocity.Parent = Roots
        end
        if self.FlightData.BodyGyro and self.FlightData.BodyGyro.Parent ~= Roots then
            self.FlightData.BodyGyro.Parent = Roots
        end
        
        local MoveDirection = Vector3_zero
    
        if ControlModule then
            local Direction = ControlModule:GetMoveVector()
            MoveDirection = (Camera.CFrame.RightVector * Direction.X) + (Camera.CFrame.LookVector * -Direction.Z)
    
            if MoveDirection.Magnitude > 0 then
                MoveDirection = MoveDirection.Unit * self.FlightData.Speed
            end
        else
            if IsKeyDown(UserInputService, Enum.KeyCode.W) then
                MoveDirection += Camera.CFrame.LookVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.S) then
                MoveDirection -= Camera.CFrame.LookVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.A) then
                MoveDirection -= Camera.CFrame.RightVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.D) then
                MoveDirection += Camera.CFrame.RightVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.Space) then
                MoveDirection += Camera.CFrame.UpVector
            end
            if IsKeyDown(UserInputService, Enum.KeyCode.LeftControl) then
                MoveDirection -= Camera.CFrame.UpVector
            end
            
            if MoveDirection.Magnitude > 0 then
                MoveDirection = MoveDirection.Unit * self.FlightData.Speed
            end
        end

        if IsKeyDown(UserInputService, Enum.KeyCode.Equals) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed + self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        elseif IsKeyDown(UserInputService, Enum.KeyCode.Minus) then
            self.FlightData.Speed = math_clamp(self.FlightData.Speed - self.FlightData.SpeedStep, 
                self.FlightData.SpeedMin, self.FlightData.SpeedMax)
        end
        
        if self.FlightData.BodyVelocity then
            self.FlightData.BodyVelocity.Velocity = MoveDirection
        end
        
        if self.FlightData.BodyGyro then
            self.FlightData.BodyGyro.CFrame = Camera.CFrame
        end
    end)

    self:_Connect("@Flight", Connection)
    return true
end

function API:InfiniteJump(State)
    State = State or false

    self.JumpData = self.JumpData or {
        Active = false,
        Debounce = false,
    }
    
    local function CleanUP()
        self.JumpData.Active = false
        self.JumpData.Debounce = false

		self:_Disconnect("@InfiniteJump")
    end
    
    if not State then
        CleanUP()
        return false
    end
    
    if self.JumpData.Active then
        return true
    end
    
    self.JumpData.Active = true
    
    local Connection = UserInputService.JumpRequest:Connect(function()
        if not self.JumpData.Debounce then
            self.JumpData.Debounce = true
            
            local Humanoid = self:GetHumanoid()
            if Humanoid then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            task_wait(0.1)
            self.JumpData.Debounce = false
        end
    end)

    self:_Connect("@InfiniteJump", Connection)
    return true
end

function API:TouchFling(State)
    State = State or false
    
    self.FlingData = self.FlingData or {
        Active = false,
        Running = false,
    }
    
    local function CleanUP()
        self.FlingData.Active = false
        self.FlingData.Running = false
        
		self:_Disconnect("@TouchFling")
    end
    
    if not State then
        CleanUP()
        return false
    end

    if self.FlingData.Active then
        return true
    end
    
    self.FlingData.Active = true
    self.FlingData.Running = true

    local movel = 0.1

    local Connection = Heartbeat:Connect(function()
        if not self.FlingData.Running then return end
        
        local Roots = self:GetRoot()
        if not Roots then return end
    
        local vel = Roots.Velocity
        Roots.Velocity = vel * 10000 + Vector3_new(0, 10000, 0)
        RenderStepped:Wait()
        Roots.Velocity = vel
        Stepped:Wait()
        Roots.Velocity = vel + Vector3_new(0, movel, 0)
        
        movel = -movel
    end)

    self:_Connect("@TouchFling", Connection)
    return true
end

function API:XRay(State)
    if State then
        if self.XRayEnabled then return end

        self.XRayEnabled = true
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChildWhichIsA("Humanoid") and not v.Parent.Parent:FindFirstChildWhichIsA("Humanoid") then
                v.LocalTransparencyModifier = 0.5
            end
        end
    else
        if not self.XRayEnabled then return end
        
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0
            end
        end
        self.XRayEnabled = false
    end
end

function API:AntiFling()
    if self.FlingActive then return end

	self.FlingActive = true

    local Connection = Heartbeat:Connect(function()
        local Char = self:GetCharacter()
        if not Char then return end

        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if not Hum then return end
        
        if not Hum:FindFirstChild("0x0x0x0x0") then
            self:CreateInstance("BodyVelocity", {
                Name = "0x0x0x0x0",
                Velocity = Vector3_zero,
                MaxForce = Vector3_new(40000, 40000, 40000),
                Parent = Hum
            })
        end

        Hum.Velocity = Vector3_zero
        Hum.AssemblyLinearVelocity = Vector3_zero
        
        local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
        if AntiFling then
            AntiFling.Velocity = Vector3_zero
        end
    end)

	self:_Connect("@AntiFling", Connection)
end

function API:StopFling()
    if not self.FlingActive then return end

    self.FlingActive = false
    self:_Disconnect("@AntiFling")

    local Char = self:GetCharacter()
    if Char then
        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if Hum then
            local AntiFling = Hum:FindFirstChild("0x0x0x0x0")
            if AntiFling then
                AntiFling:Destroy()
            end
        end
    end
end

function API:Noclip(Duration)    
    self.NoclipActive = true
    self.NoclipTimeout = os_clock() + (Duration or 0.45)

    if not self.Origins then
        self.Origins = {}
    end

    if not self.NoclipConnection then
        self.NoclipConnection = Heartbeat:Connect(function()
            local Character = self:GetCharacter()

            if not Character or os_clock() >= self.NoclipTimeout then
                self:StopClip()
                return
            end

            for _, v in pairs(Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    if self.Origins[v] == nil then
                        self.Origins[v] = v.CanCollide
                    end
                    v.CanCollide = false
                end
            end
        end)
    end
end

function API:StopClip()
    if self.NoclipConnection then
        self.NoclipConnection:Disconnect()
        self.NoclipConnection = nil
    end
    
    self.NoclipActive = false

    local Character = self:GetCharacter()
    if Character and self.Origins then
        for v, Original in pairs(self.Origins) do
            if v and v.Parent then
                v.CanCollide = Original
            end
        end
    end
    
    self.Origins = {}
    self.NoclipTimeout = nil
end

function API:IsStudio()
    return RunService:IsStudio()
end

function API:GetScreenSize()
    return CurrentCamera and CurrentCamera.ViewportSize or Vector2_new(0, 0)
end

function API:GetMousePosition()
    return GetMouseLocation(UserInputService)
end

function API:GetMouse()
    return self:GetPlayer():GetMouse()
end

function API:SetMouseIcon(Icon)
    local Plr = self:GetPlayer()
    Plr.MouseIcon = Icon
end

function API:MouseVisibility(State)
    UserInputService.MouseIconEnabled = not State
end

function API:IsKeyPressed(Key)
    return IsKeyDown(UserInputService, Key)
end

function API:IsShiftLocked()
    return UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
end

function API:GetFriends()
    local LocalPlayer = self:GetPlayer()
    if not LocalPlayer then return {} end

    local UserId = LocalPlayer.UserId
    local Success, Response = pcall(function()
        return HttpGet("https://friends.roblox.com/v1/users/" .. UserId .. "/friends")
    end)
    
    if not Success then return {} end
    
    local Data = HttpService:JSONDecode(Response)
    if not Data or not Data.data then return {} end
    
    local Friends = {}
    
    for _, Friend in pairs(Data.data) do
        local Success, Response = pcall(function()
            return Game:HttpGet("https://users.roblox.com/v1/users/" .. Friend.id)
        end)
        
        if Success then
            local UserData = HttpService:JSONDecode(Response)
            if UserData and UserData.name then
                table_insert(Friends, {
                    UserId = Friend.id,
                    Name = UserData.name,
                    DisplayName = UserData.displayName or UserData.name
                })
            end
        end
        task_wait(0.1);
    end

    return Friends
end

function API:Raycast(Origin, Direction, Distance, IgnoreList, FilterType, IgnoreWater, Callback)
    local Origins = self:ResolvePosition(Origin)
    if not Origins then return nil end

    local Dir = Direction
    if type(Direction) ~= "Vector3" then
        Dir = self:ResolvePosition(Direction)
        if not Dir then return nil end
    end

    local Params = RaycastParamsNew()
    Params.FilterType = FilterType or Enum.RaycastFilterType.Blacklist
    Params.FilterDescendantsInstances = IgnoreList or {}
    Params.IgnoreWater = IgnoreWater or false
    
    local Result = WorkspaceRaycast(Workspace, Origins, Dir.Unit * (Distance or 1000), Params)

    if Callback and Result then
        Callback(Result)
    end

    return Result
end

function API:WorldToScreen(Position)
    local Camera = CurrentCamera
    if not Camera then return nil end
    local Vector, OnScreen = Camera:WorldToScreenPoint(self:ResolvePosition(Position))
    if OnScreen then
        return {X = Vector.X, Y = Vector.Y, Z = Vector.Z}, true
    end
    return nil, false
end

function API:GetScreenCenter()
    local Camera = CurrentCamera
    if not Camera then return nil end
    return Vector2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
end

function API:IsBehindWall(Target, Character)
    local Selected = Target
    if typeof(Target) == "Instance" and Target:IsA("Player") then
        Selected = Target.Character
    end

    if not Selected then return true end

    Character = Character or self:GetCharacter()
    if not Character then return true end

    local Head = self:GetHead()
    local Parts = Selected:FindFirstChild("Head") or Selected:FindFirstChild("HumanoidRootPart")
    
    if not Head or not Parts then return true end

    local Direction = (Parts.Position - Head.Position)
    local Distance = Direction.Magnitude

    local Result = self:Raycast(Head.Position, Direction, Distance, {Character, Selected})

    if Result and Result.Instance then
        local Hit = Result.Instance:FindFirstAncestorWhichIsA("Model")
        if Hit and Hit ~= Selected then
            return true
        end
    end
    
    return false
end

function API:IsTeamMate(Target)
    return self:GetTeam() == Target.Team
end

function API:GetEnemies()
    local Enemies = {}
    local MyTeam = self:GetTeam()
    
    for _, Player in ipairs(self:GetPlayers()) do
        if Player.Team ~= MyTeam then
            table_insert(Enemies, Player)
        end
    end
    
    return Enemies
end

function API:LookAt(Target, Part)
    local T = self:ResolvePosition(Target)
    local P = Part or self:GetRoot()
    
    if P and T then
        P.CFrame = CFrame_lookAt(P.Position, T)
    end
end

function API:CreateHighlight(Target, Options)
    if not Target then return nil end

    Options = Options or {}
    self.HighlightCache = self.HighlightCache or {}

    if self.HighlightCache[Target] then
        return self.HighlightCache[Target]
    end

    local Highlight = self:CreateInstance("Highlight", {
        Name = Options.Name or self:RandomString(15),
        Adornee = Target,
        Enabled = Options.Enabled ~= false,
        FillColor = Options.FillColor or Color3_fromRGB(255, 0, 0),
        OutlineColor = Options.OutlineColor or Color3_fromRGB(255, 255, 255),
        FillTransparency = Options.FillTransparency or 0.5,
        OutlineTransparency = Options.OutlineTransparency or 0,
        DepthMode = Options.DepthMode or Enum.HighlightDepthMode.AlwaysOnTop,
        Parent = Options.Parent or Target
    })

    self.HighlightCache[Target] = Highlight
    local Preload = "@Highlight_" .. tostring(Target)

    local Connection = Target.AncestryChanged:Connect(function()
        if not Target:IsDescendantOf(Game) then
            self:RemoveHighlight(Target)
        end
    end)

    self:_Connect(Preload, Connection)
    return Highlight
end

function API:RemoveHighlight(Target)
    self.HighlightCache = self.HighlightCache or {}

    local Highlight = self.HighlightCache[Target]
    if not Highlight then return false end

    self:_Disconnect("@Highlight_" .. tostring(Target))

    if Highlight and Highlight.Destroy then
        Highlight:Destroy()
    end

    self.HighlightCache[Target] = nil
    return true
end

function API:ClearHighlights()
    self.HighlightCache = self.HighlightCache or {}

    for Target, Highlight in pairs(self.HighlightCache) do
        self:_Disconnect("@Highlight_" .. tostring(Target))

        if Highlight and Highlight.Destroy then
            pcall(function()
                Highlight:Destroy()
            end)
        end
    end

    table_clear(self.HighlightCache)
end

function API:GetPlayers(SelfIncluded)
    local List = {}

    for _, Plr in pairs(Players:GetPlayers()) do
        if SelfIncluded then
            table_insert(List, Plr)
        else
            if Plr ~= Players.LocalPlayer then
                table_insert(List, Plr)
            end
        end
    end

    return List
end

function API:GetVelocity()
    local Root = self:GetRoot()
    if not Root then return Vector3_zero end

    return Root.Velocity
end

function API:GetDistance(Target, UseSquared)
    local Roots = self:GetRoot()
    if not Roots or not Target then return math_huge end

    local Pos = self:ResolvePosition(Target)
    
    if not Pos then
        return math_huge
    end

    local Root = Roots.Position
    local dx = Root.X - Pos.X
    local dy = Root.Y - Pos.Y
    local dz = Root.Z - Pos.Z

    if UseSquared then
        return dx*dx + dy*dy + dz*dz
    end

    return math_sqrt(dx*dx + dy*dy + dz*dz)
end

function API:GetBoundingBox(Model)
    if not Model or not Model:IsA("Model") then return nil end
    
    local Parts = {}
    for _, Part in ipairs(Model:GetDescendants()) do
        if Part:IsA("BasePart") then
            table_insert(Parts, Part)
        end
    end
    
    if #Parts == 0 then return nil end
    
    local MinX, MinY, MinZ = math_huge, math_huge, math_huge
    local MaxX, MaxY, MaxZ = -math_huge, -math_huge, -math_huge
    
    for _, Part in ipairs(Parts) do
        local Pos = Part.Position
        local Size = Part.Size / 2
        
        MinX = math_min(MinX, Pos.X - Size.X)
        MinY = math_min(MinY, Pos.Y - Size.Y)
        MinZ = math_min(MinZ, Pos.Z - Size.Z)
        MaxX = math_max(MaxX, Pos.X + Size.X)
        MaxY = math_max(MaxY, Pos.Y + Size.Y)
        MaxZ = math_max(MaxZ, Pos.Z + Size.Z)
    end
    
    local Center = Vector3_new((MinX + MaxX) / 2, (MinY + MaxY) / 2, (MinZ + MaxZ) / 2)
    local Size = Vector3_new(MaxX - MinX, MaxY - MinY, MaxZ - MinZ)
    
    return Center, Size
end

function API:IsNPC(Model)
    if typeof(Model) ~= "Instance" or not Model:IsA("Model") then
        return false
    end

    if Players:GetPlayerFromCharacter(Model) then
        return false
    end

    return Model:FindFirstChildWhichIsA("Humanoid", true) ~= nil
end

function API:IsAliveTarget(Character)
    Character = Character or self:GetCharacter()
    if not Character then return false end

    local Hum = Character:FindFirstChild("Humanoid")
    return Hum and Hum.Health > 0
end

function API:GetHealthPercent(Target)
    local Character = Target.Character or Target
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return 0 end

    return (Humanoid.Health / Humanoid.MaxHealth) * 100
end

function API:CalculateSpeed(Unit, DecimalPlaces)
    Unit = Unit or "KPH"
    DecimalPlaces = DecimalPlaces or 1
    local Velocity = self:GetVelocity()
    local StudsPS = Velocity.Magnitude
    
    local Result
    if Unit == "KPH" then
        Result = StudsPS * 1.008
    elseif Unit == "MPH" then
        Result = StudsPS * 0.626 
    elseif Unit == "MPS" then
        Result = StudsPS * 0.28
    elseif Unit == "Studs" then
        Result = StudsPS
    elseif Unit == "Mach" then
        Result = (StudsPS * 0.28) / 343
    elseif Unit == "Light" then
        Result = (StudsPS * 0.28) / 299792458  -- // Fraction of light speed
    else
        Result = StudsPS
    end
    
    local Multiplier = 10 ^ DecimalPlaces
    return math_floor(Result * Multiplier + 0.5) / Multiplier
end

function API:IsMoving(Character)
    Character = Character or self:GetCharacter()
    if not Character then return false end

    if not self:IsAliveTarget(Character) then return false end
    
    local Hum = Character:FindFirstChild("Humanoid")
    return Hum and Hum.MoveDirection.Magnitude > 0 or false
end

function API:GetClosestNPC(Radius)
    Radius = Radius or math_huge
    local Closest = nil
    local ClosestDistSquared = Radius * Radius

    local Models = self:GetDescendants(Workspace, "Model", 500)

    for i = 1, #Models do
        local Model = Models[i]
        if self:IsNPC(Model) then
            local DistanceSquared = self:GetDistance(Model, true)
            if DistanceSquared < ClosestDistSquared then
                ClosestDistSquared = DistanceSquared
                Closest = Model
            end
        end
    end

    if Closest then
        return self:GetNPC(Closest), math_sqrt(ClosestDistSquared)
    end
    return nil, ClosestDistSquared
end

function API:GetClosestPlayer(Radius)
    Radius = Radius or math_huge
    local Closest = nil
    local ClosestDistSquared = Radius * Radius

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local DistanceSquared = self:GetDistance(v.Character, true)
            if DistanceSquared < ClosestDistSquared then
                ClosestDistSquared = DistanceSquared
                Closest = v
            end
        end
    end
    
    if Closest then
        return Closest, math_sqrt(ClosestDistSquared)
    end
    return Closest, ClosestDistSquared
end

function API:GetFarthestPlayer(Radius)
    Radius = Radius or math_huge
    local Farthest, FarthestDistSquared = nil, 0

    for _, v in ipairs(self:GetPlayers(false)) do
        if v.Character then
            local DistanceSquared = self:GetDistance(v.Character, true)
            if DistanceSquared > FarthestDistSquared and DistanceSquared <= (Radius * Radius) then
                FarthestDistSquared = DistanceSquared
                Farthest = v
            end
        end
    end
    
    if Farthest then
        return Farthest, math_sqrt(FarthestDistSquared)
    end
    return nil, 0
end

function API:HasAccessory(Character, Accessories, MinMatches)
    if not Character then return false end
    MinMatches = MinMatches or 1

    local Count = 0
    for _, Accessory in ipairs(Character:GetChildren()) do
        if Accessory:IsA("Accessory") then
            local AccessoryNameLower = string_lower(Accessory.Name)
            for _, Name in ipairs(Accessories) do
                local NameLower = string_lower(Name)
                if AccessoryNameLower:find(NameLower) then
                    Count = Count + 1
                    if Count >= MinMatches then 
                        return true 
                    end
                end
            end
        end
    end
    return false
end

function API:Search(Input)
    if type(Input) ~= "string" then return nil end

    local InputLower = string_lower(Input)
    local Players = self:GetPlayers(true)
    local LocalPlayer = self:GetPlayer()
    
    if InputLower == "random" then
        return Players[math_random(1, #Players)]
    end

    if InputLower == "nearest" then
        local Closest, _ = self:GetClosestPlayer()
        return Closest
    end

    if InputLower == "farthest" then
        local Farthest, _ = self:GetFarthestPlayer()
        return Farthest
    end

    if InputLower == "closestnpc" then
        local Closest, _ = self:GetClosestNPC()
        return Closest
    end

    if InputLower == "bacons" then
        local Bacons = {}
        for _, Player in ipairs(Players) do
            if self:HasAccessory(Player.Character, {"Pal Hair", "Kate Hair"}, 1) then
                table_insert(Bacons, Player)
            end
        end
        if #Bacons > 0 then
            return Bacons[math_random(1, #Bacons)]
        end
        return nil
    end

    if InputLower == "furries" then
        local Furries = {}
        for _, Player in ipairs(Players) do
            if self:HasAccessory(Player.Character, {"Tail", "Ears", "Horns", "Antlers", "Collar", 
                "Chain", "Leash", "Bunny", "Wolf", "Fox", "Cat", "Dog", "Dragon", "Demon", "Kitsune", "Neko", "Kemono", "Feline", 
                "Canine", "Paws", "Claws", "Whiskers", "Muzzle", "Snout", "Beast", "Shark", "Creature", "Animal", "Pet", "Fluff",
                "Mane", "Feathers", "Wings", "Scales", "Fins", "Gills", "Hooves", "Paw", "Furry", "Anthro"
            }, 2) then
                table_insert(Furries, Player)
            end
        end
        if #Furries > 0 then
            return Furries[math_random(1, #Furries)]
        end
        return nil
    end

    if InputLower == "friends" then
        local Friends = {}
        for _, Player in ipairs(Players) do
            if Player ~= LocalPlayer and self:IsAFriend(Player) then
                table_insert(Friends, Player)
            end
        end
        if #Friends > 0 then
            return Friends[math_random(1, #Friends)]
        end
        return nil
    end

    if InputLower == "nonfriends" then
        local NonFriends = {}
        for _, Player in ipairs(Players) do
            if Player ~= LocalPlayer and not self:IsAFriend(Player) then
                table_insert(NonFriends, Player)
            end
        end
        if #NonFriends > 0 then
            return NonFriends[math_random(1, #NonFriends)]
        end
        return nil
    end

    local Matches = table_create(#Players)
    local idx = 0
    for i = 1, #Players do
        local Player = Players[i]
        local Lower_Name = string_lower(Player.Name)
        local Lower_Display = string_lower(Player.DisplayName)

        if Lower_Name == InputLower or Lower_Display == InputLower then
            return Player
        end

        if Lower_Name:find(InputLower, 1, true) or Lower_Display:find(InputLower, 1, true) then
            idx = idx + 1
            Matches[idx] = Player
        end
    end
    
    if idx > 0 then
        return Matches[1]
    end
    
    return nil
end

function API:GetNPC(Model)
    if not Model or not Model:IsA("Model") then
        return nil
    end

    local Hum = Model:FindFirstChildOfClass("Humanoid")
    local Roots = Model:FindFirstChild("HumanoidRootPart")

    if not Hum or not Roots then return nil end

    local Status = {
        Model = Model,
        Humanoid = Hum,
        Root = Roots,
        TeleportRules = nil,

        Attributes = Model:GetAttributes()
    }

    function Status:Override(Name, Func)
        local Original = self[Name]

        if typeof(Original) ~= "function" then
            return false
        end

        self[self:RandomString(15)] = Original
        self[Name] = Func
        return true
    end

    function Status:GetAttribute(Name)
        return self.Model:GetAttribute(Name)
    end

    function Status:IsAlive()
        return self.Humanoid.Health > 0
    end

    function Status:GetHealth()
        return self.Humanoid.Health
    end

    function Status:GetMaxHealth()
        return self.Humanoid.MaxHealth
    end

    function Status:GetPosition()
        return self.Root.Position
    end

    function Status:GetPivot()
        return self.Model:GetPivot()
    end

    function Status:GetDistance()
        return API:GetDistance(self.Model)
    end

    function Status:IsMoving()
        return self.Humanoid.MoveDirection.Magnitude > 0
    end

    function Status:GetTool()
        for _, v in ipairs(self.Model:GetChildren()) do
            if v:IsA("Tool") then
                return v
            end
        end
        return nil
    end

    function Status:GetAnimation()
        local Anim = self.Humanoid:FindFirstChildOfClass("Animator")
        if not Anim then return {} end

        local Data = {}

        for _, track in ipairs(Anim:GetPlayingAnimationTracks()) do
            local AnimObj = track.Animation
            local AssetId = AnimObj and AnimObj.AnimationId and tonumber(AnimObj.AnimationId:match("%d+"))
            local AssetInfo = AssetId and self:GetAssetInfo(AssetId)

            Data[#Data + 1] = {
                Name = track.Name,
                Speed = track.Speed,
                TimePosition = track.TimePosition,
                AnimationId = AnimObj and AnimObj.AnimationId,
                
                AssetName = AssetInfo and AssetInfo.Name,
                Creator = AssetInfo and AssetInfo.Creator,
                Type = AssetInfo and AssetInfo.Type,
                Description = AssetInfo and AssetInfo.Description,
            }
        end

        return Data
    end

    function Status:Teleport(Offset)
        local Roots = API:GetRoot()
        if not Roots then return end

		Offset = Offset or Vector3_zero

		if self.CustomTeleport then
            return self.CustomTeleport(self, Roots)
        end

        if self.TeleportRules then
            for _, rule in ipairs(self.TeleportRules) do
                if rule.Condition(self) then
                    return rule.Action(self, Roots)
                end
            end
        end

        Roots.CFrame = self.Root.CFrame + Offset
    end

    return Status
end

function API:Travel(Speed, ...)
    local args = {...}
    if #args < 1 then return end

    local Position = self:ResolvePosition(args[1])
    local LookAt = args[2] and self:ResolvePosition(args[2]) or nil

    local Roots = self:GetRoot();
    if not Roots then return end

    Roots.Velocity = Vector3_zero
    Roots.AssemblyLinearVelocity = Vector3_zero

    local Current = Roots.Position
    local Delta = Position - Current;
    local Distance = Delta.Magnitude
    
    if Distance < 0.05 then return end

    local Num = tonumber(Speed)
    if not Num or Num <= 0 then Num = math_huge end
    local dt = Heartbeat:Wait();

    local Step = math_min(Num * dt, Distance)
    local Direction = (Distance > 0 and Delta.Unit) or Vector3_zero
    local NewPos = Current + Direction * Step;                

    local cf = CFrame_lookAt(NewPos, LookAt or (NewPos + Direction));
    self:GetCharacter():PivotTo(cf);
end

function API:DetectType(Object)
    if not Object then return nil end

    if typeof(Object) == "Instance" and Object:IsA("Player") then
        return Object.Character
    end

    if typeof(Object) == "Instance" and Object:IsA("Model") then
        if Object:FindFirstChildWhichIsA("Humanoid") or Object:FindFirstChildWhichIsA("Humanoid", true) then
            return Object
        end
    end

    if type(Object) == "table" then
        local Resolvers = {
            "Model", "model",
            "Character", "character",
            "Instance", "instance",
            "PrimaryPart", "primaryPart",
            "RootPart", "rootPart", "HumanoidRootPart",
            "Root", "root"
        }

        for _, Resolver in ipairs(Resolvers) do
            if Object[Resolver] then
                return self:DetectType(Object[Resolver])
            end
        end

        if Object.Humanoid or Object.humanoid then
            local hum = Object.Humanoid or Object.humanoid
            if typeof(hum) == "Instance" and hum.Parent then
                return hum.Parent
            end
        end

        for _, v in pairs(Object) do
            if typeof(v) == "Instance" then
                if v:IsA("Model") or v:IsA("BasePart") then
                    return self:DetectType(v)
                end
            end
        end
    end

    if typeof(Object) == "Instance" then
        local Current = Object
        while Current do
            if Current:IsA("Model") then
                if Current:FindFirstChildWhichIsA("Humanoid") or Current:FindFirstChildWhichIsA("Humanoid", true) then
                    return Current
                end
            end
            Current = Current.Parent
        end
    end

    return nil
end

function API:Spectate(Input)
    if self.Spectate_Active then
        self:StopSpectate()
    end

    local Target = nil

    if type(Input) == "string" then
        Target = self:Search(Input)
    elseif typeof(Input) == "Instance" then
        Target = Input
    elseif type(Input) == "table" and Input.Character then
        Target = Input.Character or Input
    end

    if not Target then
        return false
    end

	local LocalPlayer = self:GetPlayer()
    if Target == LocalPlayer or (typeof(Target) == "Instance" and Target == LocalPlayer.Character) then
		return false
    end

    local Model = self:DetectType(Target)
    if not Model then
        return false
    end

    self.Spectate_Target = Model
    self.Spectate_Active = true

    local function Lookat_Camera(Model)
        if not Model or not Model.Parent then return false end

        local Humanoid = Model:FindFirstChildWhichIsA("Humanoid") or Model:FindFirstChildWhichIsA("Humanoid", true)
        local Roots = Model:FindFirstChild("HumanoidRootPart") or Model.PrimaryPart

        if Humanoid then
            CurrentCamera.CameraSubject = Humanoid
            return true
        elseif Roots then
            CurrentCamera.CameraSubject = Roots
            return true
        end
        return false
    end

    Lookat_Camera(Model)

    self.Spectate_AncestryConnection = Model.AncestryChanged:Connect(function()
        if not Model.Parent then
            self:StopSpectate()
        else
            task_delay(0.15, Lookat_Camera, Model)
        end
    end)

    self.Spectate_AddedConnection = Model.ChildAdded:Connect(function(v)
        if v:IsA("Humanoid") then
            task_delay(0.15, Lookat_Camera, Model)
        end
    end)

    return true
end

function API:StopSpectate()
    if not self.Spectate_Active then return end

    if self.Spectate_AncestryConnection then
        self.Spectate_AncestryConnection:Disconnect()
        self.Spectate_AncestryConnection = nil
    end

    if self.Spectate_AddedConnection then
        self.Spectate_AddedConnection:Disconnect()
        self.Spectate_AddedConnection = nil
    end

	local Humanoid = self:GetHumanoid()
    if Humanoid then
        CurrentCamera.CameraSubject = Humanoid
        CurrentCamera.CameraType = Enum.CameraType.Custom
    end

    self.Spectate_Target = nil
    self.Spectate_Active = false
end

function API:IsSpectating()
    return self.Spectate_Active or false
end

function API:GetSpectateTarget()
    return self.Spectate_Target
end

function API:IsColor(Target, Colors)
    if Colors == "Nigger" then
        Colors = {["Really black"] = true,["Black"] = true,["Dark brown"] = true,["Reddish brown"] = true,
            ["Dark orange"] = true,["Earth orange"] = true,["Burnt Sienna"] = true,["Dirt brown"] = true,
            ["Medium brown"] = true,["CGA brown"] = true,["Pine Cone"] = true,["Dark taupe"] = true,
            ["Brown"] = true,["Rust"] = true,["Dark"] = true,["Brownish"] = true,
            ["Dark red"] = true,["Maroon"] = true,["Chocolate"] = true,["Coffee"] = true,
        };
    end

    if Target:IsA("Player") then
        Target = Target.Character or Target.CharacterAdded:Wait()
    end

    local BodyColors = Target and Target:FindFirstChild("Body Colors")
    if not BodyColors then
        return false
    end

    local HeadColor = BodyColors.HeadColor;
    local TorsoColor = BodyColors.TorsoColor;

    return Colors[HeadColor.Name] and Colors[TorsoColor.Name] or false
end

function API:LogGamepasses(State)
    if State == true then
        if self.LogConnection then return end

        if not self.LoggedGamepasses then self.LoggedGamepasses = {} end
        
        local function Capture(Type, Asset)
            local Data = {
                Signal = Type,
                ID = Asset,
                Time = os_date("%H:%M:%S")
            }
            table_insert(self.LoggedGamepasses, Data)
            print("Successfully Logged [" .. Type .. "]: " .. tostring(Asset))
            return Data
        end

        self:_Connect("@Gamepasses_Product", MarketplaceService.PromptProductPurchaseFinished:Connect(function(_, id) Capture("Product", id) end))
        self:_Connect("@Gamepasses_Gamepass", MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(_, id) Capture("Gamepass", id) end))
        self:_Connect("@Gamepasses_Purchase", MarketplaceService.PromptPurchaseFinished:Connect(function(_, id) Capture("Purchase", id) end))
        self:_Connect("@Gamepasses_Bulk", MarketplaceService.PromptBulkPurchaseFinished:Connect(function(_, id) Capture("Bulk", id) end))
        
        self.LogConnection = true
        
    elseif State == false then
        self:ClearGamepasses()
    end
end

function API:GetGamepass(Type, Asset)
    pcall(function()
        if Type == "Product" then
            MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Gamepass" then
            MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Purchase" then
            MarketplaceService:SignalPromptPurchaseFinished(LocalPlayer.UserId, Asset, true)
        elseif Type == "Bulk" then
            MarketplaceService:SignalPromptBulkPurchaseFinished(LocalPlayer.UserId, Asset, true)
        end
    end)
end

function API:ClearGamepasses()
    self:_Disconnect("@Gamepasses_Product")
    self:_Disconnect("@Gamepasses_Gamepass")
    self:_Disconnect("@Gamepasses_Purchase")
    self:_Disconnect("@Gamepasses_Bulk")
    
    self.LogConnection = nil
    self.LoggedGamepasses = nil
end

function API:SelectEverything(Dropdown, List) -- // @Obsidian Only
    if not globalEnv.Library then
        return
    end

    local CurrentValues = Dropdown.Value or {}
    local AddedValues = {}
    local All = true;

    for _, Item in ipairs(List) do
        if not CurrentValues[Item] then
            All = false;
            break
        end
    end

    local State = not All
    for _, item in ipairs(List) do
        AddedValues[Item] = State;
    end
    
    Dropdown:SetValue(AddedValues);
    Library:Notify(State and "Selected" or "Unselected" .. " Everything!", 2);

    return State
end

function API:Rejoin()
    local Plr = self:GetPlayer()

    if #Players:GetPlayers() <= 1 then
        Plr:Kick("Rejoining...")
        task_wait(1);
        TeleportService:Teleport(PlaceId, Plr)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, Plr)
    end
end

function API:ServerHop(MinPlayers, MaxPing)
    local Plr = self:GetPlayer()

    local Success, Result = pcall(function()
        return HttpService:JSONDecode(Game:HttpGet("https://games.roblox.com/v1/games/" ..PlaceId .."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if not Success or not Result then
        warn("[ServerHop]: Failed to fetch servers")
        return
    end

    for _, Server in next, Result.data do
        if Server.id and Server.playing < Server.maxPlayers and Server.playing > (MinPlayers or 0) and (not MaxPing or Server.ping <= MaxPing) then
            TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, Plr)
            return
        end
    end

    warn("[ServerHop]: No suitable server found, try Rejoin()")
end

function API:GetHWID(Method)
    Method = Method or "Roblox"
    
    if Method == "Executor" then
        local Success, HWID = pcall(function()
            if type(gethwid) == "function" then
                return gethwid()
            end
            return nil
        end)
        
        if Success and HWID then
            return HWID
        end
        return nil
    elseif Method == "Roblox" then
        return RbxAnalyticsService:GetClientId()
    elseif Method == "IP" then
        local Success, IP = pcall(function()
            return Game:HttpGet("https://api.ipify.org")
        end)

        if Success and IP then
            return IP
        end
        return nil
    end
    
    return nil
end

function API:Kick(Reason)
    Reason = Reason or "Disconnected by API";
    self:GetPlayer():Kick(Reason);
end

function API:Verify(Options)
    Options = Options or {}
    
    local LPlayer = self:GetPlayer()
    local AllowedList = {}
    
    local RobloxId = self:GetHWID("Roblox")
    local ExecutorHwid = self:GetHWID("Executor")

    if not RobloxId and not ExecutorHwid then
        return false, nil, nil
    end

    if Options.Url then
        local Success, Content = pcall(function()
            return Game:HttpGet(Options.Url)
        end)
    
        if Success then
            local allMatches = {}
            
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(Content)
            end)
            
            if success and type(decoded) == "table" then
                local function extractFromTable(t)
                    for k, v in pairs(t) do
                        if type(v) == "string" then
                            table_insert(allMatches, v)
                        elseif type(v) == "number" then
                            table_insert(allMatches, tostring(v))
                        elseif type(v) == "table" then
                            extractFromTable(v)
                        end
                        if type(k) == "string" then
                            table_insert(allMatches, k)
                        elseif type(k) == "number" then
                            table_insert(allMatches, tostring(k))
                        end
                    end
                end
                extractFromTable(decoded)
            end
            
            local function splitByAnyDelimiter(text)
                local results = {}
                local delimiters = {",", ";", "|", "\t", "\n", "\r", "  "}
                for _, delim in ipairs(delimiters) do
                    text = string_gsub(text, delim, " ")
                end
                for word in string_gmatch(text, "[^%s]+") do
                    table_insert(results, word)
                end
                return results
            end
            
            for line in string_gmatch(Content, "[^\r\n]+") do
                line = line:gsub("^%s+", ""):gsub("%s+$", "")
                if line ~= "" and not line:match("^%s*%-%-") and not line:match("^%s*#") and not line:match("^%s*//") then
                    local words = splitByAnyDelimiter(line)
                    for _, word in ipairs(words) do
                        table_insert(allMatches, word)
                    end
                end
            end
            
            for _, match in ipairs(allMatches) do
                match = match:gsub("^%s+", ""):gsub("%s+$", "")
                match = match:gsub('"', "")
                match = match:gsub("'", "")
                match = match:gsub("[{}%[%]()]", "")
                
                if match ~= "" then
                    table_insert(AllowedList, match)
                end
            end
        else
            warn("[Auth]: Failed to load:", Options.Url)
        end
    end
    
    for _, item in ipairs(Options.Hwids or {}) do
        if item and item ~= "" then
            table_insert(AllowedList, tostring(item))
        end
    end
    
    local function unique(t)
        local seen = {}
        local result = {}
        for _, v in ipairs(t) do
            if not seen[v] then
                seen[v] = true
                table_insert(result, v)
            end
        end
        return result
    end
    
    AllowedList = unique(AllowedList)
    
    local IsWhitelisted = false
    local Type, Value = nil, nil
    
    if RobloxId then
        for _, item in ipairs(AllowedList) do
            if tostring(RobloxId):lower() == tostring(item):lower() then
                IsWhitelisted = true
                Type = "Roblox HWID"
                Value = RobloxId
                break
            end
        end
    end
    
    if not IsWhitelisted and ExecutorHwid then
        for _, item in ipairs(AllowedList) do
            if tostring(ExecutorHwid):lower() == tostring(item):lower() then
                IsWhitelisted = true
                Type = "Executor HWID"
                Value = ExecutorHwid
                break
            end
        end
    end
    
    if not IsWhitelisted then
        for _, item in ipairs(AllowedList) do
            local itemStr = tostring(item):lower()
            if itemStr == tostring(LPlayer.UserId) or itemStr == LPlayer.Name:lower() then
                IsWhitelisted = true
                Type = "User"
                Value = item
                break
            end
        end
    end
    
    if IsWhitelisted then
        return true, Type, Value
    end
    
    return false, nil, nil
end

function API:CreateBaseplate(Options)
    Options = Options or {}

    local Size = Options.Size or Vector3_new(10, 1, 10)
    local Color = Options.Color or Color3_fromRGB(170, 170, 170)
    local Transparency = Options.Transparency or 0
    local Material = Options.Material or Enum.Material.Plastic
    local Offset = Options.Offset or Vector3_new(0, -3.7245, 0)
    local Parent = Options.Parent or Workspace
    local CanCollide = Options.CanCollide ~= false
    local Anchored = Options.Anchored ~= false

    local Baseplate = self:CreateInstance("Part", {
        Name = Options.Name or self:RandomString(15),
        Size = Size,
        Color = Color,
        Transparency = Transparency,
        Material = Material,
        CanCollide = CanCollide,
        Anchored = Anchored,
        Parent = Parent
    })
    
    local function UpdatePosition()
        local Char = self:GetCharacter()
        if not Char then return end

        local Hum = Char:FindFirstChild("HumanoidRootPart")
        if Hum then
            Baseplate.CFrame = Hum.CFrame + Offset
        end
    end

    UpdatePosition()
    
    local Connection = nil
    
    local Usage = {
        Baseplate = Baseplate,
        
        SetSize = function(_, NewSize)
            Baseplate.Size = NewSize
            return Usage
        end,
        
        SetColor = function(_, NewColor)
            Baseplate.Color = NewColor
            return Usage
        end,
        
        SetTransparency = function(_, NewTrans)
            Baseplate.Transparency = NewTrans
            return Usage
        end,
        
        SetFollow = function(_, Followed)
            if Connection then
                self:_Disconnect(Connection)
                Connection = nil
            end
            
            if Followed then
                Connection = "@Baseplate_" .. self:RandomString(15)
                self:_Connect(Connection, RenderStepped:Connect(UpdatePosition))
            end
            return Usage
        end,
        
        SetOffset = function(_, NewOffset)
            Offset = NewOffset
            UpdatePosition()
            return Usage
        end,

        GetOffset = function(_)
            return Offset
        end,
        
        Destroy = function(_)
            if Connection then
                self:_Disconnect(Connection)
                Connection = nil
            end
            Baseplate:Destroy()
            return Usage
        end
    }

    self.CreatedBaseplates = self.CreatedBaseplates or {}
    table_insert(self.CreatedBaseplates, {
        Baseplate = Baseplate,
        Connection = Connection,
        Usage = Usage
    })
    
    return Usage
end

function API:ClearBaseplates()
    self.CreatedBaseplates = self.CreatedBaseplates or {}

    for _, Data in ipairs(self.CreatedBaseplates) do
        pcall(function()
            if Data.Baseplate then
                Data.Baseplate:Destroy()
            end
            if Data.Connection then
                self:_Disconnect(Data.Connection)
            end
        end)
    end

    self.CreatedBaseplates = {}
end

function API:GetCountry(Locale)
    local locale = Locale or LocalizationService.SystemLocaleId or "en-us"
    
    local Countries = {
        ["en-us"] = {Code = "US", Country = "United States", Language = "English", Flag = "🇺🇸", LangCode = "en"},
        ["en-ca"] = {Code = "CA", Country = "Canada", Language = "English", Flag = "🇨🇦", LangCode = "en"},
        ["fr-ca"] = {Code = "CA", Country = "Canada", Language = "French", Flag = "🇨🇦", LangCode = "fr"},
        ["es-mx"] = {Code = "MX", Country = "Mexico", Language = "Spanish", Flag = "🇲🇽", LangCode = "es"},
        
        ["es-gt"] = {Code = "GT", Country = "Guatemala", Language = "Spanish", Flag = "🇬🇹", LangCode = "es"},
        ["es-hn"] = {Code = "HN", Country = "Honduras", Language = "Spanish", Flag = "🇭🇳", LangCode = "es"},
        ["es-sv"] = {Code = "SV", Country = "El Salvador", Language = "Spanish", Flag = "🇸🇻", LangCode = "es"},
        ["es-ni"] = {Code = "NI", Country = "Nicaragua", Language = "Spanish", Flag = "🇳🇮", LangCode = "es"},
        ["es-cr"] = {Code = "CR", Country = "Costa Rica", Language = "Spanish", Flag = "🇨🇷", LangCode = "es"},
        ["es-pa"] = {Code = "PA", Country = "Panama", Language = "Spanish", Flag = "🇵🇦", LangCode = "es"},
        ["es-do"] = {Code = "DO", Country = "Dominican Republic", Language = "Spanish", Flag = "🇩🇴", LangCode = "es"},
        ["es-cu"] = {Code = "CU", Country = "Cuba", Language = "Spanish", Flag = "🇨🇺", LangCode = "es"},
        ["fr-ht"] = {Code = "HT", Country = "Haiti", Language = "French", Flag = "🇭🇹", LangCode = "fr"},
        
        ["es-ar"] = {Code = "AR", Country = "Argentina", Language = "Spanish", Flag = "🇦🇷", LangCode = "es"},
        ["es-bo"] = {Code = "BO", Country = "Bolivia", Language = "Spanish", Flag = "🇧🇴", LangCode = "es"},
        ["es-cl"] = {Code = "CL", Country = "Chile", Language = "Spanish", Flag = "🇨🇱", LangCode = "es"},
        ["es-co"] = {Code = "CO", Country = "Colombia", Language = "Spanish", Flag = "🇨🇴", LangCode = "es"},
        ["es-ec"] = {Code = "EC", Country = "Ecuador", Language = "Spanish", Flag = "🇪🇨", LangCode = "es"},
        ["es-py"] = {Code = "PY", Country = "Paraguay", Language = "Spanish", Flag = "🇵🇾", LangCode = "es"},
        ["es-pe"] = {Code = "PE", Country = "Peru", Language = "Spanish", Flag = "🇵🇪", LangCode = "es"},
        ["es-uy"] = {Code = "UY", Country = "Uruguay", Language = "Spanish", Flag = "🇺🇾", LangCode = "es"},
        ["es-ve"] = {Code = "VE", Country = "Venezuela", Language = "Spanish", Flag = "🇻🇪", LangCode = "es"},
        ["pt-br"] = {Code = "BR", Country = "Brazil", Language = "Portuguese", Flag = "🇧🇷", LangCode = "pt"},
        ["nl-sr"] = {Code = "SR", Country = "Suriname", Language = "Dutch", Flag = "🇸🇷", LangCode = "nl"},
        ["en-gy"] = {Code = "GY", Country = "Guyana", Language = "English", Flag = "🇬🇾", LangCode = "en"},
        ["fr-gf"] = {Code = "GF", Country = "French Guiana", Language = "French", Flag = "🇬🇫", LangCode = "fr"},
        
        ["en-gb"] = {Code = "GB", Country = "United Kingdom", Language = "English", Flag = "🇬🇧", LangCode = "en"},
        ["en-ie"] = {Code = "IE", Country = "Ireland", Language = "English", Flag = "🇮🇪", LangCode = "en"},
        ["fr-fr"] = {Code = "FR", Country = "France", Language = "French", Flag = "🇫🇷", LangCode = "fr"},
        ["es-es"] = {Code = "ES", Country = "Spain", Language = "Spanish", Flag = "🇪🇸", LangCode = "es"},
        ["de-de"] = {Code = "DE", Country = "Germany", Language = "German", Flag = "🇩🇪", LangCode = "de"},
        ["it-it"] = {Code = "IT", Country = "Italy", Language = "Italian", Flag = "🇮🇹", LangCode = "it"},
        ["pt-pt"] = {Code = "PT", Country = "Portugal", Language = "Portuguese", Flag = "🇵🇹", LangCode = "pt"},
        ["nl-nl"] = {Code = "NL", Country = "Netherlands", Language = "Dutch", Flag = "🇳🇱", LangCode = "nl"},
        ["nl-be"] = {Code = "BE", Country = "Belgium", Language = "Dutch", Flag = "🇧🇪", LangCode = "nl"},
        ["fr-be"] = {Code = "BE", Country = "Belgium", Language = "French", Flag = "🇧🇪", LangCode = "fr"},
        ["de-be"] = {Code = "BE", Country = "Belgium", Language = "German", Flag = "🇧🇪", LangCode = "de"},
        ["pl-pl"] = {Code = "PL", Country = "Poland", Language = "Polish", Flag = "🇵🇱", LangCode = "pl"},
        ["ru-ru"] = {Code = "RU", Country = "Russia", Language = "Russian", Flag = "🇷🇺", LangCode = "ru"},
        ["tr-tr"] = {Code = "TR", Country = "Turkey", Language = "Turkish", Flag = "🇹🇷", LangCode = "tr"},
        ["sv-se"] = {Code = "SE", Country = "Sweden", Language = "Swedish", Flag = "🇸🇪", LangCode = "sv"},
        ["da-dk"] = {Code = "DK", Country = "Denmark", Language = "Danish", Flag = "🇩🇰", LangCode = "da"},
        ["no-no"] = {Code = "NO", Country = "Norway", Language = "Norwegian", Flag = "🇳🇴", LangCode = "no"},
        ["fi-fi"] = {Code = "FI", Country = "Finland", Language = "Finnish", Flag = "🇫🇮", LangCode = "fi"},
        ["el-gr"] = {Code = "GR", Country = "Greece", Language = "Greek", Flag = "🇬🇷", LangCode = "el"},
        ["cs-cz"] = {Code = "CZ", Country = "Czech Republic", Language = "Czech", Flag = "🇨🇿", LangCode = "cs"},
        ["hu-hu"] = {Code = "HU", Country = "Hungary", Language = "Hungarian", Flag = "🇭🇺", LangCode = "hu"},
        ["ro-ro"] = {Code = "RO", Country = "Romania", Language = "Romanian", Flag = "🇷🇴", LangCode = "ro"},
        ["uk-ua"] = {Code = "UA", Country = "Ukraine", Language = "Ukrainian", Flag = "🇺🇦", LangCode = "uk"},
        ["bg-bg"] = {Code = "BG", Country = "Bulgaria", Language = "Bulgarian", Flag = "🇧🇬", LangCode = "bg"},
        ["hr-hr"] = {Code = "HR", Country = "Croatia", Language = "Croatian", Flag = "🇭🇷", LangCode = "hr"},
        ["sk-sk"] = {Code = "SK", Country = "Slovakia", Language = "Slovak", Flag = "🇸🇰", LangCode = "sk"},
        ["sl-si"] = {Code = "SI", Country = "Slovenia", Language = "Slovenian", Flag = "🇸🇮", LangCode = "sl"},
        ["lt-lt"] = {Code = "LT", Country = "Lithuania", Language = "Lithuanian", Flag = "🇱🇹", LangCode = "lt"},
        ["lv-lv"] = {Code = "LV", Country = "Latvia", Language = "Latvian", Flag = "🇱🇻", LangCode = "lv"},
        ["et-ee"] = {Code = "EE", Country = "Estonia", Language = "Estonian", Flag = "🇪🇪", LangCode = "et"},
        ["is-is"] = {Code = "IS", Country = "Iceland", Language = "Icelandic", Flag = "🇮🇸", LangCode = "is"},
        ["mt-mt"] = {Code = "MT", Country = "Malta", Language = "Maltese", Flag = "🇲🇹", LangCode = "mt"},
        ["sq-al"] = {Code = "AL", Country = "Albania", Language = "Albanian", Flag = "🇦🇱", LangCode = "sq"},
        ["mk-mk"] = {Code = "MK", Country = "North Macedonia", Language = "Macedonian", Flag = "🇲🇰", LangCode = "mk"},
        ["bs-ba"] = {Code = "BA", Country = "Bosnia", Language = "Bosnian", Flag = "🇧🇦", LangCode = "bs"},
        ["sr-rs"] = {Code = "RS", Country = "Serbia", Language = "Serbian", Flag = "🇷🇸", LangCode = "sr"},
        ["me-me"] = {Code = "ME", Country = "Montenegro", Language = "Montenegrin", Flag = "🇲🇪", LangCode = "sr"},
        ["lb-lu"] = {Code = "LU", Country = "Luxembourg", Language = "Luxembourgish", Flag = "🇱🇺", LangCode = "lb"},
        ["de-li"] = {Code = "LI", Country = "Liechtenstein", Language = "German", Flag = "🇱🇮", LangCode = "de"},
        ["de-ch"] = {Code = "CH", Country = "Switzerland", Language = "German", Flag = "🇨🇭", LangCode = "de"},
        ["fr-ch"] = {Code = "CH", Country = "Switzerland", Language = "French", Flag = "🇨🇭", LangCode = "fr"},
        ["it-ch"] = {Code = "CH", Country = "Switzerland", Language = "Italian", Flag = "🇨🇭", LangCode = "it"},
        ["rm-ch"] = {Code = "CH", Country = "Switzerland", Language = "Romansh", Flag = "🇨🇭", LangCode = "rm"},
        ["at-de"] = {Code = "AT", Country = "Austria", Language = "German", Flag = "🇦🇹", LangCode = "de"},
        
        ["ja-jp"] = {Code = "JP", Country = "Japan", Language = "Japanese", Flag = "🇯🇵", LangCode = "ja"},
        ["zh-cn"] = {Code = "CN", Country = "China", Language = "Chinese Simplified", Flag = "🇨🇳", LangCode = "zh-cn"},
        ["zh-tw"] = {Code = "TW", Country = "Taiwan", Language = "Chinese Traditional", Flag = "🇹🇼", LangCode = "zh-tw"},
        ["zh-hk"] = {Code = "HK", Country = "Hong Kong", Language = "Chinese Traditional", Flag = "🇭🇰", LangCode = "zh-tw"},
        ["ko-kr"] = {Code = "KR", Country = "South Korea", Language = "Korean", Flag = "🇰🇷", LangCode = "ko"},
        ["hi-in"] = {Code = "IN", Country = "India", Language = "Hindi", Flag = "🇮🇳", LangCode = "hi"},
        ["en-in"] = {Code = "IN", Country = "India", Language = "English", Flag = "🇮🇳", LangCode = "en"},
        ["id-id"] = {Code = "ID", Country = "Indonesia", Language = "Indonesian", Flag = "🇮🇩", LangCode = "id"},
        ["th-th"] = {Code = "TH", Country = "Thailand", Language = "Thai", Flag = "🇹🇭", LangCode = "th"},
        ["vi-vn"] = {Code = "VN", Country = "Vietnam", Language = "Vietnamese", Flag = "🇻🇳", LangCode = "vi"},
        ["ms-my"] = {Code = "MY", Country = "Malaysia", Language = "Malay", Flag = "🇲🇾", LangCode = "ms"},
        ["en-my"] = {Code = "MY", Country = "Malaysia", Language = "English", Flag = "🇲🇾", LangCode = "en"},
        ["fil-ph"] = {Code = "PH", Country = "Philippines", Language = "Filipino", Flag = "🇵🇭", LangCode = "tl"},
        ["en-ph"] = {Code = "PH", Country = "Philippines", Language = "English", Flag = "🇵🇭", LangCode = "en"},
        ["bn-bd"] = {Code = "BD", Country = "Bangladesh", Language = "Bengali", Flag = "🇧🇩", LangCode = "bn"},
        ["ur-pk"] = {Code = "PK", Country = "Pakistan", Language = "Urdu", Flag = "🇵🇰", LangCode = "ur"},
        ["en-pk"] = {Code = "PK", Country = "Pakistan", Language = "English", Flag = "🇵🇰", LangCode = "en"},
        ["ar-sa"] = {Code = "SA", Country = "Saudi Arabia", Language = "Arabic", Flag = "🇸🇦", LangCode = "ar"},
        ["ar-ae"] = {Code = "AE", Country = "UAE", Language = "Arabic", Flag = "🇦🇪", LangCode = "ar"},
        ["ar-qa"] = {Code = "QA", Country = "Qatar", Language = "Arabic", Flag = "🇶🇦", LangCode = "ar"},
        ["ar-kw"] = {Code = "KW", Country = "Kuwait", Language = "Arabic", Flag = "🇰🇼", LangCode = "ar"},
        ["ar-bh"] = {Code = "BH", Country = "Bahrain", Language = "Arabic", Flag = "🇧🇭", LangCode = "ar"},
        ["ar-om"] = {Code = "OM", Country = "Oman", Language = "Arabic", Flag = "🇴🇲", LangCode = "ar"},
        ["ar-ye"] = {Code = "YE", Country = "Yemen", Language = "Arabic", Flag = "🇾🇪", LangCode = "ar"},
        ["ar-jo"] = {Code = "JO", Country = "Jordan", Language = "Arabic", Flag = "🇯🇴", LangCode = "ar"},
        ["ar-lb"] = {Code = "LB", Country = "Lebanon", Language = "Arabic", Flag = "🇱🇧", LangCode = "ar"},
        ["he-il"] = {Code = "IL", Country = "Israel", Language = "Hebrew", Flag = "🇮🇱", LangCode = "he"},
        ["fa-ir"] = {Code = "IR", Country = "Iran", Language = "Persian", Flag = "🇮🇷", LangCode = "fa"},
        ["ps-af"] = {Code = "AF", Country = "Afghanistan", Language = "Pashto", Flag = "🇦🇫", LangCode = "ps"},
        ["tk-tm"] = {Code = "TM", Country = "Turkmenistan", Language = "Turkmen", Flag = "🇹🇲", LangCode = "tk"},
        ["uz-uz"] = {Code = "UZ", Country = "Uzbekistan", Language = "Uzbek", Flag = "🇺🇿", LangCode = "uz"},
        ["kk-kz"] = {Code = "KZ", Country = "Kazakhstan", Language = "Kazakh", Flag = "🇰🇿", LangCode = "kk"},
        ["ky-kg"] = {Code = "KG", Country = "Kyrgyzstan", Language = "Kyrgyz", Flag = "🇰🇬", LangCode = "ky"},
        ["tg-tj"] = {Code = "TJ", Country = "Tajikistan", Language = "Tajik", Flag = "🇹🇯", LangCode = "tg"},
        ["mn-mn"] = {Code = "MN", Country = "Mongolia", Language = "Mongolian", Flag = "🇲🇳", LangCode = "mn"},
        ["lo-la"] = {Code = "LA", Country = "Laos", Language = "Lao", Flag = "🇱🇦", LangCode = "lo"},
        ["km-kh"] = {Code = "KH", Country = "Cambodia", Language = "Khmer", Flag = "🇰🇭", LangCode = "km"},
        ["my-mm"] = {Code = "MM", Country = "Myanmar", Language = "Burmese", Flag = "🇲🇲", LangCode = "my"},
        ["si-lk"] = {Code = "LK", Country = "Sri Lanka", Language = "Sinhala", Flag = "🇱🇰", LangCode = "si"},
        ["ta-lk"] = {Code = "LK", Country = "Sri Lanka", Language = "Tamil", Flag = "🇱🇰", LangCode = "ta"},
        ["ne-np"] = {Code = "NP", Country = "Nepal", Language = "Nepali", Flag = "🇳🇵", LangCode = "ne"},
        
        ["ar-eg"] = {Code = "EG", Country = "Egypt", Language = "Arabic", Flag = "🇪🇬", LangCode = "ar"},
        ["ar-ly"] = {Code = "LY", Country = "Libya", Language = "Arabic", Flag = "🇱🇾", LangCode = "ar"},
        ["ar-tn"] = {Code = "TN", Country = "Tunisia", Language = "Arabic", Flag = "🇹🇳", LangCode = "ar"},
        ["ar-dz"] = {Code = "DZ", Country = "Algeria", Language = "Arabic", Flag = "🇩🇿", LangCode = "ar"},
        ["ar-ma"] = {Code = "MA", Country = "Morocco", Language = "Arabic", Flag = "🇲🇦", LangCode = "ar"},
        ["ar-mr"] = {Code = "MR", Country = "Mauritania", Language = "Arabic", Flag = "🇲🇷", LangCode = "ar"},
        ["ar-sd"] = {Code = "SD", Country = "Sudan", Language = "Arabic", Flag = "🇸🇩", LangCode = "ar"},
        ["ar-iq"] = {Code = "IQ", Country = "Iraq", Language = "Arabic", Flag = "🇮🇶", LangCode = "ar"},
        ["ar-sy"] = {Code = "SY", Country = "Syria", Language = "Arabic", Flag = "🇸🇾", LangCode = "ar"},
        ["ar-ps"] = {Code = "PS", Country = "Palestine", Language = "Arabic", Flag = "🇵🇸", LangCode = "ar"},
        
        ["af-za"] = {Code = "ZA", Country = "South Africa", Language = "Afrikaans", Flag = "🇿🇦", LangCode = "af"},
        ["en-za"] = {Code = "ZA", Country = "South Africa", Language = "English", Flag = "🇿🇦", LangCode = "en"},
        ["zu-za"] = {Code = "ZA", Country = "South Africa", Language = "Zulu", Flag = "🇿🇦", LangCode = "zu"},
        ["xh-za"] = {Code = "ZA", Country = "South Africa", Language = "Xhosa", Flag = "🇿🇦", LangCode = "xh"},
        ["st-za"] = {Code = "ZA", Country = "South Africa", Language = "Sesotho", Flag = "🇿🇦", LangCode = "st"},
        ["tn-za"] = {Code = "ZA", Country = "South Africa", Language = "Tswana", Flag = "🇿🇦", LangCode = "tn"},
        ["ss-za"] = {Code = "ZA", Country = "South Africa", Language = "Swati", Flag = "🇿🇦", LangCode = "ss"},
        ["ts-za"] = {Code = "ZA", Country = "South Africa", Language = "Tsonga", Flag = "🇿🇦", LangCode = "ts"},
        ["ve-za"] = {Code = "ZA", Country = "South Africa", Language = "Venda", Flag = "🇿🇦", LangCode = "ve"},
        ["sw-ke"] = {Code = "KE", Country = "Kenya", Language = "Swahili", Flag = "🇰🇪", LangCode = "sw"},
        ["en-ke"] = {Code = "KE", Country = "Kenya", Language = "English", Flag = "🇰🇪", LangCode = "en"},
        ["am-et"] = {Code = "ET", Country = "Ethiopia", Language = "Amharic", Flag = "🇪🇹", LangCode = "am"},
        ["ha-ng"] = {Code = "NG", Country = "Nigeria", Language = "Hausa", Flag = "🇳🇬", LangCode = "ha"},
        ["yo-ng"] = {Code = "NG", Country = "Nigeria", Language = "Yoruba", Flag = "🇳🇬", LangCode = "yo"},
        ["ig-ng"] = {Code = "NG", Country = "Nigeria", Language = "Igbo", Flag = "🇳🇬", LangCode = "ig"},
        ["en-ng"] = {Code = "NG", Country = "Nigeria", Language = "English", Flag = "🇳🇬", LangCode = "en"},
        ["so-so"] = {Code = "SO", Country = "Somalia", Language = "Somali", Flag = "🇸🇴", LangCode = "so"},
        ["rw-rw"] = {Code = "RW", Country = "Rwanda", Language = "Kinyarwanda", Flag = "🇷🇼", LangCode = "rw"},
        ["rn-bi"] = {Code = "BI", Country = "Burundi", Language = "Kirundi", Flag = "🇧🇮", LangCode = "rn"},
        ["mg-mg"] = {Code = "MG", Country = "Madagascar", Language = "Malagasy", Flag = "🇲🇬", LangCode = "mg"},
        ["fr-mg"] = {Code = "MG", Country = "Madagascar", Language = "French", Flag = "🇲🇬", LangCode = "fr"},
        ["sn-zw"] = {Code = "ZW", Country = "Zimbabwe", Language = "Shona", Flag = "🇿🇼", LangCode = "sn"},
        ["en-zw"] = {Code = "ZW", Country = "Zimbabwe", Language = "English", Flag = "🇿🇼", LangCode = "en"},
        ["ny-mw"] = {Code = "MW", Country = "Malawi", Language = "Chichewa", Flag = "🇲🇼", LangCode = "ny"},
        ["en-mw"] = {Code = "MW", Country = "Malawi", Language = "English", Flag = "🇲🇼", LangCode = "en"},
        ["pt-mz"] = {Code = "MZ", Country = "Mozambique", Language = "Portuguese", Flag = "🇲🇿", LangCode = "pt"},
        ["ln-cd"] = {Code = "CD", Country = "DR Congo", Language = "Lingala", Flag = "🇨🇩", LangCode = "ln"},
        ["sw-cd"] = {Code = "CD", Country = "DR Congo", Language = "Swahili", Flag = "🇨🇩", LangCode = "sw"},
        ["fr-cd"] = {Code = "CD", Country = "DR Congo", Language = "French", Flag = "🇨🇩", LangCode = "fr"},
        ["fr-ci"] = {Code = "CI", Country = "Ivory Coast", Language = "French", Flag = "🇨🇮", LangCode = "fr"},
        ["fr-sn"] = {Code = "SN", Country = "Senegal", Language = "French", Flag = "🇸🇳", LangCode = "fr"},
        ["fr-cm"] = {Code = "CM", Country = "Cameroon", Language = "French", Flag = "🇨🇲", LangCode = "fr"},
        ["en-cm"] = {Code = "CM", Country = "Cameroon", Language = "English", Flag = "🇨🇲", LangCode = "en"},
        ["fr-bf"] = {Code = "BF", Country = "Burkina Faso", Language = "French", Flag = "🇧🇫", LangCode = "fr"},
        ["fr-ml"] = {Code = "ML", Country = "Mali", Language = "French", Flag = "🇲🇱", LangCode = "fr"},
        ["fr-ne"] = {Code = "NE", Country = "Niger", Language = "French", Flag = "🇳🇪", LangCode = "fr"},
        ["fr-tg"] = {Code = "TG", Country = "Togo", Language = "French", Flag = "🇹🇬", LangCode = "fr"},
        ["fr-bj"] = {Code = "BJ", Country = "Benin", Language = "French", Flag = "🇧🇯", LangCode = "fr"},
        ["fr-ga"] = {Code = "GA", Country = "Gabon", Language = "French", Flag = "🇬🇦", LangCode = "fr"},
        ["fr-cg"] = {Code = "CG", Country = "Congo", Language = "French", Flag = "🇨🇬", LangCode = "fr"},
        ["fr-gq"] = {Code = "GQ", Country = "Equatorial Guinea", Language = "French", Flag = "🇬🇶", LangCode = "fr"},
        ["es-gq"] = {Code = "GQ", Country = "Equatorial Guinea", Language = "Spanish", Flag = "🇬🇶", LangCode = "es"},
        ["pt-gw"] = {Code = "GW", Country = "Guinea-Bissau", Language = "Portuguese", Flag = "🇬🇼", LangCode = "pt"},
        ["pt-cv"] = {Code = "CV", Country = "Cape Verde", Language = "Portuguese", Flag = "🇨🇻", LangCode = "pt"},
        ["pt-st"] = {Code = "ST", Country = "Sao Tome", Language = "Portuguese", Flag = "🇸🇹", LangCode = "pt"},
        
        ["en-au"] = {Code = "AU", Country = "Australia", Language = "English", Flag = "🇦🇺", LangCode = "en"},
        ["en-nz"] = {Code = "NZ", Country = "New Zealand", Language = "English", Flag = "🇳🇿", LangCode = "en"},
        ["mi-nz"] = {Code = "NZ", Country = "New Zealand", Language = "Maori", Flag = "🇳🇿", LangCode = "mi"},
        ["en-pg"] = {Code = "PG", Country = "Papua New Guinea", Language = "English", Flag = "🇵🇬", LangCode = "en"},
        ["tpi-pg"] = {Code = "PG", Country = "Papua New Guinea", Language = "Tok Pisin", Flag = "🇵🇬", LangCode = "tpi"},
        ["en-fj"] = {Code = "FJ", Country = "Fiji", Language = "English", Flag = "🇫🇯", LangCode = "en"},
        ["fj-fj"] = {Code = "FJ", Country = "Fiji", Language = "Fijian", Flag = "🇫🇯", LangCode = "fj"},
        ["sm-ws"] = {Code = "WS", Country = "Samoa", Language = "Samoan", Flag = "🇼🇸", LangCode = "sm"},
        ["en-ws"] = {Code = "WS", Country = "Samoa", Language = "English", Flag = "🇼🇸", LangCode = "en"},
        ["to-to"] = {Code = "TO", Country = "Tonga", Language = "Tongan", Flag = "🇹🇴", LangCode = "to"},
        ["en-to"] = {Code = "TO", Country = "Tonga", Language = "English", Flag = "🇹🇴", LangCode = "en"},
        ["ty-py"] = {Code = "PF", Country = "French Polynesia", Language = "Tahitian", Flag = "🇵🇫", LangCode = "ty"},
        ["fr-pf"] = {Code = "PF", Country = "French Polynesia", Language = "French", Flag = "🇵🇫", LangCode = "fr"},
        ["en-sb"] = {Code = "SB", Country = "Solomon Islands", Language = "English", Flag = "🇸🇧", LangCode = "en"},
        ["bi-vu"] = {Code = "VU", Country = "Vanuatu", Language = "Bislama", Flag = "🇻🇺", LangCode = "bi"},
        ["en-vu"] = {Code = "VU", Country = "Vanuatu", Language = "English", Flag = "🇻🇺", LangCode = "en"},
        ["fr-vu"] = {Code = "VU", Country = "Vanuatu", Language = "French", Flag = "🇻🇺", LangCode = "fr"},
        ["na-nr"] = {Code = "NR", Country = "Nauru", Language = "Nauruan", Flag = "🇳🇷", LangCode = "na"},
        ["en-nr"] = {Code = "NR", Country = "Nauru", Language = "English", Flag = "🇳🇷", LangCode = "en"},
        ["mh-mh"] = {Code = "MH", Country = "Marshall Islands", Language = "Marshallese", Flag = "🇲🇭", LangCode = "mh"},
        ["en-mh"] = {Code = "MH", Country = "Marshall Islands", Language = "English", Flag = "🇲🇭", LangCode = "en"},
        ["ch-gu"] = {Code = "GU", Country = "Guam", Language = "Chamorro", Flag = "🇬🇺", LangCode = "ch"},
        ["en-gu"] = {Code = "GU", Country = "Guam", Language = "English", Flag = "🇬🇺", LangCode = "en"},
        
        ["en"] = {Code = "US", Country = "United States", Language = "English", Flag = "🇺🇸", LangCode = "en"},
    }
    
    local Result = Countries[locale] or Countries[locale:sub(1,2)] or Countries["en-us"]

    return Result.Code, Result.Country, Result.Language, Result.Flag, locale, Result.LangCode
end

function API:_GetLanguage(Input)
    if not Input then return nil end

    local Lowered = tostring(Input):lower()
    if Lowered == "home" then
        local Code, Country, Language, Flag, Locale, LangCode = self:GetCountry()
        return LangCode or "en"
    end

    local Languages = {
        auto = "Automatic", af = "Afrikaans", sq = "Albanian", ar = "Arabic",
        hy = "Armenian", az = "Azerbaijani", eu = "Basque", be = "Belarusian",
        bn = "Bengali", bs = "Bosnian", bg = "Bulgarian", ca = "Catalan",
        ceb = "Cebuano", ny = "Chichewa", ["zh-cn"] = "Chinese Simplified", 
        ["zh-tw"] = "Chinese Traditional", co = "Corsican", hr = "Croatian",
        cs = "Czech", da = "Danish", nl = "Dutch", en = "English",
        eo = "Esperanto", et = "Estonian", tl = "Filipino", fi = "Finnish",
        fr = "French", fy = "Frisian", gl = "Galician", ka = "Georgian",
        de = "German", el = "Greek", gu = "Gujarati", ht = "Haitian Creole",
        ha = "Hausa", haw = "Hawaiian", he = "Hebrew", hi = "Hindi",
        hmn = "Hmong", hu = "Hungarian", is = "Icelandic", ig = "Igbo",
        id = "Indonesian", ga = "Irish", it = "Italian", ja = "Japanese",
        jw = "Javanese", kn = "Kannada", kk = "Kazakh", km = "Khmer",
        ko = "Korean", ku = "Kurdish", ky = "Kyrgyz", lo = "Lao",
        la = "Latin", lv = "Latvian", lt = "Lithuanian", lb = "Luxembourgish",
        mk = "Macedonian", mg = "Malagasy", ms = "Malay", ml = "Malayalam",
        mt = "Maltese", mi = "Maori", mr = "Marathi", mn = "Mongolian",
        my = "Myanmar", ne = "Nepali", no = "Norwegian", ps = "Pashto",
        fa = "Persian", pl = "Polish", pt = "Portuguese", pa = "Punjabi",
        ro = "Romanian", ru = "Russian", sm = "Samoan", gd = "Scots Gaelic",
        sr = "Serbian", st = "Sesotho", sn = "Shona", sd = "Sindhi",
        si = "Sinhala", sk = "Slovak", sl = "Slovenian", so = "Somali",
        es = "Spanish", su = "Sundanese", sw = "Swahili", sv = "Swedish",
        tg = "Tajik", ta = "Tamil", te = "Telugu", th = "Thai",
        tr = "Turkish", uk = "Ukrainian", ur = "Urdu", uz = "Uzbek",
        vi = "Vietnamese", cy = "Welsh", xh = "Xhosa", yi = "Yiddish",
        yo = "Yoruba", zu = "Zulu"
    }
    
    if Languages[Lowered] then
        return Lowered
    end

    for Code, Name in pairs(Languages) do
        if Name:lower() == Lowered then
            return Code
        end
    end
    
    return nil
end

function API:Translate(Text, TargetLang, Source)
    if not Text or Text == "" then return nil end
    
    TargetLang = self:_GetLanguage(TargetLang or "en")
    Source = self:_GetLanguage(Source or "auto")
    
    if not TargetLang then TargetLang = "en" end
    if not Source then Source = "auto" end

    self.TranslateMemoryCache = self.TranslateMemoryCache or {}
    self.TranslateMemoryCache[TargetLang] = self.TranslateMemoryCache[TargetLang] or {}
    
    local CacheRoot = "@Translations/"
    local TargetPath = CacheRoot .. TargetLang .. "/"
    
    if not is_folder(CacheRoot) then make_folder(CacheRoot) end
    if not is_folder(TargetPath) then make_folder(TargetPath) end
    
    local Words = {}
    for Word in string_gmatch(Text, "[^%s]+") do
        local CleanWord = string_gsub(Word, "[%p%c]", "")
        if CleanWord ~= "" then
            table_insert(Words, {
                Original = Word,
                Clean = CleanWord
            })
        end
    end
    
    local TranslatedWords = {}
    local UncachedWords = {}
    local NeedsTranslation = false
    
    if Source ~= "auto" then
        self.TranslateMemoryCache[TargetLang][Source] = self.TranslateMemoryCache[TargetLang][Source] or {}
        local MemCache = self.TranslateMemoryCache[TargetLang][Source]
        
        local SourcePath = TargetPath .. Source .. "/"
        if not is_folder(SourcePath) then make_folder(SourcePath) end
        
        for Index, WordData in ipairs(Words) do
            local CachedTranslation = MemCache[WordData.Clean]
            
            if CachedTranslation then
                TranslatedWords[Index] = CachedTranslation
            else
                local CacheFile = SourcePath .. WordData.Clean .. ".json"
                
                if is_file(CacheFile) then
                    local Success, Cached = pcall(function()
                        return Http:JSONDecode(read_file(CacheFile))
                    end)
                    
                    if Success and Cached then
                        MemCache[WordData.Clean] = Cached.Translated
                        TranslatedWords[Index] = Cached.Translated
                    else
                        table_insert(UncachedWords, {
                            Index = Index,
                            Word = WordData.Original,
                            Clean = WordData.Clean
                        })
                        NeedsTranslation = true
                    end
                else
                    table_insert(UncachedWords, {
                        Index = Index,
                        Word = WordData.Original,
                        Clean = WordData.Clean
                    })
                    NeedsTranslation = true
                end
            end
        end
    else
        NeedsTranslation = true
    end
    
    if not NeedsTranslation and #UncachedWords == 0 then
        local Result = table_concat(TranslatedWords, " ")
        return Result, TargetLang, Text, Source
    end
    
    local TranslateAPI = ("https://translate.googleapis.com/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s")
        :format(Source, TargetLang, HttpService:UrlEncode(Text))
    
    local RequestSuccess, Response = pcall(function()
        return Game:HttpGet(TranslateAPI)
    end)

    if not RequestSuccess or not Response then 
        return nil 
    end
    
    local DecodeSuccess, Data = pcall(function()
        return HttpService:JSONDecode(Response)
    end)
    
    if not DecodeSuccess or type(Data) ~= "table" then
        return nil
    end
    
    local TranslatedText = nil
    local OriginalText = nil
    
    if Data[1] and type(Data[1]) == "table" then
        local TranslatedParts = {}
        local OriginalParts = {}
        
        for i = 1, #Data[1] do
            if Data[1][i] and Data[1][i][1] then
                table_insert(TranslatedParts, Data[1][i][1])
            end
            if Data[1][i] and Data[1][i][0] then
                table_insert(OriginalParts, Data[1][i][0])
            end
        end
        
        if #OriginalParts == 0 and Data[1][1] and Data[1][1][2] then
            for i = 1, #Data[1] do
                if Data[1][i] and Data[1][i][2] then
                    table_insert(OriginalParts, Data[1][i][2])
                end
            end
        end
        
        if #TranslatedParts > 0 then
            TranslatedText = table_concat(TranslatedParts, "")
        end
        if #OriginalParts > 0 then
            OriginalText = table_concat(OriginalParts, "")
        else
            OriginalText = Text
        end
    end
    
    local DetectedSource = Data[3] or Source
    local TargetCode = TargetLang
    
    if not TranslatedText then
        return nil
    end
    
    if DetectedSource ~= "auto" then
        self.TranslateMemoryCache[TargetLang][DetectedSource] = self.TranslateMemoryCache[TargetLang][DetectedSource] or {}
        local MemCache = self.TranslateMemoryCache[TargetLang][DetectedSource]
        
        local SourcePath = TargetPath .. DetectedSource .. "/"
        if not is_folder(SourcePath) then make_folder(SourcePath) end
        
        local TranslatedWordList = {}
        for Word in string_gmatch(TranslatedText, "[^%s]+") do
            local CleanWord = string_gsub(Word, "[%p%c]", "")
            table_insert(TranslatedWordList, {
                Original = Word,
                Clean = CleanWord
            })
        end
        
        for Index, WordData in ipairs(Words) do
            if TranslatedWordList[Index] then
                MemCache[WordData.Clean] = TranslatedWordList[Index].Original
                
                local CacheFile = SourcePath .. WordData.Clean .. ".json"
                local CacheData = {
                    Original = WordData.Original,
                    Translated = TranslatedWordList[Index].Original
                }
                
                pcall(function()
                    write_file(CacheFile, HttpService:JSONEncode(CacheData))
                end)
            end
        end
    end
    
    return TranslatedText, TargetCode, OriginalText, DetectedSource
end

-- // Developer Tool Scripts
function API:Infinite_Yield()
    return self:LoadFile("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
end

function API:Cobalt_Spy()
    return self:Gitport("notpoiu", "cobalt", "latest", "Cobalt.luau")
end

function API:Katemine_Spy()
    return self:LoadFile("https://raw.githubusercontent.com/InfernusScripts/Ketamine/main/Ketamine.lua")
end

function API:Simple_Spy()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua")
end

function API:Dex_Explorer()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua")
end

function API:Audio_Logger()
    return self:LoadFile("https://raw.githubusercontent.com/infyiff/backup/main/audiologger.lua")
end

-- // @Loop Manager.Module, Build: 1.45
function API:CreateStacks()
    if type(self.Stacks) ~= "table" then
        self.Stacks = {
			While = {Connection = nil, Coroutines = {}, Active = true},
			Heartbeat = {Connection = nil, Functions = {}, Active = true},
            RenderStep = {Connection = nil, Functions = {}, Active = true},
            Stepped = {Connection = nil, Functions = {}, Active = true},
        }
    end
end

function API:LogLM(Message, ...)
    if not self.LM_Debug then return end
    if not Message then return end
    warn("[@Loop Manager]: " .. string_format(Message, ...))
end

local function AddService(self, Name, Signal)
    local Stack = self.Stacks[Name]
    if Stack.Connection then return end

    Stack.Connection = Signal:Connect(function(...)
        if self.UnloadedLM then return end

        local Funcs = Stack.Functions
        for Name, Data in pairs(Funcs) do
            if Data.Running and not Data.Paused then
                if type(Data.Callback) == "function" then
                    task_spawn(Data.Callback, self, ...)
                else
                    self:LogLM("Callback for '%s' is not a function", Name)
                end
            end
        end
    end)
end

function API:WhileLoop(WaitBoy, Callback, Name, WaitBefore)
    self:CreateStacks()

    if type(WaitBoy) == "function" then
        local Function_1, Function_2, Function_3 = WaitBoy, Callback, Name

        WaitBoy = nil
        Callback = Function_1
        Name = Function_2
        WaitBefore = Function_3
    end

    if not Callback or type(Callback) ~= "function" then
        self:LogLM("WhileLoop requires a callback function")
        return nil
    end

    local Wait = WaitBoy or 0
    local Name = Name or self:RandomString(15)
    local Local = self
    local Waiting = {}
    
    local Stack_Data = self.Stacks.While[Wait]
    if not Stack_Data then
        Stack_Data = {
            Coroutines = {},
            Running = true,
            Connection = nil,
            Wait = Wait,
            LastRun = nil
        }
        self.Stacks.While[Wait] = Stack_Data
        
        Stack_Data.Connection = Heartbeat:Connect(function(deltaTime)
            if Local.UnloadedLM then return end
            if not Stack_Data.Running then return end

            local Time = os_clock()

            local Running = false
            if Wait == 0 then
                Running = true
            elseif Stack_Data.LastRun == nil then
                Running = true
                Stack_Data.LastRun = Time
            elseif Time - Stack_Data.LastRun >= Stack_Data.Wait then
                Running = true
                Stack_Data.LastRun = Time
            end
            
            for name, data in pairs(Stack_Data.Coroutines) do
                if data.Running and not data.Paused then
                    local Floop = Waiting[data.Coroutine]
                    if Floop then Floop.Remaining = Floop.Remaining - deltaTime
                        if Floop.Remaining <= 0 then
                            Waiting[data.Coroutine] = nil
                            data.IsWaiting = false
                        end
                    end
                end
            end
            
            if Running then
                for name, data in pairs(Stack_Data.Coroutines) do
                    if data.Running and not data.Paused and not data.IsWaiting then
                        local Floop = Waiting[data.Coroutine]
                        if not Floop then
                            task_resume(data.Coroutine, Local, deltaTime)
                        end
                    end
                end
            end
        end)
    end

    local function Cooldown(Seconds)
        local co = task_running()
        Waiting[co] = {Remaining = Seconds}
        for name, data in pairs(Stack_Data.Coroutines) do
            if data.Coroutine == co then
                data.IsWaiting = true
                break
            end
        end
        task_yield()
    end
    
    local Delay = 0 
    if WaitBefore == true then 
        Delay = Wait 
    elseif type(WaitBefore) == "number" then 
        Delay = WaitBefore 
    end

    local Source = task_create(function(self, deltaTime)
        if Delay > 0 then
            Cooldown(Delay)
        end
    
        while Stack_Data.Running do
            Callback(self, deltaTime, Cooldown)
            task_yield()
        end
    end)

    local Data = {
        Running = true,
        Paused = false,
        IsWaiting = false,
        Coroutine = Source,
        Name = Name,
        Wait = Wait,
        WaitBefore = WaitBefore,
        
        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused WhileLoop '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused WhileLoop '%s'", Name)
        end,
        
        SetWait = function(s, New)
            if type(New) ~= "number" or New < 0 then
                self:LogLM("Invalid wait time for '%s': %s", Name, tostring(New))
                return
            end
            if Stack_Data then
                Stack_Data.Wait = New
                s.Wait = New
                self:LogLM("Set wait for '%s' to %s seconds", Name, New)
            end
        end,

        Kill = function(s) 
            s.Running = false
            if Stack_Data.Coroutines then
                Stack_Data.Coroutines[Name] = nil
            end
            if Stack_Data.Coroutines and not next(Stack_Data.Coroutines) then
                Stack_Data.Running = false
                if Stack_Data.Connection then
                    Stack_Data.Connection:Disconnect()
                end
                if self.Stacks and self.Stacks.While then
                    self.Stacks.While[Wait] = nil
                end
            end
            self:LogLM("Killed WhileLoop '%s'", Name)
        end
    }

    Stack_Data.Coroutines[Name] = Data
    if WaitBefore then task_resume(Source, Local, 0) end

    return Data
end

function API:SetWait(Name, New)
    if not self.Stacks or not self.Stacks.While then
        return false
    end

    for Wait, Stack_Data in pairs(self.Stacks.While) do
        if Stack_Data.Coroutines and Stack_Data.Coroutines[Name] then
            if type(New) ~= "number" or New < 0 then
                self:LogLM("Invalid wait time for '%s': %s", Name, tostring(New))
                return false
            end
            Stack_Data.Wait = New
            Stack_Data.Coroutines[Name].Wait = New
            self:LogLM("Updated wait for '%s' to %s seconds", Name, New)
            return true
        end
    end

    self:LogLM("SetWait failed: Could not find loop named '%s'", Name)
    return false
end

function API:RenderStep(Callback, Name)
    self:CreateStacks()

    if type(Callback) ~= "function" then
        self:LogLM("RenderStep requires a callback function")
        return nil
    end

    local Name = Name or self:RandomString(15)
    AddService(self, "RenderStep", RenderStepped)

    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused RenderStep '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused RenderStep '%s'", Name)
        end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.RenderStep.Functions then
                self.Stacks.RenderStep.Functions[Name] = nil
            end
            self:LogLM("Killed RenderStep '%s'", Name)
        end
    }
    
    self.Stacks.RenderStep.Functions[Name] = Data
    return Data
end

function API:Heartbeat(Callback, Name)
    self:CreateStacks()

    if type(Callback) ~= "function" then
        self:LogLM("Heartbeat requires a callback function")
        return nil
    end

    local Name = Name or self:RandomString(15)
    AddService(self, "Heartbeat", Heartbeat)
    
    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused Heartbeat '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused Heartbeat '%s'", Name)
        end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.Heartbeat.Functions then
                self.Stacks.Heartbeat.Functions[Name] = nil
            end
            self:LogLM("Killed Heartbeat '%s'", Name)
        end
    }
    
    self.Stacks.Heartbeat.Functions[Name] = Data
    return Data
end

function API:Stepped(Callback, Name)
    self:CreateStacks()

    if type(Callback) ~= "function" then
        self:LogLM("Stepped requires a callback function")
        return nil
    end

    local Name = Name or self:RandomString(15)
    AddService(self, "Stepped", Stepped)
    
    local Data = {
        Running = true,
        Paused = false,
        Callback = Callback,

        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused Stepped '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused Stepped '%s'", Name)
        end,

        Kill = function(s) 
            s.Running = false
            if self.Stacks.Stepped.Functions then
                self.Stacks.Stepped.Functions[Name] = nil
            end
            self:LogLM("Killed Stepped '%s'", Name)
        end
    }
    
    self.Stacks.Stepped.Functions[Name] = Data
    return Data
end

function API:BindRender(Callback, Name, Priority)
    self:CreateStacks()

    if type(Callback) ~= "function" then
        self:LogLM("BindRender requires a callback function")
        return nil
    end

    local Name = Name or self:RandomString(15)
    
    local Data = {
        Type = "BindToRenderStep",
        Name = Name,
        Running = true,
        Paused = false,

        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused BindToRenderStep '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused BindToRenderStep '%s'", Name)
        end,

        Kill = function(s) 
            s.Running = false
            pcall(function() 
                UnbindFromRenderStep(s.Name or Name)
            end)
            if self.ActiveConnections then
                self.ActiveConnections[Name] = nil
            end
            self:LogLM("Killed BindRender '%s'", Name)
        end
    }

    local Func = function(dt)
        if self.UnloadedLM or not Data.Running or Data.Paused then 
            return 
        end
        Callback(self, dt)
    end

    BindToRenderStep(Name, Priority or Enum.RenderPriority.Last.Value, Func)
    Data.Func = Func
    
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = Data
    
    return Data
end

function API:BindKeybind(Key, Callback, BindName)
    self:CreateStacks()

    if not Key then
        self:LogLM("BindKeybind requires a Key parameter")
        return nil
    end

    if type(Callback) ~= "function" then
        self:LogLM("BindKeybind requires a callback function")
        return nil
    end

    local Name = BindName or self:RandomString(15)

    local Data = {
        Type = "Keybind",
        Name = Name,
        Key = Key,
        Running = true,
        Paused = false,
        
        Pause = function(s) 
            s.Paused = true 
            self:LogLM("Paused Keybind '%s'", Name)
        end,
        Unpause = function(s) 
            s.Paused = false 
            self:LogLM("Unpaused Keybind '%s'", Name)
        end,
        
        Kill = function(s) 
            s.Running = false
            if s.Connection then
                s.Connection:Disconnect()
            end
            if self.ActiveConnections then
                self.ActiveConnections[Name] = nil
            end
            self:LogLM("Killed Keybind '%s'", Name)
        end
    }

    local Func = function(Input, Processed)
        if Processed or self.UnloadedLM or not Data.Running or Data.Paused then 
            return 
        end
        
        if Input.KeyCode == Key or Input.UserInputType == Key then
            Callback(self, Input)
        end
    end

    Data.Connection = InputBegan:Connect(Func)
    Data.Callback = Callback
    Data.InternalFunc = Func
    
    self.ActiveConnections = self.ActiveConnections or {}
    self.ActiveConnections[Name] = Data
   
    return Data
end

function API:SetKeybind(Name, NewKey)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if not Entry or Entry.Type ~= "Keybind" then
        self:LogLM("SetKeybind failed: '%s' not found or not a keybind", Name)
        return false, "Invalid keybind"
    end

    if not NewKey then
        self:LogLM("SetKeybind requires a NewKey parameter")
        return false, "Invalid key"
    end

    self:LogLM("Updating keybind '%s' from %s to %s", Name, tostring(Entry.Key), tostring(NewKey))

    if Entry.Connection then
        Entry.Connection:Disconnect()
    end

    Entry.Key = NewKey

    local Func = function(Input, Processed)
        if Processed or self.UnloadedLM or not Entry.Running or Entry.Paused then 
            return 
        end
        if Input.KeyCode == NewKey or Input.UserInputType == NewKey then
            Entry.Callback(self, Input)
        end
    end

    Entry.Connection = InputBegan:Connect(Func)
    Entry.InternalFunc = Func

    return true
end

function API:ForceStop(Name)
    local Entry = self.ActiveConnections and self.ActiveConnections[Name]
    if Entry then
        Entry.Running = false
    
        if Entry.Type == "BindToRenderStep" then
            pcall(function() 
                UnbindFromRenderStep(Entry.Name or Name)
            end)
        elseif Entry.Connection then
            Entry.Connection:Disconnect()
        end
        
        self.ActiveConnections[Name] = nil
        return true
    end
    
    if self.Stacks then
        for Wait, Stack in pairs(self.Stacks.While) do
            if type(Wait) == "number" and type(Stack) == "table" and Stack.Coroutines and Stack.Coroutines[Name] then
                local Data = Stack.Coroutines[Name]
                Data.Running = false
                Stack.Coroutines[Name] = nil

                if not next(Stack.Coroutines) then
                    Stack.Running = false
                    if Stack.Connection then
                        Stack.Connection:Disconnect()
                    end
                    self.Stacks.While[Wait] = nil
                end
                return true
            end
        end
        
        if self.Stacks.Heartbeat and self.Stacks.Heartbeat.Functions and self.Stacks.Heartbeat.Functions[Name] then
            self.Stacks.Heartbeat.Functions[Name] = nil
            return true
        end
        
        if self.Stacks.RenderStep and self.Stacks.RenderStep.Functions and self.Stacks.RenderStep.Functions[Name] then
            self.Stacks.RenderStep.Functions[Name] = nil
            return true
        end
        
        if self.Stacks.Stepped and self.Stacks.Stepped.Functions and self.Stacks.Stepped.Functions[Name] then
            self.Stacks.Stepped.Functions[Name] = nil
            return true
        end
    end

    self:LogLM("ForceStop: Could not find '%s'", Name)
    return false
end

function API:GetState(Name)
    local Entry = (self.ActiveConnections and self.ActiveConnections[Name]) or (self.ActiveTasks and self.ActiveTasks[Name])
    if Entry then
        if not Entry.Running then return false end
        if Entry.Paused then return "Paused" end
        return true
    end

    if self.Stacks then
        for Wait, Stack in pairs(self.Stacks.While) do
            local Data = Stack.Functions and Stack.Functions[Name]
            if Data then
                if not Data.Running then return false end
                if Data.Paused then return "Paused" end
                return true
            end
        end

        local Data = self.Stacks.Heartbeat.Functions and self.Stacks.Heartbeat.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
        
        Data = self.Stacks.RenderStep.Functions and self.Stacks.RenderStep.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
        
        Data = self.Stacks.Stepped.Functions and self.Stacks.Stepped.Functions[Name]
        if Data then
            if not Data.Running then return false end
            if Data.Paused then return "Paused" end
            return true
        end
    end
    
    return nil
end

function API:AddTask(Signal, Callback, Name)
    self.ActiveTasks = self.ActiveTasks or {}

    if self.ActiveTasks[Name] then
        return self.ActiveTasks[Name]
    end

    local Name = Name or self:RandomString(15)
    local Local = self

    local Data = {
        Signal = Signal, 
        Callback = Callback, 
        Connection = nil, 
        Running = true,
        Paused = false,
        Type = "Task"
    }

    Data.Pause = function(S) 
        S.Paused = true 
        self:LogLM("Task '%s' paused", Name)
    end
    Data.Unpause = function(S) 
        S.Paused = false 
        self:LogLM("Task '%s' unpaused", Name)
    end
    Data.Kill = function(S) 
        Local:StopTask(Name)
        self:LogLM("Task '%s' killed", Name)
    end

    local function wrapper()
        Data.Connection = Signal:Connect(function(...)
            if Data.Running and not Data.Paused and not Local.UnloadedLM then
                Callback(Local, ...)
            end
        end)
    end

    wrapper()
    Data.Reconnect = wrapper
    self.ActiveTasks[Name] = Data

    return Data
end

function API:StopTask(Name)
    local Data = self.ActiveTasks and self.ActiveTasks[Name]
    if Data then
        Data.Running = false
        if Data.Connection then
            Data.Connection:Disconnect()
            Data.Connection = nil
        end
        self.ActiveTasks[Name] = nil
        self:LogLM("Task '%s' stopped", Name)
    else
        self:LogLM("StopTask: Task '%s' not found", Name)
    end
end

function API:RestartTask(Name)
    local Data = self.ActiveTasks and self.ActiveTasks[Name]
    if Data then
        if Data.Running then 
            Data.Connection:Disconnect() 
        end
        
        Data.Running = true
        Data.Paused = false
        Data.Reconnect()
        self:LogLM("Task '%s' restarted", Name)
    else
        self:LogLM("RestartTask: Task '%s' not found", Name)
    end
end

function API:UnloadLM()
    self.UnloadedLM = true

    local Count = 0
    if self.ActiveConnections then
        for Instance, _ in pairs(self.ActiveConnections) do
            self:ForceStop(Instance)
            Count = Count + 1
        end
        if Count > 0 then
            self:LogLM("Unloaded %d active connections", Count)
        end
    end

    Count = 0
    if self.ActiveTasks then
        for Instance, _ in pairs(self.ActiveTasks) do
            self:StopTask(Instance)
            Count = Count + 1
        end
        if Count > 0 then
            self:LogLM("Unloaded %d active tasks", Count)
        end
    end

    if self.Stacks then
        Count = 0
        for Wait, Stack in pairs(self.Stacks.While) do
            if type(Wait) == "number" and Stack and Stack.Coroutines then
                for Name, _ in pairs(Stack.Coroutines) do
                    self:ForceStop(Name)
                    Count = Count + 1
                end
            end
        end
        if Count > 0 then
            self:LogLM("Unloaded %d WhileLoops", Count)
        end
        
        Count = 0
        if self.Stacks.Heartbeat and self.Stacks.Heartbeat.Functions then
            for Instance, _ in pairs(self.Stacks.Heartbeat.Functions) do
                self:ForceStop(Instance)
                Count = Count + 1
            end
            if Count > 0 then
                self:LogLM("Unloaded %d Heartbeats", Count)
            end
        end

        Count = 0
        if self.Stacks.RenderStep and self.Stacks.RenderStep.Functions then
            for Instance, _ in pairs(self.Stacks.RenderStep.Functions) do
                self:ForceStop(Instance)
                Count = Count + 1
            end
            if Count > 0 then
                self:LogLM("Unloaded %d RenderSteps", Count)
            end
        end

        Count = 0
        if self.Stacks.Stepped and self.Stacks.Stepped.Functions then
            for Instance, _ in pairs(self.Stacks.Stepped.Functions) do
                self:ForceStop(Instance)
                Count = Count + 1
            end
            if Count > 0 then
                self:LogLM("Unloaded %d Steppeds", Count)
            end
        end
    end
end

function API:ToggleLM(State)
    if typeof(State) == "boolean" then
        self.UnloadedLM = State
    end
end

function API:OverrideFunction(Name, Func)
    if typeof(self[Name]) ~= "function" then
        return false
    end

    self[self:RandomString(15)] = self[Name]
    self[Name] = Func

    return true
end

function API:Unload()
    warn("[@Functions.luau]: Unloaded")
    self:_Disconnect("@Engine.luau")

    self:UnloadLM();
    self:XRay(false);
    self:Flight(false, nil);
    self:BypassWS(false, nil);
	self:Strengthen(false, nil);
    self:TouchFling(false);
    self:BypassJP(false, nil);
    self:InfiniteJump(false);
    self:AntiCollider(false);
	self:SetQueue(false);

    self:StopClip();
    self:StopFling();
    self:StopFps();
	self:StopBringTools();
    self:ClearHighlights();
    self:ClearBaseplates();
    self:ClearWebSockets();
    self:ClearGamepasses();
	self:ClearDrawingsV();
	self:ClearDrawings();
	self:StopSpectate();
    self:ClearSounds();
    self:ClearRaknet();

    globalEnv._IsLoadedFM = nil
    global.FunctionManager_Engine = nil
    task_wait(0.35);

    for Instance in pairs(API) do
        API[Instance] = nil -- // 💀
    end
    setmetatable(API, nil)
end

function API:Merge(...) -- // Merges with one another module 😉
    for _, Modules in ipairs({...}) do
        for Method, Func in pairs(Modules) do
            if typeof(Func) == "function" then
                if self.Core and self.Core[Method] then
                    continue;
                end

                if self[Method] == nil then
                    self[Method] = function(_, ...)
                        return Func(self, ...)
                    end
                end
            end
        end
    end
    return self
end

function API.Launch(Class)
    Class.Core = {}

    -- // @Services
	Class.Workspace = Workspace
    Class.Players = Players
    Class.LocalPlayer = LocalPlayer
    Class.Character = Character
	Class.Roots = Roots
	Class.Humanoid = Humanoid
    Class.RunService = RunService
    Class.TweenService = TweenService
    Class.MarketplaceService = MarketplaceService
    Class.HttpService = HttpService
    Class.TeleportService = TeleportService
    Class.RbxAnalyticsService = RbxAnalyticsService
    Class.VirtualInputManager = VirtualInputManager
	Class.LocalizationService = LocalizationService
    Class.UserInputService = UserInputService
    Class.SoundService = SoundService
    Class.StarterGuiService = StarterGuiService
    Class.LightingService = LightingService
    Class.CurrentCamera = CurrentCamera
    Class.CoreGui = CoreGui

	global.FunctionManager_Engine = Class
    return setmetatable(Class, {__index = API})
end

local Functions = 0
for _, v in pairs(API) do
    if type(v) == "function" then Functions = Functions + 1 end
end

local EndTime = os_clock()
warn(string_format("[@Functions.luau] Loaded in %.3f ms, Build: %s, Functions: %d | By: %s", (EndTime - LoadTime) * 1000, Project.Build, Functions, Project.Author))

return API