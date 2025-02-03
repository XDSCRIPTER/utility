print("Hello")

local Players = game:GetService("Players")
local UserInputType = game:GetService("UserInputType")
local LocalPlayer = Players.LocalPlayer;

local Utility = {};

Utility.onPlayerAdded = Players.PlayerAdded
Utility.onCharacterAdded = Player.CharacterAdded


local mathFloor = clonefunction(math.floor)
local isDescendantOf = clonefunction(game.IsDescendantOf);
local findChildIsA = clonefunction(game.FindFirstChildWhichIsA);
local findFirstChild = clonefunction(game.FindFirstChild);

local IsA = clonefunction(game.IsA);

local getMouseLocation = clonefunction(UserInputService.GetMouseLocation);
local getPlayers = clonefunction(Players.GetPlayers);

local worldToViewportPoint = clonefunction(Instance.new(getServerConstant('Camera')).WorldToViewportPoint);

function Utility:countTable(t)
    local found = 0;

    for i, v in next, t do
        found = found + 1;
    end;

    return found;
end;

function Utility:roundVector(vector)
    return Vector3.new(vector.X, 0, vector.Z);
end;

function Utility:getCharacter(player)
    local playerData = self:getPlayerData(player);
    if (not playerData.alive) then return end;

    local maxHealth, health = playerData.maxHealth, playerData.health;
    return playerData.character, maxHealth, (health / maxHealth) * 100, mathFloor(health), playerData.rootPart;
end;

function Utility:isTeamMate(player)
    local playerData, myPlayerData = self:getPlayerData(player), self:getPlayerData();
    local playerTeam, myTeam = playerData.team, myPlayerData.team;

    if(playerTeam == nil or myTeam == nil) then
        return false;
    end;

    return playerTeam == myTeam;
end;

function Utility:getRootPart(player)
    local playerData = self:getPlayerData(player);
    return playerData and playerData.rootPart;
end;

function Utility:renderOverload(data) end;

local function castPlayer(origin, direction, rayParams, playerToFind)
    local distanceTravalled = 0;

    while true do
        distanceTravalled = distanceTravalled + direction.Magnitude;

        local target = workspace:Raycast(origin, direction, rayParams);

        if(target) then
            if(isDescendantOf(target.Instance, playerToFind)) then
                return false;
            elseif(target and target.Instance.CanCollide) then
                return true;
            end;
        elseif(distanceTravalled > 2000) then
            return false;
        end;

        origin = origin + direction;
    end;
end;


local playersData = {};

local function onCharacterAdded(player)
    local playerData = playersData[player];
    if (not playerData) then return end;

    local character = player.Character;
    if (not character) then return end;

    local localAlive = true;

    table.clear(playerData.parts);

    Utility.listenToChildAdded(character, function(obj)
        if (obj.Name == 'Humanoid') then
            playerData.humanoid = obj;
        elseif (obj.Name == 'HumanoidRootPart') then
            playerData.rootPart = obj;
        elseif (obj.Name == 'Head') then
            playerData.head = obj;
        end;
    end);

    if (player == LocalPlayer) then
        Utility.listenToDescendantAdded(character, function(obj)
            if (IsA(obj, 'BasePart')) then
                table.insert(playerData.parts, obj);

                local con;
                con = obj:GetPropertyChangedSignal('Parent'):Connect(function()
                    if (obj.Parent) then return end;
                    con:Disconnect();
                    table.remove(playerData.parts, table.find(playerData.parts, obj));
                end);
            end;
        end);
    end;

return Utility;
