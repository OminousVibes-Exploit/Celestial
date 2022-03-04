local HttpService = game:GetService("HttpService")

local configs = {
    folder = "directory",
    source = "OminousVibes-Exploit/Celestial/main",
    root = "https://raw.githubusercontent.com/"
}

-- Functions:
local function requestHttp(path: string)
    local url = configs.root .. configs.source .. "/" .. path
    return game:HttpGet(url, true)
end

local function writeFile(path: string, content: string)
    local nodes = path:split("/")
    local folder = nodes[1]
    if not isfolder(folder) then makefolder(folder) end
    for i = 2, #nodes - 1 do
        folder = folder .. "/" .. nodes[i]
        if not isfolder(folder) then makefolder(folder) end
    end
    writefile(path, content)
    return path
end

-- Installer:
local Installer = {}
Installer.installed = isfile(configs.folder)
    and isfile(configs.folder .. "/build.json");

function Installer.isUpdated()
    if Installer.installed then
        local build = HttpService:JSONDecode(
            readfile(configs.folder .. "/build.json")
        );
        local latest = HttpService:JSONDecode(
            requestHttp("/build.json")
        )
        return build.version < latest.version;
    else
        return false
    end
end

function Installer.update()
    local build = requestHttp("/build.json")
    local latest = HttpService:JSONDecode(build)
    for i,v in pairs(latest.src) do
        local file = configs.folder .. "/src/" .. v
        local chunk = requestHttp(v)
        writeFile(file, chunk)
    end
    for i,v in pairs(latest.packages) do
        local file = configs.folder .. "/packages/" .. v
        local chunk = requestHttp(v)
        writeFile(file, chunk)
    end
    writeFile(configs.folder .. "/build.json", build)
end

return Installer